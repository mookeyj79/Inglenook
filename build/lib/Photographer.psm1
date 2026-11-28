# The Photographer's rules: what runs in which order, how a shot is framed, what
# its fingerprint is made from, and what its takes say. No Docker, no network, no
# app: it reads and hashes repo files and compares PNGs, and photograph.ps1, the
# thin shell around it, runs the takes.

Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'Palette.psm1')
Import-Module (Join-Path $PSScriptRoot 'Build.psm1')
Import-Module (Join-Path $PSScriptRoot 'Catalog.psm1')
Import-Module (Join-Path $PSScriptRoot 'Png.psm1')

# What every shot shares. No recipe can change these (the recipe format, #43).
# The screen per platform: on Windows, a size the hosted runner offers (it has no 1600x1000).
$Screens = @{ linux = @{ Width = 1600; Height = 1000 }; windows = @{ Width = 1920; Height = 1080 } }
$Margin = 64
$DesktopCrop = @{ Width = 1000; Height = 625 }
$WindowTimeout = 60   # seconds to find the window, then again to settle
# A window scene is settled when the screen stays the same for this long. Two equal
# grabs 300 ms apart were not enough: Claude Code changes its footer 4 to 6 s after
# its window appears. (A desktop keeps two equal grabs: its panel clock must not
# reach the next minute.)
$SettleSeconds = 8
$Clock = '2026-06-01 09:41:00'   # what any clock in the scene shows (a desktop's panel)
# The backdrop behind every shot of a variant: the file name of a wallpaper in
# wallpapers/, shown as it is, or a palette neutral laid down as a plain fill. Every
# port is shot on the same wallpaper pair, the one the preview site shows. Mode is the
# app and system mode the variant asks for (the stock frame's, and Windows').
$Variants = [ordered]@{
    day   = @{ Backdrop = 'cabin-seating.jpg'; GtkTheme = 'Adwaita'; FrameTheme = 'Adwaita'; Mode = 'light' }
    night = @{ Backdrop = 'mission-fireplace.jpg'; GtkTheme = 'Adwaita:dark'; FrameTheme = 'Adwaita-dark'; Mode = 'dark' }
}

function Get-SceneBackdrop {
    <#
    .SYNOPSIS
        What is behind every shot of a variant. Returns @{ Kind; Name; Value }.
    .DESCRIPTION
        Kind 'fill': Name is a palette neutral, Value its hex in that variant.
        Kind 'image': Name is a file in wallpapers/, Value its repo path.
        -Backdrop names another backdrop than the Photographer's own, for tests.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][ValidateSet('day', 'night')][string]$Variant, [string]$Backdrop)
    $name = if ($Backdrop) { $Backdrop } else { $Variants[$Variant].Backdrop }
    if ($name -match '\.(jpe?g|png|webp)$') {
        $path = "wallpapers/$name"
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $path) -PathType Leaf)) { throw "The $Variant backdrop $path does not exist." }
        return [pscustomobject]@{ Kind = 'image'; Name = $name; Value = $path }
    }
    $palette = Read-Palette -Path (Join-Path $RepoRoot 'palette' 'palette.json')
    if ($palette.Errors.Count) { throw "palette/palette.json has errors, so the $Variant backdrop has no color. Run build/check.ps1." }
    $entry = Get-PaletteEntry $palette.Variants[$Variant] $name
    if ($null -eq $entry -or $entry.Kind -ne 'neutral') { throw "The $Variant backdrop '$name' is not a palette neutral." }
    return [pscustomobject]@{ Kind = 'fill'; Name = $name; Value = $entry.Hex }
}

function Format-SceneBackdrop($Backdrop) {
    # The backdrop in words, for the steps of a hand-taken shot.
    if ($Backdrop.Kind -eq 'image') { return $Backdrop.Value }
    return "a plain $($Backdrop.Value) fill ($($Backdrop.Name))"
}

# A kind shot in another kind's scene, unchanged: its folder in build/photograph/scenes/.
# An icon theme is shown in the Explorer of the editor scene.
$SceneFolders = @{ 'icon-theme' = 'editor' }

function Get-SceneFolder([string]$Kind) {
    if ($SceneFolders.ContainsKey($Kind)) { return $SceneFolders[$Kind] }
    return $Kind
}

# --- Scene folders: what is shared and what is one port's own ---------------------
# In build/photograph/scenes/<folder>/, a subfolder named exactly after a port (a
# Ports/<name>/ with a screenshot.json) is that port's own. Every other file and folder
# is shared by every port shot in that folder. A port's scene input is the shared part
# plus its own folder, so one port's scene changes no other port's fingerprint.

function Get-RecipePortNames([string]$RepoRoot) {
    # The folder names under Ports/ that hold a recipe: the names an own scene folder can have.
    $ports = Join-Path $RepoRoot 'Ports'
    if (-not (Test-Path -LiteralPath $ports -PathType Container)) { return @() }
    return @(Get-ChildItem -LiteralPath $ports -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'screenshot.json') -PathType Leaf } |
             ForEach-Object Name | Sort-Object)
}

function Get-SceneInput {
    <#
    .SYNOPSIS
        Which files of build/photograph/scenes/ a port's shots are made from.
        Returns @{ Folder; Exclude }: the repo path of its scene folder, and the
        own folders of the other ports in it, which are left out.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Port, [Parameter(Mandatory)][string]$Kind)
    $folder = "build/photograph/scenes/$(Get-SceneFolder $Kind)"
    $full = Join-Path $RepoRoot $folder
    $names = Get-RecipePortNames $RepoRoot
    $exclude = if (Test-Path -LiteralPath $full -PathType Container) {
        @(Get-ChildItem -LiteralPath $full -Directory | Where-Object { $_.Name -cne $Port -and $_.Name -cin $names } | ForEach-Object { "$folder/$($_.Name)" })
    } else { @() }
    return [pscustomobject]@{ Folder = $folder; Exclude = [string[]]$exclude }
}

