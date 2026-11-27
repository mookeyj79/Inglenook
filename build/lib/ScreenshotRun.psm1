# A screenshot run in GitHub Actions: which ports it shoots, what the delivery
# job commits, and what the rolling pull request and the run summary say.
# Not a fingerprint input, so changing how a run reports retakes nothing.
# .github/workflows/screenshots.yml and build/screenshots.ps1 are the thin shell around it.

Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'Catalog.psm1')
Import-Module (Join-Path $PSScriptRoot 'Photographer.psm1')
Import-Module (Join-Path $PSScriptRoot 'Png.psm1')

function Get-FileBytesHash([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return '' }
    return Get-Sha256 ([System.IO.File]::ReadAllBytes($Path))
}

# Platforms whose takes are each shot on a fresh job, as a Linux take gets a fresh
# container: a Windows take changes the desktop (mode, effects, a DWM restart) and
# the app's own state in ways another take should not inherit. Every take the take
# verdict may ask for runs at once, and the verdict reads them in order
# (Merge-ShotTakes), so a later take counts only when the verdict asks for it.
$JobPerTake = @('windows')
$TakeJobs = 3   # the most takes Get-TakeVerdict reads

function Get-ShotTargets {
    <#
    .SYNOPSIS
        The jobs a run shoots, each with its runner label, the preview's
        shot list among them (on the Linux runner). Returns
        @{ Shoot; Manual; ManualFresh; Skipped; Errors }.
    .DESCRIPTION
        Shoot: @{ port; runner; variant; take } for each chosen port whose platform
        has a runner in the pins file (build/photograph/pins.json, 'runners').
        Variant and take are '' (one job shoots both variants, every take), or on
        Windows each variant's takes 1 to 3, one job each.
        Skipped: @{ port; platform } for chosen ports whose platform has none
        yet. Manual: for each stale manual recipe, @{ port; app; reason; kind;
        scene; fingerprint; shots; why }: scene is the repo path of its scene's
        content ('' if there is none yet), shots whether both images exist, why
        what changed since they were stamped. ManualFresh: @{ port; app } for
        each fresh one. Errors: the catalog's recipe errors, and any runner label
        that is not pinned (one ending in -latest). Manual ports are listed
        whatever the run chooses.

        Chosen: with -Port, that port; with -All, every recipe; with -BaseRoot
        (a checkout of a pull request's base), every port whose fingerprint or
        committed shots differ from the base's; otherwise every stale port.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [string]$Port, [switch]$All, [string]$BaseRoot)
    $catalog = Get-PortCatalog -PortsRoot (Join-Path $RepoRoot 'Ports')
    $pins = Read-JsonFile (Join-Path $RepoRoot 'build/photograph/pins.json') -Quiet
    $runners = if ($pins -and $pins['runners'] -is [System.Collections.IDictionary]) { $pins['runners'] } else { @{} }
    $errors = [System.Collections.Generic.List[string]]::new()
    foreach ($e in @($catalog.RecipeErrors)) { $errors.Add($e) }
    foreach ($k in @($runners.Keys)) {
        if ([string]$runners[$k] -like '*-latest') { $errors.Add("build/photograph/pins.json: the $k runner is '$($runners[$k])'. Pin an exact image label, never -latest.") }
    }
    $withRecipe = @($catalog.Ports | Where-Object Recipe | Sort-Object Name)
    $withList = @($catalog.Ports | Where-Object Shots | Sort-Object Name)
    if ($Port -and -not ($withRecipe + $withList | Where-Object Name -eq $Port)) { throw "Ports/$Port has no screenshot.json or shots.json, or it is not valid." }

    $shoot = [System.Collections.Generic.List[object]]::new()
    $manual = [System.Collections.Generic.List[object]]::new()
    $manualFresh = [System.Collections.Generic.List[object]]::new()
    $skipped = [System.Collections.Generic.List[object]]::new()
    # A shot list (the preview) is shot on Linux, in the pinned Chromium.
    foreach ($p in $withList) {
        $fingerprint = Get-PreviewFingerprint -RepoRoot $RepoRoot -Port $p.Name
        $names = @($p.Shots | ForEach-Object { $_['name'] })
        $chosen = if ($Port) { $p.Name -eq $Port }
                  elseif ($All) { $true }
                  elseif ($BaseRoot) { Test-ShotAffected -RepoRoot $RepoRoot -BaseRoot $BaseRoot -Port $p.Name -Fingerprint $fingerprint.Fingerprint -Names $names -List }
                  else { Test-ShotStale -Dir (Join-Path $p.Dir 'screenshots') -Fingerprint $fingerprint.Fingerprint -Names $names }
        if (-not $chosen) { continue }
        if ($runners.Contains('linux')) { $shoot.Add([ordered]@{ port = $p.Name; runner = [string]$runners['linux']; variant = ''; take = '' }) }
        else { $skipped.Add([ordered]@{ port = $p.Name; platform = 'linux' }) }
    }
    foreach ($p in $withRecipe) {
        $recipe = $p.Recipe
        $fingerprint = Get-ShotFingerprint -RepoRoot $RepoRoot -Port $p.Name -Recipe $recipe
        $stale = Test-ShotStale -Dir (Join-Path $p.Dir 'screenshots') -Fingerprint $fingerprint.Fingerprint
        if ($recipe.Contains('manual')) {
            $app = if ($p.Meta -and $p.Meta['name']) { [string]$p.Meta['name'] } else { $p.Name }
            if ($stale) { $manual.Add((Get-ManualState -RepoRoot $RepoRoot -Entry $p -App $app -Fingerprint $fingerprint)) }
            else { $manualFresh.Add([ordered]@{ port = $p.Name; app = $app }) }
            continue
        }
        $chosen = if ($Port) { $p.Name -eq $Port }
                  elseif ($All) { $true }
                  elseif ($BaseRoot) { Test-ShotAffected -RepoRoot $RepoRoot -BaseRoot $BaseRoot -Port $p.Name -Fingerprint $fingerprint.Fingerprint }
                  else { $stale }
        if (-not $chosen) { continue }
        $platform = [string]$recipe['platform']
        if ($runners.Contains($platform)) {
            $jobs = if ($platform -in $JobPerTake) { @(foreach ($v in 'day', 'night') { foreach ($t in 1..$TakeJobs) { @{ Variant = $v; Take = "$t" } } }) }
                    else { @(@{ Variant = ''; Take = '' }) }
            foreach ($j in $jobs) { $shoot.Add([ordered]@{ port = $p.Name; runner = [string]$runners[$platform]; variant = $j.Variant; take = $j.Take }) }
        }
        else { $skipped.Add([ordered]@{ port = $p.Name; platform = $platform }) }
    }
    return [pscustomobject]@{ Shoot = $shoot.ToArray(); Manual = $manual.ToArray(); ManualFresh = $manualFresh.ToArray()
                              Skipped = $skipped.ToArray(); Errors = $errors.ToArray() }
}

function Get-ManualState([string]$RepoRoot, $Entry, [string]$App, $Fingerprint) {
    # A stale manual port, as its issue needs it. Why compares the first stale
    # image's stamp with what a stamp would record now.
    $recipe = $Entry.Recipe
    $scene = "build/photograph/scenes/$(Get-SceneFolder $recipe['kind'])"
    $shotDir = Join-Path $Entry.Dir 'screenshots'
    $shots = @('day', 'night' | Where-Object { Test-Path -LiteralPath (Join-Path $shotDir "$_.png") -PathType Leaf }).Count -eq 2
    $why = ''
    if ($shots) {
        $new = New-ManualShotStamp -Fingerprint $Fingerprint
        foreach ($v in 'day', 'night') {
            $old = try { Read-ShotStamp -Path (Join-Path $shotDir "$v.png") } catch { $null }
            if ($null -eq $old) { $old = @{} }
            if ($old.Contains('fingerprint') -and $old['fingerprint'] -ceq $Fingerprint.Fingerprint) { continue }
            $why = Get-ShotWhy -Old $old -New $new -App $App
            break
        }
    }
    return [ordered]@{
        port = $Entry.Name; app = $App; reason = [string]$recipe['manual']; kind = [string]$recipe['kind']
        scene = $(if (Test-Path -LiteralPath (Join-Path $RepoRoot $scene) -PathType Container) { $scene } else { '' })
        fingerprint = $Fingerprint.Fingerprint; shots = $shots; why = $why
    }
}

function Test-ShotAffected([string]$RepoRoot, [string]$BaseRoot, [string]$Port, [string]$Fingerprint, [string[]]$Names = @('day', 'night'), [switch]$List) {
    # True if a pull request changed this port's inputs or its committed shots.
    # -List: the port has a shot list (shots.json), not a recipe.
    if ($List) {
        if (-not (Test-Path (Join-Path $BaseRoot 'Ports' $Port 'shots.json'))) { return $true }
        $baseFingerprint = Get-PreviewFingerprint -RepoRoot $BaseRoot -Port $Port
    }
    else {
        $baseRecipe = Read-JsonFile (Join-Path $BaseRoot 'Ports' $Port 'screenshot.json') -Quiet
        if ($baseRecipe -isnot [System.Collections.IDictionary] -or -not $baseRecipe.Contains('kind')) { return $true }
        $baseFingerprint = Get-ShotFingerprint -RepoRoot $BaseRoot -Port $Port -Recipe $baseRecipe
    }
    if ($baseFingerprint.Fingerprint -cne $Fingerprint) { return $true }
    foreach ($v in $Names) {
        $rel = Join-Path 'Ports' $Port 'screenshots' "$v.png"
        if ((Get-FileBytesHash (Join-Path $RepoRoot $rel)) -cne (Get-FileBytesHash (Join-Path $BaseRoot $rel))) { return $true }
    }
    return $false
}

function Merge-ShotParts([object[]]$Parts) {
    # One port's result from its per-variant jobs' results. Both variants or neither:
    # a part that failed, or a variant with no part, fails the port.
    $first = $Parts[0]
    $variants = [ordered]@{}
    $errors = [System.Collections.Generic.List[string]]::new()
    $why = ''
    foreach ($v in 'day', 'night') {
        $part = @($Parts | Where-Object { $_['variant'] -eq $v }) | Select-Object -First 1
        if (-not $part) { $errors.Add("The $v job left no result. See the run log."); continue }
        if ($part['status'] -eq 'failed') { $errors.Add("${v}: $(([string]$part['error']).TrimEnd())") }
        if ($part['variants'] -is [System.Collections.IDictionary] -and $part['variants'].Contains($v)) { $variants[$v] = $part['variants'][$v] }
        if (-not $why -and $part['why']) { $why = [string]$part['why'] }
    }
    $status = if ($errors.Count) { 'failed' }
              elseif (@($variants.Values | Where-Object { $_['verdict'] -eq 'changed' }).Count) { 'changed' }
              else { 'unchanged' }
    return [ordered]@{ port = $first['port']; app = $first['app']; status = $status; why = $(if ($status -eq 'changed') { $why } else { '' })
                       error = ($errors -join "`n"); variants = $variants }
}

function Merge-ShotTakes {
    <#
    .SYNOPSIS
        One variant's result from its takes, each shot in a job of its own: the
        take verdict (Get-TakeVerdict) read over takes 1, 2 and 3 in order,
        stopping as soon as it decides. Returns a part as a job per variant
        writes it, so Merge-ShotParts takes it from there.
    .DESCRIPTION
        Takes are the take parts of one port and variant (result-<variant>-<take>.json),
        Dir the port's results folder with the takes in takes/<variant>-<take>.png,
        and Committed the committed shot ($null if there is none). A take the
        verdict asks for that failed, or left no result, fails the variant; one
        it does not ask for is never read. A changed variant names its shot in
        file, relative to Dir; an unchanged one names its last take there, whose
        stamp the committed shot takes (Update-ShotStamp).
    #>
    param([Parameter(Mandatory)][object[]]$Takes, [Parameter(Mandatory)][string]$Dir, $Committed)
    $first = $Takes[0]
    $v = [string]$first['variant']
    $part = [ordered]@{ port = $first['port']; app = $first['app']; variant = $v; status = 'failed'; why = ''; error = ''; variants = [ordered]@{} }
    $paths = [System.Collections.Generic.List[string]]::new()
    $verdict = $null
    for ($t = 1; $t -le $TakeJobs; $t++) {
        $take = @($Takes | Where-Object { [int]$_['take'] -eq $t }) | Select-Object -First 1
        if (-not $take) { $part.error = "take $t left no result. See the run log."; return $part }
        if ($take['status'] -eq 'failed') { $part.error = "take $t`: $(([string]$take['error']).TrimEnd())"; return $part }
        $paths.Add((Join-Path $Dir 'takes' "$v-$t.png"))
        $verdict = Get-TakeVerdict -Committed $Committed -Takes $paths.ToArray()
        if ($verdict.Verdict -ne 'retake') { break }
    }
    if ($verdict.Verdict -eq 'failed') { $part.error = 'three takes differ from each other and from the committed shot. Something in the scene changes between takes.'; return $part }
    $compare = if ($Committed) { Compare-ShotPixels -Path $paths[-1] -Other $Committed } else { $null }
    $part.status = $verdict.Verdict
    $part.why = [string]$first['why']
    $part.variants[$v] = [ordered]@{
        verdict = $verdict.Verdict; takes = $paths.Count; committed = [bool]$Committed
        compare = if ($compare) { [ordered]@{ same = $compare.Same; differ = $compare.Differ; max_delta = $compare.MaxDelta; size = $compare.Size } } else { $null }
        file = [System.IO.Path]::GetRelativePath($Dir, $(if ($verdict.Verdict -eq 'changed') { $verdict.Shot } else { $paths[-1] })).Replace('\', '/')
    }
    return $part
}

function Read-ShotResults {
    <#
    .SYNOPSIS
        Every port's result in a folder of photograph.ps1 -Report outputs, by port.
    .DESCRIPTION
        A port shot in one job leaves result.json. A port shot in a job per
        variant leaves result-day.json and result-night.json, merged here into
        one result (both variants or neither). A port shot in a job per take
        leaves result-<variant>-<take>.json, given the take verdict here
        (Merge-ShotTakes) against the committed shots under RepoRoot. -Parts
        returns each file's result as it is, for the summary of a single job.
    #>
    param([Parameter(Mandatory)][string]$Results, [string]$RepoRoot, [switch]$Parts)
    if (-not (Test-Path -LiteralPath $Results)) { return @() }
    return @(foreach ($d in @(Get-ChildItem -LiteralPath $Results -Directory | Sort-Object Name)) {
        $whole = Read-JsonFile (Join-Path $d.FullName 'result.json') -Quiet
        $split = @(Get-ChildItem -LiteralPath $d.FullName -File -Filter 'result-*.json' | Sort-Object Name | ForEach-Object { Read-JsonFile $_.FullName -Quiet } | Where-Object { $_ })
        if ($Parts) { if ($whole) { $whole }; $split }
        elseif ($whole) { $whole }
        elseif ($split.Count) {
            $takes = @($split | Where-Object { $_.Contains('take') })
            $byVariant = @($split | Where-Object { -not $_.Contains('take') })
            foreach ($v in @($takes | ForEach-Object { [string]$_['variant'] } | Sort-Object -Unique)) {
                if (-not $RepoRoot) { throw "Read-ShotResults: $($d.Name) was shot in a job per take; its verdict needs -RepoRoot for the committed shots." }
                $committed = Join-Path $RepoRoot 'Ports' $d.Name 'screenshots' "$v.png"
                if (-not (Test-Path -LiteralPath $committed -PathType Leaf)) { $committed = $null }
                $byVariant += Merge-ShotTakes -Takes @($takes | Where-Object { $_['variant'] -eq $v }) -Dir $d.FullName -Committed $committed
            }
            Merge-ShotParts $byVariant
        }
    })
}

function Copy-ShotDelivery {
    <#
    .SYNOPSIS
        Puts a run's changed images into a checkout of main and adds every
        missing README Day and Night table (the preview lays out its own).
        Returns @{ Images; Restamped; Tables; Results; PullRequest }.
    .DESCRIPTION
        Results is the folder of photograph.ps1 -Report outputs, one folder per
        port with result.json and the last take of each image (a port's day
        and night, or each image of the preview's shot list). Only an image
        whose verdict is 'changed', of a port whose status is 'changed', is
        copied: a failed port keeps all of its old images. An unchanged image
        of a port that did not fail keeps its pixels and takes its take's stamp
        if the fingerprint moved, so it is not stale forever. Images are the repo
        paths whose pixels changed, Restamped those whose stamp alone did,
        Tables the ports whose README gained a table, Results every port's result.
        PullRequest is whether the rolling pull request should open or update:
        only when a pixel changed or a table was added. New stamps alone (the
        Restamped images) ride along with the next real change.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Results,
        [Parameter(Mandatory)][string]$DayName, [Parameter(Mandatory)][string]$NightName)
    $all = Read-ShotResults $Results -RepoRoot $RepoRoot
    $images = [System.Collections.Generic.List[string]]::new()
    $restamped = [System.Collections.Generic.List[string]]::new()
    foreach ($r in $all) {
        if ($r['status'] -notin 'changed', 'unchanged') { continue }
        foreach ($v in @($r['variants'].Keys)) {
            $x = $r['variants'][$v]
            $rel = "Ports/$($r['port'])/screenshots/$v.png"
            $dest = Join-Path $RepoRoot $rel
            $file = if ($x.Contains('file') -and $x['file']) { $x['file'] } else { "$v.png" }
            $take = Join-Path $Results $r['port'] $file
            if ($x['verdict'] -eq 'changed') {
                New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
                Copy-Item -LiteralPath $take -Destination $dest -Force
                $images.Add($rel)
            }
            elseif ($x['verdict'] -eq 'unchanged' -and (Test-Path -LiteralPath $dest -PathType Leaf) -and (Test-Path -LiteralPath $take -PathType Leaf)) {
                if (Update-ShotStamp -Committed $dest -Take $take) { $restamped.Add($rel) }
            }
        }
    }
    $tables = [System.Collections.Generic.List[string]]::new()
    foreach ($dir in @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'Ports') -Directory | Sort-Object Name)) {
        $readme = Join-Path $dir.FullName 'README.md'
        if (-not ((Test-Path (Join-Path $dir.FullName 'screenshots' 'day.png')) -and (Test-Path $readme))) { continue }
        if (Test-Path (Join-Path $dir.FullName 'shots.json')) { continue }   # the preview lays out its own images
        $text = [System.IO.File]::ReadAllText($readme)
        $updated = Add-ShotTable -Readme $text -DayName $DayName -NightName $NightName
        if ($updated -cne $text) { [System.IO.File]::WriteAllText($readme, $updated); $tables.Add($dir.Name) }
    }
    return [pscustomobject]@{ Images = $images.ToArray(); Restamped = $restamped.ToArray(); Tables = $tables.ToArray(); Results = $all
        PullRequest = ($images.Count + $tables.Count) -gt 0 }
}

