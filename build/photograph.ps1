#requires -Version 7.0
<#
.SYNOPSIS
    Takes a port's Day and Night screenshots in the real app: in Docker for a
    Linux port, on a GitHub-hosted runner for a Windows one.

.DESCRIPTION
    Reads the port's recipe (Ports/<app_name>/screenshot.json), builds the
    shared Linux base image from build/photograph/pins.json, then an image for
    the port with its install steps (and its host's) run as root. Each variant
    is shot in a fresh container as an ordinary user with the repo mounted
    read-only: the scene's display, compositor, window manager and backdrop,
    the recipe's apply, stage and launch steps, a wait for the window and for
    the screen to stay the same for a few seconds, then a crop of the window
    plus a 64 px margin of the same grab. A desktop recipe launches its own session instead, which
    brings its own window manager and compositor; the scene opens the file
    manager and the menu, and the crop is a fixed area at the bottom left.

    A Windows port is shot only on a GitHub-hosted Windows runner, since it
    changes system settings: build/photograph/windows/desktop.ps1 sets the
    scene's desktop (shadow, rounded corners, screen size, mode, backdrop,
    caret, font), the install steps run once, and each take runs
    build/photograph/windows/shoot.ps1, then the same crop. The screenshot
    workflow gives each Windows take a fresh job of its own (-Take), as a
    Linux take gets a fresh container.

    A take that differs from the committed shot, or has none to compare
    with, is taken again in a fresh container, and a third time if the two
    disagree (the take verdict in the rules module): exact pixels, no
    tolerance. A take that fails is tried once more.

    Writes Ports/<app_name>/screenshots/day.png and night.png, losslessly
    optimized and stamped with the fingerprint of their inputs, only when both
    variants succeed, and only the images whose pixels changed. An image a
    take matched exactly keeps its pixels and takes the new stamp if its
    fingerprint moved, so the port is no longer stale. Adds the Day
    and Night table to the port README if it is missing. Never commits.

    The preview has a shot list (Ports/preview/shots.json) instead of a
    recipe: its own bare page in the pinned Chromium, with no scene, frame or
    margin (build/photograph/linux/preview.py). Each shot is the top of the
    page or one page section, and any request the page makes that fails fails
    the variant. Every image is written as <name>.png, by the same take rules.

    With no -Port it shoots every stale port it can shoot here: one with no
    shots, or whose shots' fingerprint no longer matches its inputs. -All
    shoots every one. Elsewhere, Windows and macOS recipes are shot in GitHub
    Actions; for those it says so.

    A manual recipe is shot by hand. With -Port it shoots nothing: it stamps
    the hand-taken screenshots/day.png and night.png with the fingerprint and
    adds the README table, or says which image is missing. The rules (step order,
    scripts, crop, README table, pins, fingerprint, stale) live in
    build/lib/Photographer.psm1; PNG stamps and pixels in build/lib/Png.psm1.

.PARAMETER Port
    The port's folder name under Ports/. Shot even if it is not stale.

.PARAMETER All
    Shoot every Linux port, stale or not.

.PARAMETER Variant
    Shoot only this variant of -Port, for a workflow job per variant. Needs
    -Report, and writes nothing to Ports/: both variants or neither, so the
    screenshot workflow combines the two jobs.

.PARAMETER Take
    Shoot only this take (1 to 3) of -Variant, for a workflow job per take.
    Needs -Variant. Gives no verdict: the workflow reads the takes in order
    (Merge-ShotTakes in build/lib/ScreenshotRun.psm1). A take that fails is
    tried once more in the same job.

.PARAMETER Report
    A folder for the screenshot workflow: for each port, result.json (what
    happened, the why line, any failure) and the last take of each variant,
    with every take in takes/. With -Variant, result-<variant>.json instead;
    with -Take, result-<variant>-<take>.json and only takes/<variant>-<take>.png.

.EXAMPLE
    pwsh build/photograph.ps1 -Port gnome-terminal

.EXAMPLE
    pwsh build/photograph.ps1