function Get-RecipeSceneRefs($Recipe) {
    # The subfolders of its scene folder a recipe's steps name: $INGLENOOK_SCENE/<name>/.
    $text = @(foreach ($k in 'install', 'apply', 'stage', 'launch') { if ($Recipe.Contains($k)) { @($Recipe[$k]) } }) -join "`n"
    $found = [System.Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($text, 'INGLENOOK_SCENE\}?[/\\]([^/\\"''\s$]+)[/\\]')) { $null = $found.Add($m.Groups[1].Value) }
    return [string[]]@($found)
}

function Get-SceneFolderProblems {
    <#
    .SYNOPSIS
        Every way a scene folder would put a port's files on the wrong side of
        shared and own. Ports: @{ Name; Recipe } for each port with a valid recipe.
    .DESCRIPTION
        A recipe that names another port's own folder (that port's files are not
        in its fingerprint); an own folder in a scene folder its port is not shot
        in; and a shared subfolder that only one port's recipe uses and no shared
        file names, which is that port's own under another name.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Ports)
    $problems = [System.Collections.Generic.List[string]]::new()
    $names = Get-RecipePortNames $RepoRoot
    $folderOf = @{}
    foreach ($p in $Ports) { if ($p.Recipe) { $folderOf[$p.Name] = Get-SceneFolder ([string]$p.Recipe['kind']) } }
    foreach ($p in $Ports) {
        if (-not $p.Recipe) { continue }
        foreach ($ref in Get-RecipeSceneRefs $p.Recipe) {
            if ($ref -cne $p.Name -and $ref -cin $names) {
                $problems.Add("Ports/$($p.Name)/screenshot.json uses build/photograph/scenes/$($folderOf[$p.Name])/$ref/, the own folder of $ref, so a change there would not make $($p.Name) stale. Move what both use out of it, into the scene folder.")
            }
        }
    }
    $scenes = Join-Path $RepoRoot 'build' 'photograph' 'scenes'
    if (-not (Test-Path -LiteralPath $scenes -PathType Container)) { return $problems.ToArray() }
    foreach ($kindDir in Get-ChildItem -LiteralPath $scenes -Directory | Sort-Object Name) {
        $folder = $kindDir.Name
        $subs = @(Get-ChildItem -LiteralPath $kindDir.FullName -Directory | Sort-Object Name)
        $own = @($subs | Where-Object { $_.Name -cin $names })
        foreach ($d in $own) {
            if ($folderOf.ContainsKey($d.Name) -and $folderOf[$d.Name] -cne $folder) {
                $problems.Add("build/photograph/scenes/$folder/$($d.Name)/ is named after the port $($d.Name), which is shot in the $($folderOf[$d.Name]) scene. Move it to build/photograph/scenes/$($folderOf[$d.Name])/$($d.Name)/.")
            }
        }
        $ownPaths = @($own | ForEach-Object FullName)
        foreach ($d in @($subs | Where-Object { $_.Name -cnotin $names })) {
            $users = @(foreach ($p in $Ports) { if ($p.Recipe -and $folderOf[$p.Name] -ceq $folder -and $d.Name -cin (Get-RecipeSceneRefs $p.Recipe)) { $p.Name } })
            if ($users.Count -ne 1) { continue }
            $skip = @($ownPaths) + @($d.FullName) | ForEach-Object { $_ + [System.IO.Path]::DirectorySeparatorChar }
            $outside = @(Get-ChildItem -LiteralPath $kindDir.FullName -Recurse -File -Force | Where-Object {
                $f = $_.FullName
                @($skip | Where-Object { $f.StartsWith($_) }).Count -eq 0
            })
            $named = @($outside | Where-Object { (Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue) -match "(^|[^A-Za-z0-9._-])$([regex]::Escape($d.Name))[/\\]" })
            if (-not $named.Count) {
                $problems.Add("build/photograph/scenes/$folder/$($d.Name)/ is used only by $($users[0])'s recipe, so it is $($users[0])'s own: rename it to build/photograph/scenes/$folder/$($users[0])/. A shared folder is in every $folder port's fingerprint; an own folder is named exactly after its port.")
            }
        }
    }
    return $problems.ToArray()
}

