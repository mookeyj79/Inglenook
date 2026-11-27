#requires -Version 7.0
<#
.SYNOPSIS
    Checks the palette and every port. Exits 1 if anything fails.

.DESCRIPTION
    1. Palette       Both variants exist; every neutral, named color, and role
                     is present and valid.
    2. Gamut         Every color fits sRGB. A color that clips by more than
                     0.003 a channel is a warning, never a failure.
    3. Contrast      The contrast floor in PHILOSOPHY.md, on solid surfaces.
                     Prints the table for both variants.
    4. Structure     Every port has a README.md and a template/ folder, and a
                     site.json, where there is one, points at real files.
    5. Port list     Every port has a valid port.json (except folders listed as
                     unlisted), and planned ports in Ports/ports.json do not
                     exist yet. A port's icon.svg and the "icon" credit in its
                     port.json come together, and the icon is plain shapes in
                     currentColor on a 24 x 24 viewBox (ADR 0008).
    6. Recipes       Every port has a screenshot.json, or a shots.json instead
                     (the preview), not both. A recipe has only the recipe
                     fields, valid steps and window, and a host on the same
                     platform that is not a guest itself. Every port with a
                     recipe has screenshots/day.png and night.png, and the
                     preview every image of its shot list.
    7. Raw color     No hex, rgb(), or hsl() values in templates or values.json.
                     Add "inglenook-ignore" to a line to skip it (for example a
                     CSS id selector that happens to look like a hex color).
    8. Placeholders  Every {{placeholder}} in every template resolves in both
                     variants, and the table in CONTRIBUTING.md lists exactly
                     the filters the build supports.
    9. Drift         Committed dist/ matches a fresh build.
   10. Leftovers     No unresolved {{placeholders}} in dist/.
   11. Format        Every dist/ file is valid for its format: .json parses,
                     .svg and .xml are well formed, .css has balanced
                     braces, comments, and quotes, and shell files parse and
                     source cleanly: .sh in bash and zsh, .zsh in zsh, .ps1 in
                     PowerShell. A shell that is not installed is a warning.
                     Every tracked .json outside dist/ (ports.json, port.json,
                     the palette, templates) parses and ends with a newline.
   12. Wallpapers    Every image in wallpapers/ has a thumbnail and a section in
                     wallpapers/README.md with its author, source, license, and
                     variant mark. Each pair has one day and one night image,
                     and pairs come before single images. A port's values.json
                     shows a wallpaper only in a variant it is marked for.
   13. Prose         No em dashes in the repo's Markdown (outside dist/).
                     Add "inglenook-ignore" to a line to skip it.
   14. Paths         Every tracked path can be checked out on Windows: no
                     < > : " | ? * or control character, and no file or
                     folder name that ends in a space or a dot. In a file
                     name, write {{variant.slug}}, not {{variant.name|slug}}.

    Outside CI, a clone with no pre-commit hook turned on (core.hooksPath
    .githooks, or prek install) gets a warning.

    The rules live in build/lib/: Palette.psm1, Placeholders.psm1,
    Shell.psm1, Build.psm1, Catalog.psm1, and Wallpaper.psm1. This script runs them and reports.

.EXAMPLE
    pwsh build/check.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($m in 'Palette', 'Placeholders', 'Shell', 'Build', 'Catalog', 'Wallpaper') {
    Import-Module (Join-Path $PSScriptRoot 'lib' "$m.psm1") -Force
}

$RepoRoot  = Split-Path -Parent $PSScriptRoot
$PortsRoot = Join-Path $RepoRoot 'Ports'

$script:Failures = [System.Collections.Generic.List[string]]::new()
function Add-Failure([string]$Message) { $script:Failures.Add($Message) }

function Invoke-Section([string]$Title, [scriptblock]$Body) {
    $before = $script:Failures.Count
    & $Body
    $status = if ($script:Failures.Count -gt $before) { 'FAIL' } else { 'ok' }
    Write-Host ('{0,-12} {1}' -f $Title, $status)
}
function Skip-Section([string]$Title, [string]$Reason) { Write-Host ('{0,-12} skipped ({1})' -f $Title, $Reason) }