function Format-Failure($Result) {
    $text = ([string]$Result['error']).TrimEnd()
    if (-not $text) { $text = 'no output' }
    return @("**$($Result['port'])** failed. Neither of its images is replaced.", '', '```', $text, '```', '')
}

function New-DeliveryBody {
    <#
    .SYNOPSIS
        The rolling pull request's body: old and new images and the why line
        per changed port, the images whose stamp alone changed, the README tables added, failed ports with their
        step and last lines, manual ports, ports this workflow does not shoot
        yet, and the warning that hand edits are lost.
    .DESCRIPTION
        Old images link to Base (the main commit the branch is rebuilt from),
        new ones to Commit (the delivery commit). Results as from
        Copy-ShotDelivery; Images, Restamped and Tables as it returned them.
    #>
    param([object[]]$Results = @(), [string[]]$Images = @(), [string[]]$Restamped = @(), [string[]]$Tables = @(), [object[]]$Manual = @(), [object[]]$Skipped = @(),
        [Parameter(Mandatory)][string]$Repo, [Parameter(Mandatory)][string]$Base, [Parameter(Mandatory)][string]$Commit, [string]$RunUrl)
    $raw = { param($sha, $path) "https://github.com/$Repo/raw/$sha/$path" }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("Screenshots retaken after ``$($Base.Substring(0, [math]::Min(7, $Base.Length)))`` on ``main``. Every image shown below changed in its exact pixels, confirmed by a second take.")
    $lines.Add('')
    $lines.Add('> This branch is rebuilt from `main` and force-pushed on every run, so hand edits to it are lost. Fix a bad shot in the port, its recipe, or the Photographer on `main`.')
    $lines.Add('')
    foreach ($r in $Results) {
        $mine = @(foreach ($v in @($r['variants'].Keys)) { $p = "Ports/$($r['port'])/screenshots/$v.png"; if ($Images -contains $p) { @{ Variant = $v; Path = $p } } })
        if (-not $mine.Count) { continue }
        $lines.Add("## $($r['app'])"); $lines.Add('')
        $lines.Add("Why: $($r['why'])"); $lines.Add('')
        $lines.Add('| | Before | After |'); $lines.Add('|---|---|---|')
        foreach ($m in $mine) {
            $label = (Get-Culture).TextInfo.ToTitleCase($m.Variant)
            $before = if ($r['variants'][$m.Variant]['committed']) { "![$label before]($(& $raw $Base $m.Path))" } else { 'none' }
            $lines.Add("| $label | $before | ![$label after]($(& $raw $Commit $m.Path)) |")
        }
        $lines.Add('')
    }
    if ($Restamped.Count) {
        $lines.Add('## Stamp only'); $lines.Add('')
        $lines.Add('A retake matched these images exactly, so no pixel changed. Each gets the new fingerprint in its stamp, so it is no longer retaken every run. New stamps alone never open this pull request: they wait for a real change.'); $lines.Add('')
        foreach ($i in $Restamped) { $lines.Add("- ``$i``") }
        $lines.Add('')
    }
    if ($Tables.Count) {
        $lines.Add('## README tables added'); $lines.Add('')
        foreach ($t in $Tables) { $lines.Add("- ``Ports/$t/README.md``") }
        $lines.Add('')
    }
    $failed = @($Results | Where-Object { $_['status'] -eq 'failed' })
    if ($failed.Count) {
        $lines.Add('## Failed'); $lines.Add('')
        foreach ($r in $failed) { foreach ($l in Format-Failure $r) { $lines.Add($l) } }
    }
    if ($Manual.Count) {
        $lines.Add('## Shot by hand'); $lines.Add('')
        $lines.Add('These ports have a manual recipe and are stale. Each has a "Screenshots for <app>" issue that says how to retake them by hand and stamp them with `pwsh build/photograph.ps1 -Port <app>`.'); $lines.Add('')
        foreach ($m in $Manual) { $lines.Add("- ``$($m['port'])``: $($m['reason'])") }
        $lines.Add('')
    }
    if ($Skipped.Count) {
        $lines.Add('## Not shot by this workflow yet'); $lines.Add('')
        foreach ($s in $Skipped) { $lines.Add("- ``$($s['port'])`` ($($s['platform']))") }
        $lines.Add('')
    }
    if ($RunUrl) { $lines.Add("From [this run]($RunUrl).") }
    return ($lines -join "`n").TrimEnd() + "`n"
}