function Get-SceneEnv {
    <#
    .SYNOPSIS
        The fixed scene of one take, as the variables shoot.sh reads from
        scene.env. Returns an ordered dictionary.
    .DESCRIPTION
        Every take: KIND, SCREEN, BACKDROP_KIND and BACKDROP (fill and a hex, or
        image and a repo path, from Get-SceneBackdrop), GTK_THEME (the
        stock frame in the variant's mode, as GTK_THEME takes it), TIMEOUT and
        RECIPE (named in failures). A window adds WINDOW_KIND, WINDOW_MATCH and
        SETTLE (seconds the screen must stay the same before the grab). A
        desktop has no window: it adds FRAME_THEME (the same frame by theme name,
        for the desktop's own settings) and CLOCK (the time its panel shows).
        On Windows the frame is the system's: MODE (light or dark, the Windows
        app and system mode) takes GTK_THEME's place, and the screen is the
        Windows one.
    #>
    param([Parameter(Mandatory)]$Plan, [Parameter(Mandatory)][ValidateSet('day', 'night')][string]$Variant,
        [Parameter(Mandatory)][string]$RecipeFile, [Parameter(Mandatory)]$Backdrop)
    $v = $Variants[$Variant]
    if ($Plan.Platform -eq 'windows') {
        $s = $Screens['windows']
        return [ordered]@{
            KIND = $Plan.Kind; SCREEN = "$($s.Width)x$($s.Height)"; BACKDROP_KIND = $Backdrop.Kind; BACKDROP = $Backdrop.Value; MODE = $v.Mode
            TIMEOUT = $WindowTimeout; RECIPE = $RecipeFile; WINDOW_KIND = $Plan.Window.Kind; WINDOW_MATCH = $Plan.Window.Match
        }
    }
    $scene = [ordered]@{
        KIND = $Plan.Kind; SCREEN = "$($Screens.linux.Width)x$($Screens.linux.Height)"; BACKDROP_KIND = $Backdrop.Kind; BACKDROP = $Backdrop.Value; GTK_THEME = $v.GtkTheme
        TIMEOUT = $WindowTimeout; RECIPE = $RecipeFile
    }
    if ($Plan.Kind -eq 'desktop') {
        $scene.FRAME_THEME = $v.FrameTheme
        $scene.CLOCK = $Clock
    }
    else {
        $scene.WINDOW_KIND = $Plan.Window.Kind
        $scene.WINDOW_MATCH = $Plan.Window.Match
        $scene.SETTLE = $SettleSeconds
    }
    return $scene
}

function Get-RecipeSteps([string]$Port, $Recipe, [string]$Phase) {
    $version = if ($Recipe.Contains('version')) { $Recipe['version'] } else { '' }
    $n = 0
    foreach ($line in @($(if ($Recipe.Contains($Phase)) { $Recipe[$Phase] }))) {
        $n++
        [pscustomobject]@{ Port = $Port; Phase = $Phase; Number = $n; Line = $line; Version = $version }
    }
}

function Get-ShotPlan {
    <#
    .SYNOPSIS
        The steps of a port's shot, in order. Returns @{ Install; Shot; Kind; Window; Platform }.
    .DESCRIPTION
        Install runs as root when the port's image is built; Shot runs per variant
        as the ordinary user. Each step is { Port; Phase; Number; Line; Version }.
        A guest runs inside its host: host install, guest install; then host apply
        and stage, guest apply and stage, host launch. The scene kind is the port's own; the
        window is the host's. Window is { Kind = class|title; Match }, or $null for
        a desktop. Platform is the recipe's (a guest's host is on the same one).
    #>
    param([Parameter(Mandatory)][string]$Port, [Parameter(Mandatory)]$Recipe, [string]$HostPort, $HostRecipe)
    $main = if ($HostRecipe) { $HostRecipe } else { $Recipe }
    $mainPort = if ($HostRecipe) { $HostPort } else { $Port }
    $install = @(Get-RecipeSteps $mainPort $main 'install')
    $shot = @(Get-RecipeSteps $mainPort $main 'apply') + @(Get-RecipeSteps $mainPort $main 'stage')
    if ($HostRecipe) {
        $install += @(Get-RecipeSteps $Port $Recipe 'install')
        $shot += @(Get-RecipeSteps $Port $Recipe 'apply') + @(Get-RecipeSteps $Port $Recipe 'stage')
    }
    $shot += @(Get-RecipeSteps $mainPort $main 'launch')
    $window = $null
    if ($main.Contains('window')) {
        $k = @($main['window'].Keys)[0]
        $window = [pscustomobject]@{ Kind = $k; Match = $main['window'][$k] }
    }
    return [pscustomobject]@{ Install = $install; Shot = $shot; Kind = $Recipe['kind']; Window = $window; Platform = [string]$main['platform'] }
}

function ConvertTo-PortDockerfile {
    <#
    .SYNOPSIS
        The Dockerfile of a port's image: the shared base plus the plan's install
        steps, run as root, each with its own port's INGLENOOK_VERSION.
    #>
    param([Parameter(Mandatory)][string]$Base, [object[]]$Steps = @())
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# Generated by build/photograph.ps1 from the recipe''s install steps.')
    $lines.Add("FROM $Base")
    $lines.Add('USER root')
    $version = $null
    foreach ($s in $Steps) {
        if ($s.Version -cne $version) { $lines.Add("ENV INGLENOOK_VERSION=$(ConvertTo-Json -InputObject ([string]$s.Version) -Compress)"); $version = $s.Version }
        $lines.Add("RUN $(ConvertTo-Json -InputObject @('bash', '-euo', 'pipefail', '-c', $s.Line) -Compress)")
    }
    return ($lines -join "`n") + "`n"
}

function ConvertTo-BashWord([string]$Text) { return "'" + $Text.Replace("'", "'\''") + "'" }