#>
[CmdletBinding(DefaultParameterSetName = 'Stale')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Port')][string]$Port,
    [Parameter(Mandatory, ParameterSetName = 'All')][switch]$All,
    [Parameter(ParameterSetName = 'Port')][ValidateSet('day', 'night')][string]$Variant,
    [Parameter(ParameterSetName = 'Port')][ValidateRange(1, 3)][int]$Take,
    [string]$Report
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($m in 'Palette', 'Catalog', 'Png', 'Photographer') {
    Import-Module (Join-Path $PSScriptRoot 'lib' "$m.psm1") -Force
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
# Named apart: PowerShell names ignore case, and the shot loop's $variant would hide it.
$OnlyVariant = $Variant
if ($OnlyVariant -and -not $Report) { Write-Host '-Variant needs -Report: one variant alone is never written to Ports/.' -ForegroundColor Red; exit 1 }
$OnlyTake = $Take
if ($OnlyTake -and -not $OnlyVariant) { Write-Host '-Take needs -Variant: a take is of one variant.' -ForegroundColor Red; exit 1 }
if ($Report) { $Report = [System.IO.Path]::GetFullPath($Report); New-Item -ItemType Directory -Path $Report -Force | Out-Null }
$PhotoDir = Join-Path $PSScriptRoot 'photograph'
$PinsPath = Join-Path $PhotoDir 'pins.json'
# A hosted runner's image cannot be pinned: it is recorded in the stamp, outside the fingerprint.
$RunnerImage = if ($env:ImageOS) { "$env:ImageOS $env:ImageVersion".Trim() } else { 'local' }

# Image tags name their own content, so runs from other worktrees never swap an image under us.
function Get-ContentTag([string]$Name, [string]$Text) {
    return "${Name}:$((Get-Sha256 $Text).Substring(0, 12))"
}

function Stop-With([string]$Message) { Write-Host $Message -ForegroundColor Red; exit 1 }

# Windows takes change system settings (screen, mode, DWM), so they run only on a hosted runner.
$OnWindowsRunner = $IsWindows -and $env:GITHUB_ACTIONS -eq 'true' -and $env:RUNNER_ENVIRONMENT -eq 'github-hosted'
function Test-ShootsHere($Recipe) {
    switch ($Recipe['platform']) { 'linux' { return $true } 'windows' { return $OnWindowsRunner } default { return $false } }
}

$catalog = Get-PortCatalog -PortsRoot (Join-Path $RepoRoot 'Ports')
$palette = Read-Palette -Path (Join-Path $RepoRoot 'palette' 'palette.json')
$failed = [System.Collections.Generic.List[string]]::new()

function Add-ReadmeTable($Entry) {
    # The Day and Night table, once the port has its shots.
    $readmePath = Join-Path $Entry.Dir 'README.md'
    if (-not ((Test-Path (Join-Path $Entry.Dir 'screenshots' 'day.png')) -and (Test-Path $readmePath))) { return }
    $readme = [System.IO.File]::ReadAllText($readmePath)
    $updated = Add-ShotTable -Readme $readme -DayName $palette.Variants['day'].Name -NightName $palette.Variants['night'].Name
    if ($updated -cne $readme) {
        [System.IO.File]::WriteAllText($readmePath, $updated)
        Write-Host "Added the Day and Night table to Ports/$($Entry.Name)/README.md"
    }
}

function Invoke-ManualStamp($Entry) {
    # A manual recipe: stamp the hand-taken shots with the fingerprint, both or neither.
    $name = $Entry.Name
    $recipe = $Entry.Recipe
    $shotDir = Join-Path $Entry.Dir 'screenshots'
    $missing = @(foreach ($v in 'day', 'night') { if (-not (Test-Path -LiteralPath (Join-Path $shotDir "$v.png") -PathType Leaf)) { "$v.png" } })
    if ($missing.Count) {
        $scene = "build/photograph/scenes/$(Get-SceneFolder $recipe['kind'])"
        Write-Host "$name has a manual recipe, so its screenshots are taken by hand: $($recipe['manual'])" -ForegroundColor Red
        Write-Host "Ports/$name/screenshots/ has no $($missing -join ' or ') yet. Take both variants by hand to the $($recipe['kind']) scene:" -ForegroundColor Red
        Write-Host "  - the content staged in $scene$(if (-not (Test-Path (Join-Path $RepoRoot $scene))) { ' (not written yet: match the other ports'' shots)' })"
        foreach ($v in 'day', 'night') {
            Write-Host "  - $($palette.Variants[$v].Name) over $(Format-SceneBackdrop (Get-SceneBackdrop -RepoRoot $RepoRoot -Variant $v)), saved as Ports/$name/screenshots/$v.png"
        }
        Write-Host "Then run this again to stamp them and add the README table."
        exit 1
    }
    foreach ($v in 'day', 'night') {
        try { $null = Read-ShotStamp -Path (Join-Path $shotDir "$v.png") }
        catch { Stop-With "Ports/$name/screenshots/$v.png is not a PNG. Save the screenshot as PNG, then run this again." }
    }
    $fingerprint = Get-ShotFingerprint -RepoRoot $RepoRoot -Port $name -Recipe $recipe
    $fresh = -not (Test-ShotStale -Dir $shotDir -Fingerprint $fingerprint.Fingerprint)
    $stamp = New-ManualShotStamp -Fingerprint $fingerprint
    foreach ($v in 'day', 'night') { Write-ShotStamp -Path (Join-Path $shotDir "$v.png") -Stamp $stamp }
    Write-Host $(if ($fresh) { "Ports/$name/screenshots/day.png and night.png were already stamped with the current fingerprint." }
                 else { "Stamped Ports/$name/screenshots/day.png and night.png with the current fingerprint. They are fresh until the port or the Photographer changes." })
    Add-ReadmeTable $Entry
    Write-Host 'Look at both shots, then commit them with the README.'
}

# Which ports to shoot.
$targets = [System.Collections.Generic.List[object]]::new()
if ($Port) {
    $entry = $catalog.Ports | Where-Object Name -eq $Port
    if (-not $entry) { Stop-With "No port named '$Port' in Ports/." }
    foreach ($e in $catalog.RecipeErrors) { if ($e -like "Ports/$Port/*") { Stop-With $e } }
    $recipe = $entry.Recipe
    if ($entry.Shots) { $recipe = @{ platform = 'linux' } }
    if ($entry.Shots -and $OnlyVariant) { Stop-With "Ports/$Port has a shot list: it is shot in one job, without -Variant." }
    if (-not $recipe) { Stop-With "Ports/$Port/screenshot.json does not exist. Write the port's recipe first (CONTRIBUTING.md, Add a port)." }
    if ($recipe.Contains('manual')) { Invoke-ManualStamp $entry; exit 0 }
    if (-not (Test-ShootsHere $recipe)) { Write-Host "$Port is shot on $($recipe['platform']): shoot this in Actions."; exit 0 }
    $targets.Add($entry)
}
else {
    foreach ($e in $catalog.RecipeErrors) { Write-Host $e -ForegroundColor Red; $failed.Add(($e -split '/')[1]) }
    foreach ($entry in @($catalog.Ports | Where-Object Shots | Sort-Object Name)) {
        $fingerprint = Get-PreviewFingerprint -RepoRoot $RepoRoot -Port $entry.Name
        $names = @($entry.Shots | ForEach-Object { $_['name'] })
        if ($All -or (Test-ShotStale -Dir (Join-Path $entry.Dir 'screenshots') -Fingerprint $fingerprint.Fingerprint -Names $names)) { $targets.Add($entry) }
        else { Write-Host "$($entry.Name): fresh." }
    }
    foreach ($entry in @($catalog.Ports | Where-Object Recipe | Sort-Object Name)) {
        $recipe = $entry.Recipe
        if ($recipe.Contains('manual')) { Write-Host "$($entry.Name): manual recipe. Take its screenshots by hand, then stamp them with -Port $($entry.Name)."; continue }
        if (-not (Test-ShootsHere $recipe)) { Write-Host "$($entry.Name): shot on $($recipe['platform']), shoot this in Actions."; continue }
        $fingerprint = Get-ShotFingerprint -RepoRoot $RepoRoot -Port $entry.Name -Recipe $recipe
        if ($All -or (Test-ShotStale -Dir (Join-Path $entry.Dir 'screenshots') -Fingerprint $fingerprint.Fingerprint)) { $targets.Add($entry) }
        else { Write-Host "$($entry.Name): fresh." }
    }
    if (-not $targets.Count) {
        Write-Host $(if ($All) { 'No port to shoot here.' } else { 'No stale port to shoot here.' })
        exit $(if ($failed.Count) { 1 } else { 0 })
    }
    Write-Host "To shoot: $(@($targets | ForEach-Object Name) -join ', ')"
}

$needsDocker = @($targets | Where-Object { $_.Shots -or $_.Recipe['platform'] -eq 'linux' }).Count -gt 0
if ($needsDocker -and -not (Get-Command docker -ErrorAction SilentlyContinue)) { Stop-With 'Docker is not installed or not on PATH.' }

function Invoke-Docker([string]$What, [string[]]$Arguments) {
    $out = & docker @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        $tail = @($out | ForEach-Object { "$_" } | Select-Object -Last 30) -join "`n"
        throw "$What failed:`n$tail"
    }
    return $out
}

function Get-AppName($Entry) {
    if ($Entry -and $Entry.Meta -and $Entry.Meta['name']) { return [string]$Entry.Meta['name'] }
    return [string]$Entry.Name
}

function Write-PortReport([string]$Name, $Entry, [string]$Status, [string]$Why = '', [string]$Failure = '', $Variants = [ordered]@{}) {
    # For the screenshot workflow: what happened to one port, beside its last takes.
    # One variant's job writes its own part, which the workflow merges.
    $dir = Join-Path $Report $Name
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $result = [ordered]@{ port = $Name; app = (Get-AppName $Entry) }
    if ($OnlyVariant) { $result.variant = $OnlyVariant }
    if ($OnlyTake) { $result.take = $OnlyTake }
    $result += [ordered]@{ status = $Status; why = $Why; error = $Failure; variants = $Variants }
    $file = if ($OnlyTake) { "result-$OnlyVariant-$OnlyTake.json" } elseif ($OnlyVariant) { "result-$OnlyVariant.json" } else { 'result.json' }
    Set-Content -Path (Join-Path $dir $file) -Value (ConvertTo-Json -InputObject $result -Depth 6)
}

function Write-StampOnly([string]$Name, $Images, [string]$ShotDir) {
    # An unchanged image takes its last take's stamp if its fingerprint moved, so
    # the port is fresh again. Its pixels stay as they are.
    foreach ($n in $Images.Keys) {
        $x = $Images[$n]
        if ($x.verdict -ne 'unchanged') { continue }
        if (Update-ShotStamp -Committed (Join-Path $ShotDir "$n.png") -Take $x.last) { Write-Host "Restamped Ports/$Name/screenshots/$n.png (no pixel changed)" }
    }
}

function Invoke-LinuxTake {
    # One take of one variant in a fresh container. Returns the stamped, cropped shot.
    param([string]$Name, [string]$Image, $Plan, [string]$Variant, [string]$Work, [int]$Number, [string]$RecipeFile, $Stamp)
    # Its own folder, even when a failed take is tried again.
    $take = Join-Path $Work "$Variant-$Number-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    New-Item -ItemType Directory -Path $take | Out-Null
    if (-not $IsWindows) { & chmod 777 $take }
    Set-Content -Path (Join-Path $take 'steps.sh') -NoNewline -Value (
        ConvertTo-StepScript -Steps $Plan.Shot -Kind $Plan.Kind -Variant $Variant -RepoRoot '/inglenook')
    $envLines = Get-SceneEnv -Plan $Plan -Variant $Variant -RecipeFile $RecipeFile -Backdrop (Get-SceneBackdrop -RepoRoot $RepoRoot -Variant $Variant)
    Set-Content -Path (Join-Path $take 'scene.env') -Value @(foreach ($k in $envLines.Keys) {
        "export $k='$(([string]$envLines[$k]).Replace("'", "'\''"))'"
    })

    Write-Host "Shooting $Name ($Variant), take $Number..."
    # A desktop's file manager shows a staged folder on a fixed-size tmpfs, so its free space never moves.
    $sceneDisk = if ($Plan.Kind -eq 'desktop') { @('--tmpfs', '/scene:size=64m,mode=1777') } else { @() }
    # Root only drops the files that mark a container (Docker's, and the base image's
    # for systemd), so apps act as on a desktop: Starship would show [Docker]. The take
    # itself runs as the ordinary user.
    $out = Invoke-Docker "Shooting $Name ($Variant)" (@('run', '--rm', '--user', 'root') + $sceneDisk + @(
        '-v', "${RepoRoot}:/inglenook:ro", '-v', "${take}:/work", $Image, 'bash', '-c',
        'rm -f /.dockerenv /run/systemd/container && exec runuser -u shooter -- bash /inglenook/build/photograph/linux/shoot.sh'))
    Write-Host "  $(@($out)[-1])"

    $frame = $null
    if ($Plan.Window) {
        $f = @{}
        foreach ($line in Get-Content (Join-Path $take 'frame.env')) { $k, $v = $line -split '=', 2; $f[$k] = [int]$v }
        $frame = @{ X = $f.X; Y = $f.Y; Width = $f.WIDTH; Height = $f.HEIGHT }
    }
    $crop = Get-ShotCrop -Kind $Plan.Kind -Frame $frame
    $geometry = "$($crop.Width)x$($crop.Height)+$($crop.X)+$($crop.Y)"
    # Lossless only: the crop, then optipng.
    $null = Invoke-Docker "Cropping $Variant" @('run', '--rm', '--user', 'shooter', '-v', "${take}:/work", $Image, 'bash', '-euo', 'pipefail', '-c',
        "convert /work/root.png -crop $geometry +repage -strip -define png:exclude-chunks=date,time /work/shot.png && optipng -quiet -o2 /work/shot.png")
    # A copy of our own: the container's user owns shot.png.
    $shot = "$take.png"
    Copy-Item -Path (Join-Path $take 'shot.png') -Destination $shot
    Write-ShotStamp -Path $shot -Stamp $Stamp
    return $shot
}

function Initialize-WindowsJob([string]$Name, $Plan, [string]$Work) {
    # Once per job: the recipe's install steps, as the runner's admin user.
    Write-Host "Running the install steps of Ports/$Name/screenshot.json..."
    $script = Join-Path $Work 'install.ps1'
    Set-Content -Path $script -Value (ConvertTo-WindowsStepScript -Steps $Plan.Install -Kind $Plan.Kind -RepoRoot $RepoRoot -Logs $Work)
    $out = @(& pwsh -NoProfile -NonInteractive -File $script 2>&1 | ForEach-Object { "$_" })
    if ($LASTEXITCODE -ne 0) { throw ($out -join "`n") }
}

function Initialize-WindowsDesktop($Plan, [string]$Variant, [string]$RecipeFile, [string]$Work) {
    Write-Host "Setting the Windows desktop for $Variant..."
    $pins = Read-JsonFile $PinsPath
    $scene = Get-SceneEnv -Plan $Plan -Variant $Variant -RecipeFile $RecipeFile -Backdrop (Get-SceneBackdrop -RepoRoot $RepoRoot -Variant $Variant)
    & (Join-Path $PhotoDir 'windows' 'desktop.ps1') -Scene $scene -RepoRoot $RepoRoot -Font $pins['font'] -Work $Work
}

function Invoke-WindowsTake {
    # One take of one variant on this hosted runner. Returns the stamped, cropped shot.
    param([string]$Name, $Plan, [string]$Variant, [string]$Work, [int]$Number, [string]$RecipeFile, $Stamp)
    $take = Join-Path $Work "$Variant-$Number-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    New-Item -ItemType Directory -Path $take | Out-Null
    Set-Content -Path (Join-Path $take 'steps.ps1') -Value (
        ConvertTo-WindowsStepScript -Steps $Plan.Shot -Kind $Plan.Kind -Variant $Variant -RepoRoot $RepoRoot -Logs $take)
    $scene = Get-SceneEnv -Plan $Plan -Variant $Variant -RecipeFile $RecipeFile -Backdrop (Get-SceneBackdrop -RepoRoot $RepoRoot -Variant $Variant)
    Write-Host "Shooting $Name ($Variant), take $Number..."
    $out = & (Join-Path $PhotoDir 'windows' 'shoot.ps1') -Scene $scene -Work $take
    Write-Host "  $(@($out)[-1])"
    $f = Read-JsonFile (Join-Path $take 'frame.json')
    $crop = Get-ShotCrop -Kind $Plan.Kind -Frame $f -Platform 'windows'
    $shot = "$take.png"
    Export-ShotCrop -Path (Join-Path $take 'root.png') -Crop $crop -Out $shot
    Write-ShotStamp -Path $shot -Stamp $Stamp
    return $shot
}

function Invoke-PortShot($Entry, [string]$BaseImage) {
    $name = $Entry.Name
    $recipe = $Entry.Recipe
    $recipeFile = "Ports/$name/screenshot.json"
    $hostName = $null; $hostRecipe = $null
    if ($recipe.Contains('host')) {
        $hostName = $recipe['host']
        $hostRecipe = ($catalog.Ports | Where-Object Name -eq $hostName).Recipe
    }
    $plan = Get-ShotPlan -Port $name -Recipe $recipe -HostPort $hostName -HostRecipe $hostRecipe
    # Taken before the shot, from the files the shot is made from.
    $fingerprint = Get-ShotFingerprint -RepoRoot $RepoRoot -Port $name -Recipe $recipe
    $stamp = New-ShotStamp -Fingerprint $fingerprint -Recipe $recipe -HostRecipe $hostRecipe -PinsPath $PinsPath -RunnerImage $RunnerImage

    $work = Join-Path ([System.IO.Path]::GetTempPath()) ("inglenook-photograph-$name-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $windows = $plan.Platform -eq 'windows'
        if ($windows) { Initialize-WindowsJob -Name $name -Plan $plan -Work $work }
        else {
            $portFile = ConvertTo-PortDockerfile -Base $BaseImage -Steps $plan.Install
            $image = Get-ContentTag "inglenook-photograph-$name" $portFile
            $ctx = Join-Path $work 'image'
            New-Item -ItemType Directory -Path $ctx | Out-Null
            Set-Content -Path (Join-Path $ctx 'Dockerfile') -Value $portFile -NoNewline
            Write-Host "Building $image with the install steps of $recipeFile..."
            $null = Invoke-Docker "The install steps of $recipeFile" @('build', '-q', '-t', $image, $ctx)
        }

        $shotDir = Join-Path $Entry.Dir 'screenshots'
        $variants = [ordered]@{}
        foreach ($variant in $(if ($OnlyVariant) { @($OnlyVariant) } else { @('day', 'night') })) {
            if ($windows) { Initialize-WindowsDesktop -Plan $plan -Variant $variant -RecipeFile $recipeFile -Work $work }
            $committed = Join-Path $shotDir "$variant.png"
            if (-not (Test-Path -LiteralPath $committed -PathType Leaf)) { $committed = $null }
            # A take that differs from the committed shot is confirmed by another, each in a
            # fresh container. A take that fails is tried once more.
            $takes = [System.Collections.Generic.List[string]]::new()
            $failures = 0
            while ($true) {
                $number = if ($OnlyTake) { $OnlyTake } else { $takes.Count + 1 }
                try {
                    $takes.Add($(if ($windows) { Invoke-WindowsTake -Name $name -Plan $plan -Variant $variant -Work $work -Number $number -RecipeFile $recipeFile -Stamp $stamp }
                                 else { Invoke-LinuxTake -Name $name -Image $image -Plan $plan -Variant $variant -Work $work -Number $number -RecipeFile $recipeFile -Stamp $stamp }))
                }
                catch {
                    $failures++
                    if ($failures -gt 1) { throw }
                    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
                    Write-Host "  Trying $name ($variant) once more in a fresh $(if ($windows) { 'take' } else { 'container' })..."
                    continue
                }
                # One take of a job per take: the workflow gives the verdict.
                if ($OnlyTake) { $verdict = [pscustomobject]@{ Verdict = 'shot'; Shot = $null }; break }
                $verdict = Get-TakeVerdict -Committed $committed -Takes $takes.ToArray()
                if ($verdict.Verdict -ne 'retake') { break }
                Write-Host "  $(if ($takes.Count -gt 1) { 'The takes disagree: taking a third' } elseif ($committed) { 'Differs from the committed shot: taking it again to confirm' } else { 'No committed shot: taking it again to confirm' })."
            }
            if ($verdict.Verdict -eq 'failed') {
                throw "Shooting $name ($variant) failed: three takes differ from each other and from the committed shot. Something in the scene changes between takes."
            }
            $compare = if ($committed) { Compare-ShotPixels -Path $takes[-1] -Other $committed } else { $null }
            Write-Host $(if ($OnlyTake) { "  $variant`: take $OnlyTake shot" } else { "  $variant`: $($verdict.Verdict) after $($takes.Count) take$(if ($takes.Count -ne 1) { 's' })" })
            $variants[$variant] = [ordered]@{
                verdict = $verdict.Verdict; takes = $takes.Count; committed = [bool]$committed; last = $takes[-1]; all = $takes.ToArray(); shot = $verdict.Shot
                compare = if ($compare) { [ordered]@{ same = $compare.Same; differ = $compare.Differ; max_delta = $compare.MaxDelta; size = $compare.Size } } else { $null }
            }
        }

        # Both variants or neither: only now, with both shot, does anything reach the repo.
        # Only images whose exact pixels changed are written; an unchanged one may get the new
        # stamp (Write-StampOnly). One variant alone is only reported.
        $changed = @(foreach ($v in $variants.Keys) { if ($variants[$v].verdict -eq 'changed') { $v } })
        # A take alone cannot tell if it changed: its why is kept for the workflow's verdict.
        if ($OnlyTake) { $changed = @($OnlyVariant) }
        $why = ''
        if ($changed.Count) {
            $old = $null
            $first = Join-Path $shotDir "$($changed[0]).png"
            if (Test-Path -LiteralPath $first) { $old = Read-ShotStamp -Path $first; if ($null -eq $old) { $old = @{} } }
            $why = Get-ShotWhy -Old $old -New $stamp -App (Get-AppName $Entry) -HostApp $(if ($hostName) { Get-AppName ($catalog.Ports | Where-Object Name -eq $hostName) } else { 'host' })
        }
        if ($OnlyTake) { Write-Host "$name ($OnlyVariant, take $OnlyTake): reported only; the workflow gives the take verdict." }
        elseif ($OnlyVariant) { Write-Host "$name ($OnlyVariant): reported only; the workflow combines both variants." }
        else {
            New-Item -ItemType Directory -Path $shotDir -Force | Out-Null
            foreach ($v in $changed) {
                Copy-Item -Path $variants[$v].shot -Destination (Join-Path $shotDir "$v.png") -Force
                Write-Host "Wrote Ports/$name/screenshots/$v.png ($why)"
            }
            Write-StampOnly -Name $name -Images $variants -ShotDir $shotDir
            if (-not $changed.Count) { Write-Host "$name`: no pixel changed." }
        }
        if (-not $OnlyVariant) { Add-ReadmeTable $Entry }

        if ($Report) {
            $dir = Join-Path $Report $name
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $out = [ordered]@{}
            foreach ($v in $variants.Keys) {
                # Every take, for when takes disagree. A job per take leaves its own take only,
                # so the jobs' files never collide.
                New-Item -ItemType Directory -Path (Join-Path $dir 'takes') -Force | Out-Null
                $x = $variants[$v]
                if ($OnlyTake) { Copy-Item -Path $x.last -Destination (Join-Path $dir 'takes' "$v-$OnlyTake.png") -Force }
                else {
                    Copy-Item -Path $x.last -Destination (Join-Path $dir "$v.png") -Force
                    $n = 0
                    foreach ($t in $x.all) { $n++; Copy-Item -Path $t -Destination (Join-Path $dir 'takes' "$v-$n.png") -Force }
                }
                $out[$v] = [ordered]@{ verdict = $x.verdict; takes = $x.takes; committed = $x.committed; compare = $x.compare }
                if ($OnlyTake) { $out[$v].take = $OnlyTake }
            }
            $status = if ($OnlyTake) { 'shot' } elseif ($changed.Count) { 'changed' } else { 'unchanged' }
            Write-PortReport -Name $name -Entry $Entry -Status $status -Why $why -Variants $out
        }
    }
    finally {
        Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-PreviewTake {
    # One take of one variant of a shot list, in a fresh container: the bare page in
    # the pinned Chromium. Returns @{ <name> = <stamped shot> }.
    param([string]$Name, [string]$Image, [string]$Variant, [object[]]$Shots, [string]$Work, [int]$Number, $Stamp)
    $take = Join-Path $Work "$Variant-$Number-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    New-Item -ItemType Directory -Path $take | Out-Null
    if (-not $IsWindows) { & chmod 777 $take }
    $mine = @($Shots | Where-Object { $_['variant'] -eq $Variant } | ForEach-Object { [ordered]@{ name = $_['name']; show = $_['show'] } })
    Set-Content -Path (Join-Path $take 'shots.json') -Value (ConvertTo-Json -InputObject @($mine) -Compress)
    Write-Host "Shooting $Name ($Variant), take $Number..."
    # Lossless only, as for a port: the grab as Chromium drew it, then optipng.
    $script = 'python3 /inglenook/build/photograph/linux/preview.py && cd /work && for f in ' + (@($mine | ForEach-Object { "$($_['name']).png" }) -join ' ') +
        '; do convert "$f" -strip -define png:exclude-chunks=date,time "shot-$f" && optipng -quiet -o2 "shot-$f"; done'
    $out = Invoke-Docker "Shooting $Name ($Variant)" @('run', '--rm', '--user', 'shooter', '-e', "INGLENOOK_VARIANT=$Variant",
        '-v', "${RepoRoot}:/inglenook:ro", '-v', "${take}:/work", $Image, 'bash', '-euo', 'pipefail', '-c', $script)
    foreach ($line in @($out)) { if ("$line" -match '^\S+: (top|section)') { Write-Host "  $line" } }
    $taken = [ordered]@{}
    foreach ($s in $mine) {
        $shot = "$take-$($s['name']).png"
        Copy-Item -Path (Join-Path $take "shot-$($s['name']).png") -Destination $shot
        Write-ShotStamp -Path $shot -Stamp $Stamp
        $taken[$s['name']] = $shot
    }
    return $taken
}

function Invoke-PreviewShot($Entry, [string]$BaseImage) {
    # A shot list (the preview): every image of a variant comes from one take, and a
    # take is repeated until every image has its verdict, as for a port's two.
    $name = $Entry.Name
    $shots = @($Entry.Shots)
    $fingerprint = Get-PreviewFingerprint -RepoRoot $RepoRoot -Port $name
    $stamp = New-ShotStamp -Fingerprint $fingerprint -Recipe @{} -PinsPath $PinsPath -RunnerImage $RunnerImage
    $shotDir = Join-Path $Entry.Dir 'screenshots'
    $work = Join-Path ([System.IO.Path]::GetTempPath()) ("inglenook-photograph-$name-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $images = [ordered]@{}
        foreach ($variant in 'day', 'night') {
            $names = @($shots | Where-Object { $_['variant'] -eq $variant } | ForEach-Object { $_['name'] })
            $takes = @{}; $verdicts = @{}; $committed = @{}
            foreach ($n in $names) {
                $takes[$n] = [System.Collections.Generic.List[string]]::new()
                $c = Join-Path $shotDir "$n.png"
                $committed[$n] = if (Test-Path -LiteralPath $c -PathType Leaf) { $c } else { $null }
            }
            $failures = 0; $number = 0
            while ($true) {
                $number++
                try { $take = Invoke-PreviewTake -Name $name -Image $BaseImage -Variant $variant -Shots $shots -Work $work -Number $number -Stamp $stamp }
                catch {
                    $failures++
                    if ($failures -gt 1) { throw }
                    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
                    Write-Host "  Trying $name ($variant) once more in a fresh container..."
                    continue
                }
                $open = @()
                foreach ($n in $names) {
                    if ($verdicts.ContainsKey($n)) { continue }
                    $takes[$n].Add($take[$n])
                    $v = Get-TakeVerdict -Committed $committed[$n] -Takes $takes[$n].ToArray()
                    if ($v.Verdict -eq 'retake') { $open += $n } else { $verdicts[$n] = $v }
                }
                if (-not $open.Count) { break }
                Write-Host "  Not settled yet: $($open -join ', '). Taking it again to confirm."
            }
            foreach ($n in $names) {
                $v = $verdicts[$n]
                if ($v.Verdict -eq 'failed') {
                    throw "Shooting $name ($variant) failed: three takes of $n.png differ from each other and from the committed shot. Something on the page changes between takes."
                }
                $last = $takes[$n][-1]
                $compare = if ($committed[$n]) { Compare-ShotPixels -Path $last -Other $committed[$n] } else { $null }
                Write-Host "  $n`: $($v.Verdict) after $($takes[$n].Count) take$(if ($takes[$n].Count -ne 1) { 's' })"
                $images[$n] = [ordered]@{
                    verdict = $v.Verdict; takes = $takes[$n].Count; committed = [bool]$committed[$n]; last = $last; shot = $v.Shot
                    compare = if ($compare) { [ordered]@{ same = $compare.Same; differ = $compare.Differ; max_delta = $compare.MaxDelta; size = $compare.Size } } else { $null }
                }
            }
        }

        # Both variants or neither: only with every image shot does anything reach the repo.
        $changed = @(foreach ($n in $images.Keys) { if ($images[$n].verdict -eq 'changed') { $n } })
        $why = ''
        if ($changed.Count) {
            $first = Join-Path $shotDir "$($changed[0]).png"
            $old = $null
            if (Test-Path -LiteralPath $first) { $old = Read-ShotStamp -Path $first; if ($null -eq $old) { $old = @{} } }
            $why = Get-ShotWhy -Old $old -New $stamp -App (Get-AppName $Entry)
            New-Item -ItemType Directory -Path $shotDir -Force | Out-Null
            foreach ($n in $changed) {
                Copy-Item -Path $images[$n].shot -Destination (Join-Path $shotDir "$n.png") -Force
                Write-Host "Wrote Ports/$name/screenshots/$n.png ($why)"
            }
        }
        Write-StampOnly -Name $name -Images $images -ShotDir $shotDir
        if (-not $changed.Count) { Write-Host "$name`: no pixel changed." }

        if ($Report) {
            $dir = Join-Path $Report $name
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $out = [ordered]@{}
            foreach ($n in $images.Keys) {
                Copy-Item -Path $images[$n].last -Destination (Join-Path $dir "$n.png") -Force
                $x = $images[$n]
                $out[$n] = [ordered]@{ verdict = $x.verdict; takes = $x.takes; committed = $x.committed; compare = $x.compare }
            }
            Write-PortReport -Name $name -Entry $Entry -Status $(if ($changed.Count) { 'changed' } else { 'unchanged' }) -Why $why -Variants $out
        }
    }
    finally {
        Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# The shared base, once. Docker's cache makes it quick after the first run.
$baseImage = ''
if ($needsDocker) { try {
    $baseArgs = @(Get-BaseBuildArgs -Path $PinsPath)
    # The tag covers the Dockerfile and the script it copies in.
    $baseFile = @('Dockerfile', 'install-resvg.sh' | ForEach-Object { [System.IO.File]::ReadAllText((Join-Path $PhotoDir 'linux' $_)) }) -join "`n"
    $baseImage = Get-ContentTag 'inglenook-photograph-base' ((@($baseFile) + $baseArgs) -join "`n")
    Write-Host "Building the base image ($baseImage)..."
    $buildArgs = @(foreach ($a in $baseArgs) { '--build-arg'; $a })
    $null = Invoke-Docker 'Building the base image' (@('build', '-q', '-t', $baseImage) + $buildArgs + @((Join-Path $PhotoDir 'linux')))
}
catch {
    if ($Report) { foreach ($entry in $targets) { Write-PortReport -Name $entry.Name -Entry $entry -Status 'failed' -Failure $_.Exception.Message } }
    Stop-With $_.Exception.Message
} }

foreach ($entry in $targets) {
    # A failed port keeps its old shots; the others still get theirs.
    try {
        if ($entry.Shots) { Invoke-PreviewShot -Entry $entry -BaseImage $baseImage }
        else { Invoke-PortShot -Entry $entry -BaseImage $baseImage }
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        $failed.Add($entry.Name)
        if ($Report) { Write-PortReport -Name $entry.Name -Entry $entry -Status 'failed' -Failure $_.Exception.Message }
    }
}
if ($failed.Count) { Stop-With "Failed: $(@($failed | Sort-Object -Unique) -join ', ')." }
Write-Host 'Done. Look at every new shot before committing it.'