function New-DeliveryNote {
    <#
    .SYNOPSIS
        The comment that closes the rolling pull request when a run has
        nothing to deliver, naming any port that failed.
    #>
    param([object[]]$Results = @(), [string]$RunUrl)
    $note = 'Nothing to deliver: every retaken shot matches `main`, and every README has its table. Closing.'
    $failed = @($Results | Where-Object { $_['status'] -eq 'failed' } | ForEach-Object { "``$($_['port'])``" })
    if ($failed.Count) { $note += " Failed this run, so still stale: $($failed -join ', ')." }
    if ($RunUrl) { $note += " From [this run]($RunUrl)." }
    return $note
}

function ConvertTo-ShotSummary {
    <#
    .SYNOPSIS
        A port's lines in the run summary: its status, and for each variant
        whether the last take matches the committed shot, or how many pixels
        differ and by how much. A failed port shows its step and last lines.
    #>
    param([Parameter(Mandatory)]$Result)
    $lines = [System.Collections.Generic.List[string]]::new()
    $why = if ($Result['why']) { " ($($Result['why']))" } else { '' }
    $variant = if ($Result.Contains('variant') -and $Result['variant']) { ", $($Result['variant'])" } else { '' }
    if ($Result.Contains('take') -and $Result['take']) { $variant += ", take $($Result['take'])" }
    $lines.Add("### $($Result['app']) (``$($Result['port'])``$variant): $($Result['status'])$why")
    $lines.Add('')
    if ($Result['status'] -eq 'failed') { foreach ($l in Format-Failure $Result) { $lines.Add($l) } }
    foreach ($v in @($Result['variants'].Keys)) {
        $x = $Result['variants'][$v]
        $takes = "$($x['takes']) take$(if ($x['takes'] -ne 1) { 's' })"
        $c = $x['compare']
        $against = if (-not $x['committed'] -or $null -eq $c) { 'no committed shot' }
                   elseif ($c['same']) { 'matches the committed shot' }
                   elseif ($c['size']) { "differs from the committed shot in size: $($c['size'])" }
                   else { "$($c['differ']) pixels differ from the committed shot, by up to $($c['max_delta']) of 255" }
        $lines.Add("- ${v}: $($x['verdict']), $against ($takes)")
    }
    return ($lines -join "`n") + "`n"
}