function ConvertTo-StepScript {
    <#
    .SYNOPSIS
        The bash script that runs a plan's shot steps for one variant, from the
        repo root. A failed step stops the take and names the recipe, the step,
        and its last output lines. Launch steps run in the background.
    .DESCRIPTION
        Steps get exactly four variables: INGLENOOK_VARIANT, INGLENOOK_SCENE (the scene
        kind's folder; an icon theme's is the editor's), INGLENOOK_PORT (the step's own port folder) and
        INGLENOOK_VERSION (the step's own port's version).
    #>
    param([object[]]$Steps = @(), [Parameter(Mandatory)][string]$Kind, [Parameter(Mandatory)][string]$Variant,
        [Parameter(Mandatory)][string]$RepoRoot)
    $root = $RepoRoot.TrimEnd('/')
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('#!/usr/bin/env bash')
    $lines.Add('# Generated by build/photograph.ps1 from the recipe''s apply, stage and launch steps.')
    $lines.Add('set -uo pipefail')
    $lines.Add("cd $(ConvertTo-BashWord $root)")
    $lines.Add("export INGLENOOK_VARIANT=$(ConvertTo-BashWord $Variant) INGLENOOK_SCENE=$(ConvertTo-BashWord "$root/build/photograph/scenes/$(Get-SceneFolder $Kind)")")
    $lines.Add('step() {  # port phase number version line')
    $lines.Add('  local log="/tmp/step-$1-$2-$3.log"')
    $lines.Add('  if [ "$2" = launch ]; then')
    $lines.Add("    INGLENOOK_PORT=`"$root/Ports/`$1`" INGLENOOK_VERSION=`"`$4`" setsid bash -c `"`$5`" >`"`$log`" 2>&1 &")
    $lines.Add('    return')
    $lines.Add('  fi')
    $lines.Add("  if ! INGLENOOK_PORT=`"$root/Ports/`$1`" INGLENOOK_VERSION=`"`$4`" bash -euo pipefail -c `"`$5`" >`"`$log`" 2>&1; then")
    $lines.Add('    echo "photograph: Ports/$1/screenshot.json, $2 step $3 failed: $5" >&2')
    $lines.Add('    tail -n 20 "$log" | sed "s/^/    /" >&2')
    $lines.Add('    exit 1')
    $lines.Add('  fi')
    $lines.Add('}')
    foreach ($s in $Steps) {
        $lines.Add("step $(@($s.Port, $s.Phase, [string]$s.Number, [string]$s.Version, $s.Line | ForEach-Object { ConvertTo-BashWord $_ }) -join ' ')")
    }
    return ($lines -join "`n") + "`n"
}

# Single quotes, doubled inside, as PowerShell reads them (it counts curly quotes as quotes too).
function ConvertTo-PwshWord([string]$Text) { return "'" + ($Text -replace "(['‘’‚‛])", '$1$1') + "'" }

