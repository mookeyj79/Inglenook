#requires -Version 7.0
<#
.SYNOPSIS
    The steps of the screenshot workflow (.github/workflows/screenshots.yml)
    that are not a shot: what to shoot, the run summary, and the rolling pull
    request. The shots themselves are build/photograph.ps1 -Port <app> -Report.

.DESCRIPTION
    plan     Writes the run's plan as JSON to -Out: { shoot: [{ port, runner, variant, take }],
             manual: [{ port, app, reason, ... }] (the stale manual ports),
             manual_fresh: [{ port, app }], skipped: [{ port, platform }] }. With
             -Port, that port; with -All, every port; with -BaseRoot (a checkout
             of a pull request's base), the ports the pull request changed;
             otherwise every stale port. Exits 1 on a recipe error.
    summary  Prints each port's result in -Results as Markdown for the run
             summary: matches, or how many pixels differ from the committed shot.
             A port shot in a job per variant or take shows each job's own result;
             with -Whole, each port's merged result, with the take verdict.
    deliver  In a checkout of main: copies the changed images from -Results,
             restamps the unchanged ones whose fingerprint moved (pixels kept),
             and adds missing README tables. Writes { images, restamped, tables,
             pull_request } to -Out; pull_request is false when only stamps
             changed, and then the rolling pull request is left alone.
    body     Prints the rolling pull request's body, from -Results, -Plan and
             -Delivery, with old images from -Base and new ones from -Commit.
    note     Prints the comment that closes the rolling pull request when a run
             has nothing to deliver.
    issues   From -Plan and -Issues (gh issue list --json number,title,state,
             body,comments), writes to -Out the list of what to do to the
             "Screenshots for <app>" issues: [{ action, number, title, body }],
             action being create, reopen, comment or close.

    With -Plan, summary, body and note count a planned port with no result as
    failed.

    The rules live in build/lib/ScreenshotRun.psm1. Never commits, pushes, or
    calls GitHub: the workflow does that.

.EXAMPLE
    pwsh build/screenshots.ps1 plan -Out plan.json
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)][ValidateSet('plan', 'summary', 'deliver', 'body', 'note', 'issues')][string]$Step,
    [string]$Port,
    [switch]$All,
    [string]$BaseRoot,
    [string]$Results,
    [string]$Plan,
    [string]$Delivery,
    [string]$Issues,
    [string]$Out,
    [string]$Repo,
    [string]$Base,
    [string]$Commit,
    [string]$RunUrl,
    [switch]$Whole
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($m in 'Palette', 'Catalog', 'Photographer', 'ScreenshotRun') {
    Import-Module (Join-Path $PSScriptRoot 'lib' "$m.psm1") -Force
}
$RepoRoot = Split-Path -Parent $PSScriptRoot

function Read-Results([switch]$Parts) {
    # Every port's result (one per job with -Parts). With -Plan, a planned port that
    # left none (its jobs died before photograph.ps1 could write one) counts as failed.
    $found = [System.Collections.Generic.List[object]]::new()
    if ($Results) { foreach ($r in @(Read-ShotResults -Results $Results -RepoRoot $RepoRoot -Parts:$Parts)) { $found.Add($r) } }
    if ($Plan) {
        foreach ($s in @((Read-JsonFile $Plan)['shoot'])) {
            if (-not ($found | Where-Object { $_['port'] -eq $s['port'] })) {
                $found.Add([ordered]@{ port = $s['port']; app = $s['port']; status = 'failed'; why = ''; variants = [ordered]@{}
                                      error = 'Its shoot job left no result. See the run log.' })
            }
        }
    }
    return @($found | Sort-Object { $_['port'] })
}

switch ($Step) {
    'plan' {
        $t = Get-ShotTargets -RepoRoot $RepoRoot -Port $Port -All:$All -BaseRoot $BaseRoot
        foreach ($e in $t.Errors) { Write-Host $e -ForegroundColor Red }
        $planData = [ordered]@{ shoot = @($t.Shoot); manual = @($t.Manual); manual_fresh = @($t.ManualFresh); skipped = @($t.Skipped) }
        Set-Content -Path $Out -Value (ConvertTo-Json -InputObject $planData -Depth 5 -Compress)
        Write-Host "To shoot: $(if ($t.Shoot.Count) { @($t.Shoot | ForEach-Object { "$($_.port)$(if ($_.variant) { " ($($_.variant))" }) on $($_.runner)" }) -join ', ' } else { 'nothing' })"
        foreach ($s in $t.Skipped) { Write-Host "$($s.port): shot on $($s.platform), which this workflow does not shoot yet." }
        foreach ($m in $t.Manual) { Write-Host "$($m.port): manual recipe, stale." }
        if ($t.Errors.Count) { exit 1 }
    }
    'summary' {
        $found = @(Read-Results -Parts:(-not $Whole))
        if (-not $found.Count) { Write-Output 'No port was shot.'; break }
        foreach ($r in $found) { Write-Output (ConvertTo-ShotSummary -Result $r) }
    }
    'deliver' {
        $palette = Read-Palette -Path (Join-Path $RepoRoot 'palette' 'palette.json')
        $d = Copy-ShotDelivery -RepoRoot $RepoRoot -Results $Results -DayName $palette.Variants['day'].Name -NightName $palette.Variants['night'].Name
        Set-Content -Path $Out -Value (ConvertTo-Json -InputObject ([ordered]@{ images = @($d.Images); restamped = @($d.Restamped); tables = @($d.Tables); pull_request = $d.PullRequest }) -Compress)
        foreach ($i in $d.Images) { Write-Host "Changed: $i" }
        foreach ($i in $d.Restamped) { Write-Host "Stamp only: $i" }
        foreach ($t in $d.Tables) { Write-Host "README table added: Ports/$t/README.md" }
        if (-not $d.PullRequest -and $d.Restamped.Count) { Write-Host 'Only stamps changed, no pixel: the rolling pull request is left alone.' }
    }
    'body' {
        $p = Read-JsonFile $Plan
        $d = Read-JsonFile $Delivery
        Write-Output (New-DeliveryBody -Results @(Read-Results) -Images @($d['images']) -Restamped @($(if ($d.Contains('restamped')) { $d['restamped'] })) -Tables @($d['tables']) -Manual @($p['manual']) -Skipped @($p['skipped']) `
            -Repo $Repo -Base $Base -Commit $Commit -RunUrl $RunUrl)
    }
    'note' { Write-Output (New-DeliveryNote -Results @(Read-Results) -RunUrl $RunUrl) }
    'issues' {
        $p = Read-JsonFile $Plan
        $palette = Read-Palette -Path (Join-Path $RepoRoot 'palette' 'palette.json')
        $actions = @(Get-ManualIssueActions -Manual @($p['manual']) -Fresh @($p['manual_fresh']) -Issues @(Read-JsonFile $Issues) `
            -DayName $palette.Variants['day'].Name -NightName $palette.Variants['night'].Name -RunUrl $RunUrl `
            -Backdrops @{ day = (Format-SceneBackdrop (Get-SceneBackdrop -RepoRoot $RepoRoot -Variant 'day')); night = (Format-SceneBackdrop (Get-SceneBackdrop -RepoRoot $RepoRoot -Variant 'night')) })
        Set-Content -Path $Out -Value (ConvertTo-Json -InputObject $actions -Depth 4)
        foreach ($a in $actions) { Write-Host "$($a['action']) $(if ($a['number']) { "#$($a['number']) " })$($a['title'])" }
        if (-not $actions.Count) { Write-Host 'No manual port issue to change.' }
    }
}