# --- Manual ports: one "Screenshots for <app>" issue each, open while stale -------

function Get-IssueMarker([string]$Port, [string]$Fingerprint) {
    # Hidden in an issue's body or comment: which fingerprint it was written for.
    return "<!-- inglenook-screenshots $Port $Fingerprint -->"
}

function Get-ManualIssueText($Manual, [string]$DayName, [string]$NightName, $Backdrops) {
    # What a person needs to retake a manual port's shots, and the stamp step.
    # Backdrops: each variant's backdrop in words (Format-SceneBackdrop).
    $over = { param($v) if ($Backdrops -and $Backdrops[$v]) { $Backdrops[$v] } else { "the scene's $v backdrop" } }
    $port = $Manual['port']
    $setup = if ($Manual['scene']) { "set up as the $($Manual['kind']) scene staged in ``$($Manual['scene'])/``" }
             else { "set up like the other ports' shots (the $($Manual['kind']) scene has no staged content in ``build/photograph/scenes/`` yet)" }
    return @(
        "1. Take a screenshot of the app in **$DayName** over $(& $over 'day'), $setup. Save it as ``Ports/$port/screenshots/day.png``."
        "2. Do the same in **$NightName**, over $(& $over 'night'), and save it as ``Ports/$port/screenshots/night.png``."
        "3. Run ``pwsh build/photograph.ps1 -Port $port``. It stamps both images with the fingerprint of what they show and adds the screenshot table to the README."
        "4. Look at both, then commit them with the README in a pull request. This issue closes itself once the screenshots on ``main`` are fresh."
    )
}