function Get-RepoPath([string]$Path) { [System.IO.Path]::GetRelativePath($RepoRoot, $Path) -replace '\\', '/' }

$palette = Read-Palette -Path (Join-Path $RepoRoot 'palette' 'palette.json')
$paletteOk = $palette.Errors.Count -eq 0
$catalog = Get-PortCatalog -PortsRoot $PortsRoot -VariantKeys (Get-VariantKeys)
$templatePorts = @($catalog.Ports | Where-Object HasTemplate)

# --- 1. Palette ---------------------------------------------------------------

Invoke-Section 'Palette' { foreach ($e in $palette.Errors) { Add-Failure "Palette: $e" } }

# --- 2. Gamut -----------------------------------------------------------------

$script:Warnings = [System.Collections.Generic.List[string]]::new()
if ($paletteOk) {
    $gamut = @(Get-GamutWarning -Palette $palette)
    foreach ($w in $gamut) { $script:Warnings.Add("Gamut: $w") }
    Write-Host ('{0,-12} {1}' -f 'Gamut', $(if ($gamut.Count) { "$($gamut.Count) warning(s)" } else { 'ok' }))
}
else { Skip-Section 'Gamut' 'fix the palette first' }

# --- 3. Contrast --------------------------------------------------------------

$contrastTable = @()
if ($paletteOk) {
    Invoke-Section 'Contrast' {
        $c = Test-PaletteContrast -Palette $palette
        foreach ($f in $c.Failures) { Add-Failure "Contrast: $f" }
        $script:contrastTable = foreach ($k in Get-VariantKeys) { ''; Format-ContrastTable -Palette $palette -Variant $k -Measurements $c.Measurements }
    }
}
else { Skip-Section 'Contrast' 'fix the palette first' }

# --- 4. Structure -------------------------------------------------------------

Invoke-Section 'Structure' { foreach ($e in $catalog.StructureErrors) { Add-Failure "Structure: $e" } }

# --- 5. Port list -------------------------------------------------------------

Invoke-Section 'Port list' {
    foreach ($e in $catalog.Errors) { Add-Failure $(if ($e -like 'Icon: *') { $e } else { "Port list: $e" }) }
}

# --- 6. Recipes ---------------------------------------------------------------

Invoke-Section 'Recipes' {
    foreach ($e in $catalog.RecipeErrors) { Add-Failure "Recipes: $e" }
    foreach ($e in Get-ShotProblems $catalog) { Add-Failure "Recipes: $e" }
}

# --- 7. Raw colors in templates -------------------------------------------------

Invoke-Section 'Raw color' {
    $hexPattern  = '(?<![\w&])#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b'
    $funcPattern = '\b(?:rgba?|hsla?)\(\s*[\d.]'
    foreach ($port in $templatePorts) {
        $scan = @(Get-ChildItem -Path (Join-Path $port.Dir 'template') -Recurse -File -Force)
        $valuesPath = Join-Path $port.Dir 'values.json'
        if (Test-Path $valuesPath) { $scan += Get-Item -Path $valuesPath }
        foreach ($file in $scan) {
            $tpl = Read-TemplateFile -Path $file.FullName
            if ($tpl.Binary) { continue }
            $rel = Get-RepoPath $file.FullName
            $lineNo = 0
            foreach ($line in $tpl.Text -split "`r?`n") {
                $lineNo++
                if ($line -match 'inglenook-ignore') { continue }
                foreach ($pattern in $hexPattern, $funcPattern) {
                    $m = [regex]::Match($line, $pattern)
                    if ($m.Success) { Add-Failure "Raw color: ${rel}:$lineNo contains '$($m.Value)'. Use a palette placeholder, such as {{text}} or {{accent}}." }
                }
            }
        }
    }
}

# --- 8. Placeholders ------------------------------------------------------------