function ConvertTo-WindowsStepScript {
    <#
    .SYNOPSIS
        The PowerShell script that runs a plan's steps on Windows, from the repo
        root: the shot steps of one variant, or with no -Variant the install
        steps. Each step runs in its own pwsh, where an error stops it. A failed
        step stops the script and names the recipe, the step, and its last
        output lines. Launch steps run in the background.
    .DESCRIPTION
        Steps get the same four variables as on Linux: INGLENOOK_VARIANT and
        INGLENOOK_SCENE (shot steps only), INGLENOOK_PORT and INGLENOOK_VERSION. Each
        step's output goes to step-<port>-<phase>-<number>.log in -Logs.
    #>
    param([object[]]$Steps = @(), [Parameter(Mandatory)][string]$Kind, [ValidateSet('', 'day', 'night')][string]$Variant = '',
        [Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Logs)
    $root = $RepoRoot.TrimEnd('\', '/')
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# Generated by build/photograph.ps1 from the recipe''s steps.')
    $lines.Add('$ErrorActionPreference = ''Stop''')
    $lines.Add("Set-Location -LiteralPath $(ConvertTo-PwshWord $root)")
    if ($Variant) {
        $lines.Add("`$env:INGLENOOK_VARIANT = $(ConvertTo-PwshWord $Variant)")
        $lines.Add("`$env:INGLENOOK_SCENE = $(ConvertTo-PwshWord "$root\build\photograph\scenes\$(Get-SceneFolder $Kind)")")
    }
    $lines.Add('function Step([string]$Port, [string]$Phase, [string]$Number, [string]$Version, [string]$Line) {')
    $lines.Add("    `$env:INGLENOOK_PORT = $(ConvertTo-PwshWord "$root\Ports\")" + ' + $Port')
    $lines.Add('    $env:INGLENOOK_VERSION = $Version')
    $lines.Add("    `$log = Join-Path $(ConvertTo-PwshWord $Logs) ""step-`$Port-`$Phase-`$Number.log""")
    $lines.Add('    $code = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("`$ErrorActionPreference = ''Stop''; `$PSNativeCommandUseErrorActionPreference = `$true`n$Line"))')
    $lines.Add('    if ($Phase -eq ''launch'') {')
    $lines.Add('        $null = Start-Process pwsh -ArgumentList ''-NoProfile'', ''-NonInteractive'', ''-EncodedCommand'', $code -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError "$log.err"')
    $lines.Add('        return')
    $lines.Add('    }')
    $lines.Add('    & pwsh -NoProfile -NonInteractive -EncodedCommand $code *> $log')
    $lines.Add('    if ($LASTEXITCODE -ne 0) {')
    $lines.Add('        Write-Output "photograph: Ports/$Port/screenshot.json, $Phase step $Number failed: $Line"')
    $lines.Add('        Get-Content -LiteralPath $log -Tail 20 | ForEach-Object { "    $_" }')
    $lines.Add('        exit 1')
    $lines.Add('    }')
    $lines.Add('}')
    foreach ($s in $Steps) {
        $lines.Add("Step $(@($s.Port, $s.Phase, [string]$s.Number, [string]$s.Version, $s.Line | ForEach-Object { ConvertTo-PwshWord $_ }) -join ' ')")
    }
    return ($lines -join "`n") + "`n"
}

function Find-ShotWindow {
    <#
    .SYNOPSIS
        The window a Windows take shoots, from the visible top-level windows in
        z-order (front first), or $null. Each window is @{ Handle; Class; Title;
        Path } (Path: its process's exe).
    .DESCRIPTION
        A window matches the recipe's class exactly, or its title regex, and
        belongs to an exe that was not running before the take (Before: those
        exe paths, compared as Windows does, ignoring case). So the runner's own
        Windows Terminal never matches, whatever its class. The frontmost match wins.
    #>
    param([object[]]$Windows = @(), [string[]]$Before = @(), [Parameter(Mandatory)]$Window)
    foreach ($w in $Windows) {
        if (-not $w.Path -or ($Before -contains $w.Path)) { continue }
        $hit = if ($Window.Kind -eq 'title') { [string]$w.Title -match $Window.Match } else { [string]$w.Class -ceq $Window.Match }
        if ($hit) { return $w }
    }
    return $null
}

function Get-ShotCrop {
    <#
    .SYNOPSIS
        The area of the settled screen grab that becomes the shot: the window
        frame plus a margin of the real desktop, clipped to the screen. A desktop
        has no window: its shot is a fixed area at the bottom left.
        Returns @{ X; Y; Width; Height }. The screen is the platform's.
    #>
    param([Parameter(Mandatory)][string]$Kind, $Frame, [ValidateSet('linux', 'windows')][string]$Platform = 'linux')
    $scr = $Screens[$Platform]
    if ($Kind -eq 'desktop') {
        return @{ X = 0; Y = $scr.Height - $DesktopCrop.Height; Width = $DesktopCrop.Width; Height = $DesktopCrop.Height }
    }
    $x1 = [math]::Max(0, $Frame.X - $Margin)
    $y1 = [math]::Max(0, $Frame.Y - $Margin)
    $x2 = [math]::Min($scr.Width, $Frame.X + $Frame.Width + $Margin)
    $y2 = [math]::Min($scr.Height, $Frame.Y + $Frame.Height + $Margin)
    return @{ X = $x1; Y = $y1; Width = $x2 - $x1; Height = $y2 - $y1 }
}

function Add-ShotTable {
    <#
    .SYNOPSIS
        A port README with the Day and Night screenshot table under its header
        lines (the bold Tier, Variants and Tested with lines), headed Day and
        Night as in the new-port README template; the image alt text carries
        the full variant names. Returns the text unchanged if it already shows
        screenshots/day.png.
    #>
    param([Parameter(Mandatory)][string]$Readme, [Parameter(Mandatory)][string]$DayName, [Parameter(Mandatory)][string]$NightName)
    if ($Readme -match '\(screenshots/day\.png\)') { return $Readme }
    $nl = if ($Readme -match "`r`n") { "`r`n" } else { "`n" }
    $lines = [System.Collections.Generic.List[string]]($Readme -split "`r?`n")
    $i = 0
    while ($i -lt $lines.Count -and ($lines[$i] -like '# *' -or $lines[$i] -eq '')) { $i++ }
    while ($i -lt $lines.Count -and $lines[$i] -like '`**') { $i++ }
    $table = @(
        '| Day | Night |'
        '|---|---|'
        "| ![$DayName](screenshots/day.png) | ![$NightName](screenshots/night.png) |"
    )
    $lines.InsertRange($i, [string[]](@('') + $table))
    return $lines -join $nl
}

function Get-BaseBuildArgs {
    <#
    .SYNOPSIS
        The build arguments of the shared Linux base image, from the pins file
        (build/photograph/pins.json), as NAME=value strings. Throws, naming every
        loose pin, if one is not exact.
    .DESCRIPTION
        base: the image by digest. ubuntu_snapshot: the Ubuntu package date
        (YYYYMMDDTHHMMSSZ), set per Ubuntu source line. mint_packages: package to
        exact version, for packages from Mint's own repo. font: the BlexMono Nerd
        Font zip's https URL and sha256. chromium: the exact version of Mint's
        chromium package, the browser of the web scene and the preview shots,
        installed in the last layer so the layers below it stay cached. resvg: the
        exact version, https URL and sha256 of the resvg release that renders a
        .png.svg template (Build.psm1 refuses any other version).
    #>
    param([Parameter(Mandatory)][string]$Path)
    $p = Read-JsonFile $Path
    $problems = [System.Collections.Generic.List[string]]::new()
    if (-not ($p['base'] -is [string] -and $p['base'] -match '^\S+@sha256:[0-9a-f]{64}$')) { $problems.Add('base must name an image by digest (<image>@sha256:<64 hex>)') }
    if (-not ($p['ubuntu_snapshot'] -is [string] -and $p['ubuntu_snapshot'] -match '^\d{8}T\d{6}Z$')) { $problems.Add('ubuntu_snapshot must be a date like 20261124T000000Z') }
    $mint = $p['mint_packages']
    if ($mint -isnot [System.Collections.IDictionary] -or @($mint.Values | Where-Object { -not ($_ -is [string] -and $_ -match '^\S+$') }).Count) {
        $problems.Add('mint_packages must map each package to an exact version')
    }
    $font = $p['font']
    if (-not ($font -is [System.Collections.IDictionary] -and $font['url'] -is [string] -and $font['url'] -match '^https://\S+$' -and
              $font['sha256'] -is [string] -and $font['sha256'] -match '^[0-9a-f]{64}$')) { $problems.Add('font needs an https url and its sha256') }
    if (-not ($p['chromium'] -is [string] -and $p['chromium'] -match '^\d+(\.\d+){3}\S*$')) { $problems.Add('chromium must be the exact version of Mint''s chromium package') }
    $resvg = $p['resvg']
    if (-not ($resvg -is [System.Collections.IDictionary] -and $resvg['version'] -is [string] -and $resvg['version'] -match '^\d+\.\d+\.\d+$' -and
              $resvg['url'] -is [string] -and $resvg['url'] -match '^https://\S+$' -and
              $resvg['sha256'] -is [string] -and $resvg['sha256'] -match '^[0-9a-f]{64}$')) { $problems.Add('resvg needs an exact version, an https url and its sha256') }
    if ($problems.Count) { throw "$Path`: $($problems -join '; ')." }
    $mintList = @(foreach ($k in $mint.Keys) { "$k=$($mint[$k])" }) -join ' '
    return @("BASE=$($p['base'])", "UBUNTU_SNAPSHOT=$($p['ubuntu_snapshot'])", "MINT_PACKAGES=$mintList",
        "FONT_URL=$($font['url'])", "FONT_SHA256=$($font['sha256'])", "CHROMIUM_VERSION=$($p['chromium'])",
        "RESVG_URL=$($resvg['url'])", "RESVG_SHA256=$($resvg['sha256'])", "RESVG_VERSION=$($resvg['version'])")
}

# --- The fingerprint: a hash of everything a shot is made from ------------------

function Get-Sha256($Data) {
    # The SHA-256 of bytes, or of text as UTF-8, in lowercase hex: every hash the Photographer writes or compares.
    if ($Data -is [byte[]]) { $bytes = $Data } else { $bytes = [System.Text.Encoding]::UTF8.GetBytes([string]$Data) }
    return [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Get-StampVersion([string]$RepoRoot) {
    # The palette version, which dist/ carries as its version stamp.
    $path = Join-Path $RepoRoot 'palette' 'palette.json'
    $version = (Read-JsonFile $path)['meta']['version']
    if (-not ($version -is [string] -and $version)) { throw "$path has no meta.version." }
    return $version
}

function Get-InputGroupHash([string]$RepoRoot, [string[]]$Paths, [string[]]$Exclude = @(), [string]$StampVersion) {
    # One hash of the files under the given repo paths (files or folders), each
    # listed by its repo path. Text is read with LF line endings, and with
    # -StampVersion that version stamp reads the same whatever it is. '' if there are none.
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($p in $Paths) {
        $full = Join-Path $RepoRoot $p
        $found = if (Test-Path -LiteralPath $full -PathType Leaf) { @(Get-Item -LiteralPath $full) }
                 elseif (Test-Path -LiteralPath $full -PathType Container) { @(Get-ChildItem -LiteralPath $full -Recurse -File -Force) }
                 else { @() }
        foreach ($f in $found) {
            $rel = [System.IO.Path]::GetRelativePath($RepoRoot, $f.FullName).Replace('\', '/')
            if (@($Exclude | Where-Object { $rel -eq $_ -or $rel.StartsWith("$_/") }).Count) { continue }
            $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
            $hash = if ([Array]::IndexOf($bytes, [byte]0) -ge 0) { Get-Sha256 $bytes }
                    else {
                        $text = [System.Text.Encoding]::UTF8.GetString($bytes) -replace "`r`n", "`n"
                        if ($StampVersion) { $text = Remove-VersionStamp $text -Version $StampVersion }
                        Get-Sha256 $text
                    }
            $lines.Add("$rel`t$hash")
        }
    }
    if (-not $lines.Count) { return '' }
    $sorted = [string[]]$lines.ToArray(); [Array]::Sort($sorted, [StringComparer]::Ordinal)
    return Get-Sha256 (($sorted -join "`n") + "`n")
}

function Get-BackdropHash([string]$RepoRoot) {
    # One hash of both variants' backdrops: a fill by its hex, an image by its file.
    $lines = foreach ($v in $Variants.Keys) {
        $b = Get-SceneBackdrop -RepoRoot $RepoRoot -Variant $v
        $what = if ($b.Kind -eq 'image') { Get-InputGroupHash $RepoRoot @($b.Value) } else { $b.Value }
        "$v=$($b.Kind):$what"
    }
    return Get-Sha256 (($lines -join "`n") + "`n")
}

function Get-ShotFingerprint {
    <#
    .SYNOPSIS
        The fingerprint of a port's shots, and a hash per input group.
        Returns @{ Fingerprint; Inputs } (Inputs: port, host, recipe, scene,
        photographer, backdrop, in that order).
    .DESCRIPTION
        The inputs come from the recipe: the port's dist/; its host's dist/
        and recipe (empty without a host); its own recipe; the folder of its
        scene kind in build/photograph/scenes/ (an icon theme's is the editor's), but the
        other ports' own folders in it (Get-SceneInput); the Photographer itself (the
        rest of build/photograph/ with its pins, photograph.ps1, this module and Png.psm1); the backdrop of each variant (its hex, or its wallpaper file). The version stamp in
        dist/ (the palette version, palette/palette.json meta.version) is left out, and text is read with LF line endings, so a Windows checkout
        gives the same fingerprint. Templates, READMEs, MAPPING.md, port.json,
        icons and the rest of the palette are not inputs.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Port, [Parameter(Mandatory)]$Recipe)
    $hostPort = if ($Recipe.Contains('host')) { [string]$Recipe['host'] } else { '' }
    $stamp = Get-StampVersion $RepoRoot
    $scene = Get-SceneInput -RepoRoot $RepoRoot -Port $Port -Kind $Recipe['kind']
    $inputs = [ordered]@{
        port = Get-InputGroupHash $RepoRoot @("Ports/$Port/dist") -StampVersion $stamp
        host = if ($hostPort) {
            Get-Sha256 ((Get-InputGroupHash $RepoRoot @("Ports/$hostPort/dist") -StampVersion $stamp) + (Get-InputGroupHash $RepoRoot @("Ports/$hostPort/screenshot.json")))
        } else { '' }
        recipe = Get-InputGroupHash $RepoRoot @("Ports/$Port/screenshot.json")
        scene = Get-InputGroupHash $RepoRoot @($scene.Folder) -Exclude $scene.Exclude
        photographer = Get-InputGroupHash $RepoRoot @('build/photograph', 'build/photograph.ps1', 'build/lib/Photographer.psm1', 'build/lib/Png.psm1') -Exclude @('build/photograph/scenes')
        backdrop = Get-BackdropHash $RepoRoot
    }
    $fingerprint = Get-Sha256 ((@(foreach ($k in $inputs.Keys) { "$k=$($inputs[$k])" }) -join "`n") + "`n")
    return [pscustomobject]@{ Fingerprint = $fingerprint; Inputs = $inputs }
}

function Get-PreviewFingerprint {
    <#
    .SYNOPSIS
        The fingerprint of the preview's shots (shots.json), and a hash per
        input group. Returns @{ Fingerprint; Inputs } (Inputs: port, assets,
        shots, photographer, wallpapers, in that order).
    .DESCRIPTION
        The preview is its own bare page: its dist/ (version stamps included,
        since the page prints the palette version), its assets/, its shots.json,
        the Photographer (as for a port: build/photograph/ but its scenes, with
        the pins, photograph.ps1, this module and Png.psm1), and the wallpapers its dist/
        names (wallpapers/<file>, or a web copy, wallpapers/web/<file>). Text is read with LF line endings. The scenes
        and the scene wallpapers are not inputs.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Port)
    $dist = Join-Path $RepoRoot 'Ports' $Port 'dist'
    $named = [System.Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
    if (Test-Path -LiteralPath $dist) {
        foreach ($f in Get-ChildItem -LiteralPath $dist -Recurse -File) {
            foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($f.FullName), 'wallpapers/((?:web/)?[A-Za-z0-9._-]+\.(?:jpe?g|png|webp))')) { $null = $named.Add("wallpapers/$($m.Groups[1].Value)") }
        }
    }
    $inputs = [ordered]@{
        port = Get-InputGroupHash $RepoRoot @("Ports/$Port/dist")
        assets = Get-InputGroupHash $RepoRoot @("Ports/$Port/assets")
        shots = Get-InputGroupHash $RepoRoot @("Ports/$Port/shots.json")
        photographer = Get-InputGroupHash $RepoRoot @('build/photograph', 'build/photograph.ps1', 'build/lib/Photographer.psm1', 'build/lib/Png.psm1') -Exclude @('build/photograph/scenes')
        wallpapers = Get-InputGroupHash $RepoRoot @($named)
    }
    $fingerprint = Get-Sha256 ((@(foreach ($k in $inputs.Keys) { "$k=$($inputs[$k])" }) -join "`n") + "`n")
    return [pscustomobject]@{ Fingerprint = $fingerprint; Inputs = $inputs }
}

function Test-ShotStale {
    <#
    .SYNOPSIS
        True if a port's shots are stale: one of its images (day.png and
        night.png, or -Names for a shot list) is missing from its screenshots
        folder, or its stamp lacks the fingerprint.
    #>
    param([Parameter(Mandatory)][string]$Dir, [Parameter(Mandatory)][string]$Fingerprint, [string[]]$Names = @('day', 'night'))
    foreach ($v in $Names) {
        $png = Join-Path $Dir "$v.png"
        if (-not (Test-Path -LiteralPath $png -PathType Leaf)) { return $true }
        $stamp = Read-ShotStamp -Path $png
        if ($null -eq $stamp -or $stamp['fingerprint'] -cne $Fingerprint) { return $true }
    }
    return $false
}

function New-ShotStamp {
    <#
    .SYNOPSIS
        What a shot's PNG text chunk records: the fingerprint, and beside it,
        outside the fingerprint, the hash per input group, the app and host
        versions (the recipes' version, or '' when the package date pins the
        app), the Ubuntu package date, and the runner image.
    #>
    param([Parameter(Mandatory)]$Fingerprint, [Parameter(Mandatory)]$Recipe, $HostRecipe,
        [Parameter(Mandatory)][string]$PinsPath, [Parameter(Mandatory)][string]$RunnerImage)
    $pins = Read-JsonFile $PinsPath
    $versionOf = { param($r) if ($r -and $r.Contains('version')) { [string]$r['version'] } else { '' } }
    return [ordered]@{
        fingerprint = $Fingerprint.Fingerprint
        inputs = $Fingerprint.Inputs
        app_version = & $versionOf $Recipe
        host_version = & $versionOf $HostRecipe
        package_date = [string]$pins['ubuntu_snapshot']
        runner_image = $RunnerImage
    }
}

function New-ManualShotStamp {
    <#
    .SYNOPSIS
        The stamp of a hand-taken shot of a manual recipe: the fingerprint and
        the hash per input group, with no app version, package date or runner
        image ('by hand' in its place).
    #>
    param([Parameter(Mandatory)]$Fingerprint)
    return [ordered]@{
        fingerprint = $Fingerprint.Fingerprint
        inputs = $Fingerprint.Inputs
        app_version = ''
        host_version = ''
        package_date = ''
        runner_image = 'by hand'
    }
}

function Update-ShotStamp {
    <#
    .SYNOPSIS
        Gives an unchanged committed shot the stamp of the take that matched it,
        if its fingerprint is not the take's. Returns $true if it wrote.
    .DESCRIPTION
        For a take whose verdict is unchanged: the pixels are the same, so only
        the stamp is new. Without it, the shot keeps its old fingerprint and stays
        stale, retaken every run. The image chunks are kept byte for byte. A stamp
        that differs only outside the fingerprint (the runner image) is left alone.
    #>
    param([Parameter(Mandatory)][string]$Committed, [Parameter(Mandatory)][string]$Take)
    $new = Read-ShotStamp -Path $Take
    if ($null -eq $new -or -not $new.Contains('fingerprint')) { return $false }
    $old = Read-ShotStamp -Path $Committed
    if ($null -ne $old -and $old.Contains('fingerprint') -and $old['fingerprint'] -ceq $new['fingerprint']) { return $false }
    Write-ShotStamp -Path $Committed -Stamp $new
    return $true
}

# --- The take verdict: decoded pixels, exact, no tolerance ----------------------

function Get-TakeVerdict {
    <#
    .SYNOPSIS
        What the takes of one variant say. Returns @{ Verdict; Shot }.
    .DESCRIPTION
        Takes are compared with the committed shot (or $null if there is none)
        by exact decoded pixels. One take that equals the committed shot:
        unchanged. A second take that equals it: unchanged. Two takes that equal
        each other: changed, and Shot is the second. Neither: a third take must
        equal the committed shot (unchanged) or one of the takes (changed, Shot
        is the third), or the variant has failed. Verdict 'retake' asks for
        another take. Shot is the committed path when unchanged.
    #>
    param($Committed, [Parameter(Mandatory)][string[]]$Takes)
    if ($Takes.Count -gt 3) { throw "Get-TakeVerdict: at most three takes, got $($Takes.Count)." }
    $same = { param($x, $y) (Compare-ShotPixels -Path $x -Other $y).Same }
    $last = $Takes[-1]
    if ($Committed -and (& $same $last $Committed)) { return [pscustomobject]@{ Verdict = 'unchanged'; Shot = $Committed } }
    switch ($Takes.Count) {
        1 { return [pscustomobject]@{ Verdict = 'retake'; Shot = $null } }
        2 {
            if (& $same $Takes[0] $last) { return [pscustomobject]@{ Verdict = 'changed'; Shot = $last } }
            return [pscustomobject]@{ Verdict = 'retake'; Shot = $null }
        }
        3 {
            if ((& $same $Takes[0] $last) -or (& $same $Takes[1] $last)) { return [pscustomobject]@{ Verdict = 'changed'; Shot = $last } }
            return [pscustomobject]@{ Verdict = 'failed'; Shot = $null }
        }
    }
}

function Get-ShotWhy {
    <#
    .SYNOPSIS
        The "why" line of a changed shot in the rolling pull request, from the
        committed shot's stamp (Old) and the new one (New).
    .DESCRIPTION
        Names what moved, in order: the app version ("VS Code 1.104.0 → 1.108.1"),
        the host's version, the package date, then each input group that changed
        ("port files changed", "host port changed", "recipe changed", "scene
        changed", "Photographer changed", "backdrop changed", "wallpapers changed"), joined by "; ".
        A recipe change that moved the app version is not named twice. With no
        input changed it says so, and names the runner image if that moved.
        The preview's groups (assets changed, shot list changed) are named too.
        Old is $null when there was no committed shot, and a stamp without
        inputs (an empty hashtable) when the committed shot was not stamped.
    #>
    param($Old, [Parameter(Mandatory)]$New, [Parameter(Mandatory)][string]$App, [string]$HostApp = 'host')
    if ($null -eq $Old) { return 'first shot' }
    if (-not ($Old -is [System.Collections.IDictionary] -and $Old.Contains('inputs') -and $Old['inputs'] -is [System.Collections.IDictionary])) {
        return 'the committed shot has no stamp'
    }
    $value = { param($s, $k) if ($s.Contains($k)) { [string]$s[$k] } else { '' } }
    $moved = { param($k) (& $value $Old $k) -cne (& $value $New $k) }
    $show = { param($v) if ($v) { $v } else { 'none' } }
    $parts = [System.Collections.Generic.List[string]]::new()
    $appMoved = & $moved 'app_version'
    if ($appMoved) { $parts.Add("$App $(& $show (& $value $Old 'app_version')) → $(& $show (& $value $New 'app_version'))") }
    if (& $moved 'host_version') { $parts.Add("$HostApp $(& $show (& $value $Old 'host_version')) → $(& $show (& $value $New 'host_version'))") }
    if (& $moved 'package_date') { $parts.Add("package date $(& $show (& $value $Old 'package_date')) → $(& $show (& $value $New 'package_date'))") }
    $names = [ordered]@{ port = 'port files changed'; assets = 'port assets changed'; host = 'host port changed'; recipe = 'recipe changed'
                         shots = 'shot list changed'; scene = 'scene changed'; photographer = 'Photographer changed'; backdrop = 'backdrop changed'
                         wallpapers = 'wallpapers changed' }
    foreach ($k in $names.Keys) {
        if ($k -eq 'recipe' -and $appMoved) { continue }
        if ((& $value $Old['inputs'] $k) -cne (& $value $New['inputs'] $k)) { $parts.Add($names[$k]) }
    }
    if ($parts.Count) { return $parts -join '; ' }
    if (& $moved 'runner_image') { return "no input changed; runner image $(& $show (& $value $Old 'runner_image')) → $(& $show (& $value $New 'runner_image'))" }
    return 'no input changed'
}

Export-ModuleMember -Function Get-ShotPlan, ConvertTo-PortDockerfile, ConvertTo-StepScript, ConvertTo-WindowsStepScript, Find-ShotWindow, Get-ShotCrop, Add-ShotTable, Get-BaseBuildArgs, Get-SceneEnv,
    Get-ShotFingerprint, Get-PreviewFingerprint, Get-SceneInput, Get-SceneFolderProblems, Test-ShotStale, New-ShotStamp, Update-ShotStamp, New-ManualShotStamp, Get-SceneFolder, Get-SceneBackdrop, Format-SceneBackdrop,
    Get-TakeVerdict, Get-ShotWhy, Get-Sha256