function Get-ManualChange($Manual) {
    if (-not $Manual['shots']) { return 'It has no screenshots yet.' }
    return "Its screenshots are stale: $($Manual['why'])."
}

function Get-ManualIssueActions {
    <#
    .SYNOPSIS
        What the delivery job does to the "Screenshots for <app>" issues, as a
        list of @{ action; number; title; body }, in order. action is create,
        reopen, comment or close; the workflow runs each with gh.
    .DESCRIPTION
        Manual and Fresh are the plan's manual and manual_fresh lists. Issues
        is every issue as gh lists it (number, title, state, body, comments
        with their body). For each stale port, exactly one issue titled
        "Screenshots for <app>" is open: the oldest open one, or the newest
        closed one reopened, or a new one. Any other open one is closed as a
        duplicate. The kept issue gets one comment per new fingerprint, saying
        what changed: a hidden marker in the body or a comment records each
        fingerprint already told. For each fresh port, its open issues close.
    #>
    param([object[]]$Manual = @(), [object[]]$Fresh = @(), [object[]]$Issues = @(),
        [Parameter(Mandatory)][string]$DayName, [Parameter(Mandatory)][string]$NightName, $Backdrops, [string]$RunUrl)
    $from = if ($RunUrl) { " From [this run]($RunUrl)." } else { '' }
    $actions = [System.Collections.Generic.List[object]]::new()
    $add = { param($a, $n, $t, $b) $actions.Add([ordered]@{ action = $a; number = $n; title = $t; body = $b }) }
    $matching = { param($title) @($Issues | Where-Object { $_['title'] -ceq $title } | Sort-Object { [int]$_['number'] }) }
    $isOpen = { param($i) ([string]$i['state']) -eq 'open' }

    foreach ($m in $Manual) {
        $title = "Screenshots for $($m['app'])"
        $marker = Get-IssueMarker $m['port'] $m['fingerprint']
        $all = @(& $matching $title)
        $open = @($all | Where-Object { & $isOpen $_ })
        $keep = $null
        if ($open.Count) {
            $keep = $open[0]
            foreach ($d in @($open | Select-Object -Skip 1)) { & $add 'close' ([int]$d['number']) $title "Duplicate of #$($keep['number']), which tracks these screenshots." }
        }
        elseif ($all.Count) {
            $keep = $all[-1]
            & $add 'reopen' ([int]$keep['number']) $title ''
        }
        else {
            $body = @(
                "$($m['app'])'s screenshots are taken by hand: $($m['reason'])"
                ''
                (Get-ManualChange $m)
                ''
                (Get-ManualIssueText $m $DayName $NightName $Backdrops)
                ''
                "This issue stays open while the screenshots are stale, and gets a comment each time the port or the Photographer changes again.$from"
                ''
                $marker
            ) -join "`n"
            & $add 'create' $null $title $body
            continue
        }
        $told = @(@($keep['body']) + @(@($keep['comments']) | Where-Object { $_ } | ForEach-Object { $_['body'] }) | Where-Object { "$_".Contains($marker) })
        if ($told.Count) { continue }
        $body = @(
            "$(Get-ManualChange $m) Retake them:"
            ''
            (Get-ManualIssueText $m $DayName $NightName $Backdrops)
            ''
            "$from".Trim()
            ''
            $marker
        ) -join "`n"
        & $add 'comment' ([int]$keep['number']) $title $body
    }
    foreach ($f in $Fresh) {
        $title = "Screenshots for $($f['app'])"
        foreach ($i in @(& $matching $title | Where-Object { & $isOpen $_ })) {
            & $add 'close' ([int]$i['number']) $title "The screenshots on ``main`` are fresh. Closing.$from"
        }
    }
    return $actions.ToArray()
}

Export-ModuleMember -Function Get-ShotTargets, Read-ShotResults, Copy-ShotDelivery, New-DeliveryBody, New-DeliveryNote, ConvertTo-ShotSummary, Get-ManualIssueActions