$placeholderOk = $true
if ($paletteOk) {
    Invoke-Section 'Placeholders' {
        $before = $script:Failures.Count
        foreach ($port in $templatePorts) {
            $values = $null
            $valuesPath = Join-Path $port.Dir 'values.json'
            if (Test-Path $valuesPath) {
                try { $values = Get-Content -Raw -Path $valuesPath | ConvertFrom-Json -AsHashtable }
                catch { Add-Failure "Placeholders: $(Get-RepoPath $valuesPath) is not valid JSON: $($_.Exception.Message)"; continue }
            }
            $templateDir = Join-Path $port.Dir 'template'
            foreach ($file in Get-ChildItem -Path $templateDir -Recurse -File -Force) {
                $rel = Get-RepoPath $file.FullName
                $nameRel = [System.IO.Path]::GetRelativePath($templateDir, $file.FullName)
                foreach ($e in Find-PlaceholderError -Text $nameRel -Palette $palette -PortValues $values) {
                    Add-Failure "Placeholders: $rel (file name): $e"
                }
                $tpl = Read-TemplateFile -Path $file.FullName
                if ($tpl.Binary) { continue }
                foreach ($e in Find-PlaceholderError -Text $tpl.Text -Palette $palette -PortValues $values) {
                    Add-Failure "Placeholders: ${rel}: $e"
                }
            }
        }
        $script:placeholderOk = $script:Failures.Count -eq $before

        # The CONTRIBUTING.md table documents the filters; keep it complete.
        $docPath = Join-Path $RepoRoot 'CONTRIBUTING.md'
        if (Test-Path $docPath) {
            $documented = @([regex]::Matches((Get-Content -Raw $docPath), '\{\{color\\?\|([a-z]+)\}\}') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
            $supported = @(Get-ColorFilters | Sort-Object)
            foreach ($f in $supported) { if ($f -notin $documented) { Add-Failure "Placeholders: CONTRIBUTING.md does not list the filter {{color|$f}}." } }
            foreach ($f in $documented) { if ($f -notin $supported) { Add-Failure "Placeholders: CONTRIBUTING.md lists {{color|$f}}, which the build does not support." } }
        }
    }
}
else { Skip-Section 'Placeholders' 'fix the palette first' }

# --- 9. Drift -----------------------------------------------------------------

if (-not $paletteOk) { Skip-Section 'Drift' 'fix the palette first' }
elseif (-not $placeholderOk) { Skip-Section 'Drift' 'fix the placeholders first' }
else {
    Invoke-Section 'Drift' {
        foreach ($port in $templatePorts) {
            $dist = "Ports/$($port.Name)/dist"
            try { $status = Get-PortStatus -Palette $palette -PortDir $port.Dir }
            catch { Add-Failure "Drift: Ports/$($port.Name) does not build: $($_.Exception.Message)"; continue }
            foreach ($f in $status.Files) {
                switch ($f.Kind) {
                    'missing' { Add-Failure "Drift: $dist/$($f.Path) is missing. Run build/build.ps1." }
                    'extra'   { Add-Failure "Drift: $dist/$($f.Path) is not produced by the build. Delete it or run build/build.ps1." }
                    default   { Add-Failure "Drift: $dist/$($f.Path) is out of date. Run build/build.ps1." }
                }
            }
        }
    }
}

# --- 10. Unresolved placeholders in dist -----------------------------------------

Invoke-Section 'Leftovers' {
    foreach ($port in $catalog.Ports) {
        $distDir = Join-Path $port.Dir 'dist'
        if (-not (Test-Path $distDir)) { continue }
        foreach ($file in Get-ChildItem -Path $distDir -Recurse -File -Force) {
            $rel = Get-RepoPath $file.FullName
            if (Find-Placeholder -Text $file.Name) { Add-Failure "Leftover: $rel has a placeholder in its file name." }
            $tpl = Read-TemplateFile -Path $file.FullName
            if ($tpl.Binary) { continue }
            $left = Find-Placeholder -Text $tpl.Text
            if ($left) { Add-Failure "Leftover: $rel still contains '$left'." }
        }
    }
}

# --- 11. Format of generated files -----------------------------------------------

function Test-CssBalance([string]$Text) {
    # Returns $null when balanced, otherwise a short reason.
    $depth = 0
    $i = 0
    $n = $Text.Length
    while ($i -lt $n) {
        $c = $Text[$i]
        if ($c -eq '/' -and $i + 1 -lt $n -and $Text[$i + 1] -eq '*') {
            $end = $Text.IndexOf('*/', $i + 2)
            if ($end -lt 0) { return 'unclosed /* comment' }
            $i = $end + 2
            continue
        }
        if ($c -eq '"' -or $c -eq "'") {
            $j = $i + 1
            while ($j -lt $n -and $Text[$j] -ne $c) {
                if ($Text[$j] -eq '\') { $j++ }
                elseif ($Text[$j] -eq "`n") { return "unclosed $c string" }
                $j++
            }
            if ($j -ge $n) { return "unclosed $c string" }
            $i = $j + 1
            continue
        }
        if ($c -eq '{') { $depth++ }
        elseif ($c -eq '}') {
            $depth--
            if ($depth -lt 0) { return "unexpected '}'" }
        }
        $i++
    }
    if ($depth -gt 0) { return "$depth unclosed '{'" }
    return $null
}

$script:MissingShells = [System.Collections.Generic.HashSet[string]]::new()
Invoke-Section 'Format' {
    foreach ($port in $catalog.Ports) {
        $distDir = Join-Path $port.Dir 'dist'
        if (-not (Test-Path $distDir)) { continue }
        foreach ($file in Get-ChildItem -Path $distDir -Recurse -File -Force) {
            $rel = Get-RepoPath $file.FullName
            $ext = $file.Extension.ToLowerInvariant()
            if ($ext -in '.sh', '.zsh', '.ps1') {
                $r = Test-ShellFile -Path $file.FullName
                foreach ($p in $r.Problems) { Add-Failure "Format: $rel, $p" }
                foreach ($s in $r.Skipped) { $null = $script:MissingShells.Add($s) }
                continue
            }
            if ($ext -notin '.json', '.svg', '.xml', '.css') { continue }
            $text = [System.IO.File]::ReadAllText($file.FullName)
            switch ($ext) {
                '.json' {
                    try { $null = $text | ConvertFrom-Json -AsHashtable }
                    catch { Add-Failure "Format: $rel is not valid JSON: $($_.Exception.Message)" }
                }
                { $_ -in '.svg', '.xml' } {
                    try { $null = [xml]$text }
                    catch { Add-Failure "Format: $rel is not well-formed XML: $($_.Exception.Message)" }
                }
                '.css' {
                    $reason = Test-CssBalance $text
                    if ($reason) { Add-Failure "Format: $rel has broken CSS: $reason." }
                }
            }
        }
    }
    $jsonFiles = @()
    Push-Location $RepoRoot
    try { $jsonFiles = @(git ls-files -- '*.json' 2>$null) }
    finally { Pop-Location }
    if ($LASTEXITCODE -ne 0 -or $jsonFiles.Count -eq 0) {
        # Not a git checkout: fall back to the file system, skipping local folders.
        $jsonFiles = @(Get-ChildItem -Path $RepoRoot -Recurse -File -Filter '*.json' -Force |
            ForEach-Object { Get-RepoPath $_.FullName } |
            Where-Object { $_ -notmatch '^(\.git|_site|prototypes|\.claude/worktrees)/' })
    }
    foreach ($rel in $jsonFiles) {
        if ($rel -match '(^|/)dist/') { continue }   # the Format section checks dist/
        $path = Join-Path $RepoRoot $rel
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        foreach ($p in Get-JsonFileProblem -Path $path) { Add-Failure "Format: $rel $p." }
    }
}

foreach ($s in $script:MissingShells) { $script:Warnings.Add("Format: $s is not installed, so shell files for it were not checked. CI checks them.") }

# --- 12. Wallpapers -------------------------------------------------------------

Invoke-Section 'Wallpapers' {
    $wallpaperDir = Join-Path $RepoRoot 'wallpapers'
    foreach ($e in Test-WallpaperFolder -Path $wallpaperDir) { Add-Failure "Wallpapers: $e" }
    foreach ($port in $catalog.Ports) {
        $valuesPath = Join-Path $port.Dir 'values.json'
        if (-not (Test-Path $valuesPath)) { continue }
        # Invalid JSON is reported by the Placeholders section.
        try { $values = Get-Content -Raw -Path $valuesPath | ConvertFrom-Json -AsHashtable } catch { continue }
        if ($values -isnot [System.Collections.IDictionary]) { continue }
        foreach ($e in Test-WallpaperUse -Path $wallpaperDir -Values $values -Source (Get-RepoPath $valuesPath)) { Add-Failure "Wallpapers: $e" }
    }
}

# --- 13. Prose ------------------------------------------------------------------

Invoke-Section 'Prose' {
    $emDash = [string][char]0x2014
    $mdFiles = @()
    Push-Location $RepoRoot
    try { $mdFiles = @(git ls-files -- '*.md' 2>$null) }
    finally { Pop-Location }
    if ($LASTEXITCODE -ne 0 -or $mdFiles.Count -eq 0) {
        # Not a git checkout: fall back to the file system, skipping local folders.
        $mdFiles = @(Get-ChildItem -Path $RepoRoot -Recurse -File -Filter '*.md' -Force |
            ForEach-Object { Get-RepoPath $_.FullName } |
            Where-Object { $_ -notmatch '^(\.git|_site|prototypes|\.claude/worktrees)/' })
    }
    foreach ($rel in $mdFiles) {
        if ($rel -match '(^|/)dist/') { continue }
        $path = Join-Path $RepoRoot $rel
        if (-not (Test-Path $path)) { continue }
        $lineNo = 0
        foreach ($line in [System.IO.File]::ReadAllLines($path)) {
            $lineNo++
            if ($line.Contains($emDash) -and $line -notmatch 'inglenook-ignore') {
                Add-Failure "Prose: ${rel}:$lineNo has an em dash. Use a colon, comma, or period."
            }
        }
    }
}

# --- 14. Paths ------------------------------------------------------------------

Invoke-Section 'Paths' {
    $paths = @()
    Push-Location $RepoRoot
    try { $listed = git -c core.quotepath=off ls-files -z 2>$null }
    finally { Pop-Location }
    if ($LASTEXITCODE -eq 0 -and $listed) { $paths = @(($listed -join '') -split [char]0 | Where-Object { $_ }) }
    else {
        # Not a git checkout: fall back to the file system, skipping local folders.
        $paths = @(Get-ChildItem -Path $RepoRoot -Recurse -File -Force |
            ForEach-Object { Get-RepoPath $_.FullName } |
            Where-Object { $_ -notmatch '^(\.git|_site|prototypes|\.claude/worktrees)/' })
    }
    foreach ($e in Find-WindowsPathError -Path $paths) { Add-Failure "Paths: $e" }
}

# --- Hook ---------------------------------------------------------------------

# A reminder for a local clone, never in CI: the pre-commit hook runs these
# checks before each commit. Either .githooks or a prek/pre-commit hook counts.
if (-not ($env:CI -or $env:GITHUB_ACTIONS)) {
    Push-Location $RepoRoot
    try {
        $hooksPath = git config core.hooksPath 2>$null
        $hookFile = git rev-parse --path-format=absolute --git-path hooks/pre-commit 2>$null
        $inGit = $LASTEXITCODE -eq 0
    }
    finally { Pop-Location }
    if ($inGit) {
        $hookOn = ([string]$hooksPath -replace '\\', '/' -replace '/+$', '') -match '(^|/)\.githooks$'
        if (-not $hookOn -and $hookFile -and (Test-Path -LiteralPath $hookFile -PathType Leaf)) {
            $hookOn = (Get-Content -Raw -LiteralPath $hookFile) -match 'prek|pre-commit'
        }
        if (-not $hookOn) { $script:Warnings.Add('Hook: no pre-commit hook is on, so these checks do not run before a commit. Turn it on once per clone: git config core.hooksPath .githooks (or prek install).') }
    }
}

# --- Summary ------------------------------------------------------------------

foreach ($line in $contrastTable) { Write-Host $line }
Write-Host ''
$appPorts = @($catalog.Ports | Where-Object Listed).Count
if ($appPorts -eq 0) { Write-Host 'No app ports yet.' }

foreach ($w in $script:Warnings) { Write-Host "WARN: $w" -ForegroundColor Yellow }
foreach ($f in $script:Failures) { Write-Host "FAIL: $f" -ForegroundColor Red }

if ($script:Failures.Count -gt 0) {
    Write-Host ''
    Write-Host "$($script:Failures.Count) check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "All checks passed ($($catalog.Ports.Count) port(s))."
exit 0
