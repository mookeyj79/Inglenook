#requires -Version 7.0
<#
.SYNOPSIS
    Tests the build modules in build/lib/ through their interfaces, and
    smoke tests the entry scripts. Exits 1 if any test fails.

.DESCRIPTION
    Module tests use small palettes and ports written to a temp folder, never
    the repo's own files, so a test failure points at the module and not at a
    port. The entry script tests run each script once, offline except for
    wallpaper.ps1, which fetches its image library from NuGet once and caches
    it. Plain PowerShell: no Pester needed.

.EXAMPLE
    pwsh build/test.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($m in 'Palette', 'Placeholders', 'Build', 'Catalog', 'Wallpaper') {
    Import-Module (Join-Path $PSScriptRoot 'lib' "$m.psm1") -Force
}

$script:Passed = 0
$script:Failed = [System.Collections.Generic.List[string]]::new()
$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('inglenook-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Tmp | Out-Null

function Test([string]$Name, [scriptblock]$Body) {
    try { & $Body; $script:Passed++ }
    catch { $script:Failed.Add("$Name`n    $($_.Exception.Message)") }
}
function Assert-Equal($Expected, $Actual, [string]$What = 'value') {
    if ($Expected -is [array] -or $Actual -is [array]) {
        $e = @($Expected) -join ' | '; $a = @($Actual) -join ' | '
        if ($e -cne $a) { throw "$What`: expected [$e], got [$a]" }
    }
    elseif ($Expected -cne $Actual) { throw "$What`: expected '$Expected', got '$Actual'" }
}
function Assert-True($Condition, [string]$What) { if (-not $Condition) { throw $What } }
function Assert-Throws([scriptblock]$Body, [string]$Like) {
    try { & $Body } catch { if ($_.Exception.Message -notlike $Like) { throw "threw '$($_.Exception.Message)', expected like '$Like'" }; return }
    throw "did not throw (expected like '$Like')"
}

# A palette that passes every check: gray neutrals, and every named color at
# one lightness and chroma, spread over the hues. Tests change it, then read it.
function New-PaletteData {
    $hues = @{ firelight = 66; ember = 28; oxblood = 15; clay = 52; brass = 100; moss = 140; ivy = 165; pine = 195; steel = 245; dusk = 285; heather = 330; rosewood = 8 }
    $variant = {
        param($Name, $Mode, [double[]]$N, [double]$ColorL)
        $neutrals = [ordered]@{}
        $i = 0
        foreach ($k in 'deeper', 'deep', 'base', 'raised', 'hover', 'line', 'faint', 'dim', 'text') { $neutrals[$k] = [ordered]@{ l = $N[$i]; c = 0; h = 0 }; $i++ }
        $colors = [ordered]@{}
        foreach ($c in $hues.Keys | Sort-Object) { $colors[$c] = [ordered]@{ l = $ColorL; c = 0.05; h = $hues[$c] } }
        [ordered]@{ name = $Name; mode = $Mode; wash = 0.2; neutrals = $neutrals; colors = $colors }
    }
    return [ordered]@{
        meta = [ordered]@{ name = 'Test'; version = '1.2.3'; repository = 'https://example.invalid/repo' }
        variants = [ordered]@{
            day   = (& $variant 'Test Day' 'light' @(0.93, 0.95, 0.97, 0.99, 0.91, 0.88, 0.55, 0.4, 0.2) 0.45)
            night = (& $variant 'Test Night' 'dark' @(0.16, 0.18, 0.2, 0.25, 0.28, 0.3, 0.62, 0.75, 0.9) 0.8)
        }
        roles = [ordered]@{
            accent = 'firelight'; on_accent = [ordered]@{ day = 'raised'; night = 'deeper' }
            error = 'ember'; warning = 'brass'; success = 'moss'; info = 'steel'
            keyword = 'heather'; reference = 'pine'; literal = 'clay'; type = 'dusk'; tag = 'rosewood'
        }
    }
}
function Get-TestPalette($Data) {
    $path = Join-Path $Tmp ("palette-" + [guid]::NewGuid().ToString('N') + '.json')
    ConvertTo-Json -InputObject $Data -Depth 8 | Set-Content -Path $path
    return Read-Palette -Path $path
}

# --- Palette ------------------------------------------------------------------

Test 'Palette: a valid palette has no errors, both variants, and every color as hex' {
    $p = Get-TestPalette (New-PaletteData)
    Assert-Equal 0 $p.Errors.Count "errors ($($p.Errors -join '; '))"
    Assert-Equal @('day', 'night') @($p.Variants.Keys) 'variants'
    Assert-Equal 9 $p.Variants['day'].Neutrals.Count 'neutrals'
    Assert-Equal 12 $p.Variants['night'].Colors.Count 'named colors'
    Assert-True ($p.Variants['day'].Colors['moss'].Hex -match '^#[0-9a-f]{6}$') 'hex'
    Assert-Equal 'raised' $p.Variants['day'].Roles['on_accent'] 'on_accent in day'
    Assert-Equal 'deeper' $p.Variants['night'].Roles['on_accent'] 'on_accent in night'
    Assert-Equal 'firelight' $p.Variants['night'].Roles['accent'] 'a shared role'
}

Test 'Palette: OKLCH to sRGB hex' {
    Assert-Equal '#ffffff' (ConvertTo-Srgb 1 0 0).Hex 'white'
    Assert-Equal '#000000' (ConvertTo-Srgb 0 0 0).Hex 'black'
    Assert-Equal '#ff0000' (ConvertTo-Srgb 0.627955 0.257683 29.2339).Hex 'sRGB red'
    Assert-Equal '#0000ff' (ConvertTo-Srgb 0.452014 0.313214 264.052).Hex 'sRGB blue'
    Assert-Equal '#636363' (ConvertTo-Srgb 0.5 0 0).Hex 'mid gray'
    Assert-True ((ConvertTo-Srgb 0.5 0 0).Clip -eq 0) 'gray is in gamut'
}

Test 'Palette: colors outside sRGB are clamped and warned about' {
    $s = ConvertTo-Srgb 0.6 0.35 145
    Assert-True ($s.Clip -gt 0.003) "clip $($s.Clip)"
    Assert-True ($s.Hex -match '^#[0-9a-f]{6}$') 'still a hex'
    $d = New-PaletteData
    $d.variants.day.colors.moss = [ordered]@{ l = 0.6; c = 0.35; h = 145 }
    $p = Get-TestPalette $d
    Assert-Equal 0 $p.Errors.Count 'not an error'
    $w = @(Get-GamutWarning $p)
    Assert-Equal 1 @($w | Where-Object { $_ -like 'day.moss *' }).Count "warnings: $($w -join '; ')"
    $gentle = @(Get-GamutWarning (Get-TestPalette (New-PaletteData)))
    Assert-Equal 0 $gentle.Count "a gentle palette has none: $($gentle -join '; ')"
}

Test 'Palette: reports every problem at once' {
    $d = New-PaletteData
    $d.variants.Remove('night')
    $d.variants.day.wash = 1.5
    $d.variants.day.mode = 'dark'
    $d.variants.day.neutrals.Remove('line')
    $d.variants.day.neutrals.text.l = 1.2
    $d.variants.day.colors.moss.h = 'green'
    $d.variants.day.colors.extra = [ordered]@{ l = 0.5; c = 0.1; h = 1 }
    $d.variants.day.colors.ember.x = 1
    $d.roles.error = 'red'
    $d.roles.Remove('tag')
    $d.roles.glow = 'ember'
    $d.roles.on_accent = [ordered]@{ day = 'nope'; night = 'deeper' }
    $d.meta.version = 'one'
    $p = Get-TestPalette $d
    $all = $p.Errors -join "`n"
    foreach ($want in "variant 'night' is missing", 'wash must be a number', "mode must be 'light'", "missing neutral 'line'",
        'text.l must be from 0 to 1', 'moss.h must be a number', 'colors.extra is not a named color', 'ember.x is not an OKLCH key',
        "roles.error points at 'red'", 'roles.tag is missing', 'roles.glow is not a role', 'roles.on_accent.day must name',
        'meta.version must be x.y.z') {
        Assert-True ($all -like "*$want*") "expected an error like '$want' in:`n$all"
    }
}

Test 'Palette: read from data as from a file' {
    $d = New-PaletteData
    $fromFile = Get-TestPalette $d
    $fromData = Read-Palette -Data ((ConvertTo-Json -InputObject $d -Depth 8) | ConvertFrom-Json -AsHashtable)
    Assert-Equal 0 $fromData.Errors.Count 'errors'
    Assert-Equal $fromFile.Variants['day'].Neutrals['base'].Hex $fromData.Variants['day'].Neutrals['base'].Hex 'base hex'
}

Test 'Palette: blend and contrast' {
    Assert-Equal '#808080' (Get-Blend '#ffffff' '#000000' 0.5) 'blend'
    Assert-Equal '#ffffff' (Get-Blend '#ffffff' '#000000' 1) 'blend at 1'
    Assert-Equal '21.00' ('{0:0.00}' -f (Get-Contrast '#000000' '#ffffff')) 'contrast'
    Assert-Equal '1.00' ('{0:0.00}' -f (Get-Contrast '#777777' '#777777')) 'contrast with itself'
}

Test 'Palette: names resolve to neutrals, named colors, roles, and ANSI slots' {
    $v = (Get-TestPalette (New-PaletteData)).Variants['day']
    Assert-Equal 'neutral' (Get-PaletteEntry $v 'base').Kind 'neutral'
    Assert-Equal 'color' (Get-PaletteEntry $v 'moss').Kind 'named color'
    $r = Get-PaletteEntry $v 'success'
    Assert-Equal 'role' $r.Kind 'role'
    Assert-Equal $v.Colors['moss'].Hex $r.Hex 'a role draws its color'
    Assert-Equal $v.Neutrals['raised'].Hex (Get-PaletteEntry $v 'on_accent').Hex 'on_accent draws a neutral'
    Assert-Equal 'ember' (Get-PaletteEntry $v 'ansi.red').Source 'ansi red'
    Assert-Equal $null (Get-PaletteEntry $v 'nope') 'unknown name'
    Assert-Equal $null (Get-PaletteEntry $v 'ansi.purple') 'unknown slot'
}

Test 'Palette: every filter' {
    $d = New-PaletteData
    $d.variants.day.neutrals.base = [ordered]@{ l = 1; c = 0; h = 0 }
    $d.variants.day.colors.ember = [ordered]@{ l = 0; c = 0; h = 0 }
    $d.variants.day.wash = 0.5
    $v = (Get-TestPalette $d).Variants['day']
    Assert-Equal '#000000' (Format-PaletteColor $v 'ember') 'hex'
    Assert-Equal 'ffffff' (Format-PaletteColor $v 'base' 'nohash') 'nohash'
    Assert-Equal '255, 255, 255' (Format-PaletteColor $v 'base' 'rgb') 'rgb'
    Assert-Equal '#00000000' (Format-PaletteColor $v 'error' 'clear') 'clear'
    Assert-Equal '#808080' (Format-PaletteColor $v 'ember' 'wash') 'wash is the color over base'
    Assert-Equal '#808080' (Format-PaletteColor $v 'error' 'wash') 'wash through a role'
    Assert-Equal '#808080' (Format-PaletteColor $v 'ansi.red' 'wash') 'wash through an ANSI slot'
    Assert-Equal (Get-WashColor $v 'ember') (Format-PaletteColor $v 'ember' 'wash') 'wash is what the contrast check measures'
    Assert-Equal 'ember' (Format-PaletteColor $v 'error' 'name') 'name'
    Assert-Equal 'raised' (Format-PaletteColor $v 'on_accent' 'name') 'name of a neutral'
}

Test 'Palette: wash only on named colors, unknown filters throw' {
    $v = (Get-TestPalette (New-PaletteData)).Variants['night']
    Assert-Throws { Format-PaletteColor $v 'text' 'wash' } '*only applies to named colors*'
    Assert-Throws { Format-PaletteColor $v 'on_accent' 'wash' } '*only applies to named colors*'
    Assert-Throws { Format-PaletteColor $v 'ansi.bright_red' 'wash' } '*only applies to named colors*'
    Assert-Throws { Format-PaletteColor $v 'moss' 'bogus' } "*unknown filter 'bogus'*"
    Assert-Throws { Format-PaletteColor $v 'nope' } "*unknown color 'nope'*"
}

Test 'Palette: ANSI slots, with bright the same hue slightly stronger' {
    $p = Get-TestPalette (New-PaletteData)
    $day = $p.Variants['day']; $night = $p.Variants['night']
    Assert-Equal 'raised' (Get-AnsiColor 'black' $night).Source 'night black'
    Assert-Equal 'faint' (Get-AnsiColor 'bright_black' $night).Source 'night bright black'
    Assert-Equal 'dim' (Get-AnsiColor 'white' $night).Source 'night white'
    Assert-Equal 'text' (Get-AnsiColor 'bright_white' $night).Source 'night bright white'
    Assert-Equal 'text' (Get-AnsiColor 'black' $day).Source 'day black'
    Assert-Equal 'line' (Get-AnsiColor 'white' $day).Source 'day white'
    Assert-Equal 'raised' (Get-AnsiColor 'bright_white' $day).Source 'day bright white'
    foreach ($pair in @('red', 'ember'), @('green', 'moss'), @('yellow', 'brass'), @('blue', 'steel'), @('magenta', 'heather'), @('cyan', 'pine')) {
        Assert-Equal $pair[1] (Get-AnsiColor $pair[0] $day).Source "$($pair[0])"
        Assert-Equal $day.Colors[$pair[1]].Hex (Get-AnsiColor $pair[0] $day).Hex "$($pair[0]) is the named color"
    }
    $b = Get-AnsiColor 'bright_green' $night
    Assert-Equal 0.85 ([math]::Round($b.L, 4)) 'night: lightness up 0.05'
    Assert-Equal 0.055 ([math]::Round($b.C, 4)) 'chroma times 1.1'
    Assert-Equal 140.0 $b.H 'same hue'
    Assert-Equal 0.4 ([math]::Round((Get-AnsiColor 'bright_green' $day).L, 4)) 'day: lightness down 0.05'
    $d = New-PaletteData
    $d.variants.night.colors.moss.l = 0.9
    Assert-Equal 0.92 (Get-AnsiColor 'bright_green' (Get-TestPalette $d).Variants['night']).L 'night lightness is capped'
    Assert-Equal 16 @(Get-AnsiSlots).Count 'sixteen slots'
    Assert-Equal $null (Get-AnsiColor 'purple' $day) 'unknown slot'
}

function Assert-Failure($Contrast, [string]$Like) {
    $all = $Contrast.Failures -join "`n"
    Assert-True ($all -like $Like) "expected a failure like '$Like', got:`n$all"
}
function Assert-NoFailure($Contrast, [string]$Like) {
    $hit = @($Contrast.Failures | Where-Object { $_ -like $Like })
    Assert-True ($hit.Count -eq 0) "expected no failure like '$Like', got:`n$($hit -join "`n")"
}

Test 'Contrast: a good palette passes, and every measurement is listed' {
    $c = Test-PaletteContrast (Get-TestPalette (New-PaletteData))
    Assert-Equal 0 $c.Failures.Count "failures ($($c.Failures -join '; '))"
    # Per variant: 3 text rows, 12 colors on 3 surfaces, on_accent, 12 washes.
    Assert-Equal (2 * (3 + 36 + 1 + 12)) $c.Measurements.Count 'measurements'
    $m = @($c.Measurements | Where-Object { $_.Variant -eq 'day' -and $_.Role -eq 'text' -and $_.Surface -eq 'base' })
    Assert-Equal 7.0 $m[0].Floor 'text floor'
}

Test 'Contrast: text needs 7, dim 4.5, faint 3 on base' {
    $d = New-PaletteData
    $d.variants.day.neutrals.text.l = 0.5
    $d.variants.day.neutrals.dim.l = 0.65
    $d.variants.day.neutrals.faint.l = 0.8
    $c = Test-PaletteContrast (Get-TestPalette $d)
    Assert-Failure $c '*day.text on base is*needs 7:1*'
    Assert-Failure $c '*day.dim on base is*needs 4.5:1*'
    Assert-Failure $c '*day.faint on base is*needs 3:1*'
    Assert-NoFailure $c '*night.*'
}

Test 'Contrast: named colors need 4.5 on base and 3 on raised and deep' {
    $d = New-PaletteData
    $d.variants.night.colors.ember.l = 0.55   # about 3.6:1 on base, above 3 on raised and deep
    $c = Test-PaletteContrast (Get-TestPalette $d)
    Assert-Failure $c '*night.ember on base is*needs 4.5:1*'
    Assert-NoFailure $c '*night.ember on raised*'
    Assert-NoFailure $c '*night.ember on deep*'
    $d.variants.night.colors.ember.l = 0.4
    $c = Test-PaletteContrast (Get-TestPalette $d)
    Assert-Failure $c '*night.ember on raised is*needs 3:1*'
    Assert-Failure $c '*night.ember on deep is*needs 3:1*'
}

Test 'Contrast: on_accent needs 4.5 on the accent' {
    $d = New-PaletteData
    $d.roles.on_accent = [ordered]@{ day = 'line'; night = 'deeper' }
    $c = Test-PaletteContrast (Get-TestPalette $d)
    Assert-NoFailure $c '*day.on_accent*'
    $d.variants.day.colors.firelight.l = 0.75
    Assert-Failure (Test-PaletteContrast (Get-TestPalette $d)) '*day.on_accent on accent is*needs 4.5:1*'
}

Test 'Contrast: text needs 4.5 on a wash of every named color' {
    $d = New-PaletteData
    $d.variants.night.wash = 0.9
    $c = Test-PaletteContrast (Get-TestPalette $d)
    Assert-Failure $c '*night.text on moss wash is*needs 4.5:1*'
    Assert-NoFailure $c '*day.text on*wash*'
}

Test 'Contrast: the table shows every row and marks failures' {
    $p = Get-TestPalette (New-PaletteData)
    $lines = @(Format-ContrastTable $p 'day' (Test-PaletteContrast $p).Measurements)
    Assert-Equal 'Test Day' $lines[0] 'title'
    Assert-Equal 1 @($lines | Where-Object { $_ -match '^\s+rosewood\s+\d+\.\d\d\s+\d+\.\d\d\s+\d+\.\d\d\s+\d+\.\d\d$' }).Count "rosewood row:`n$($lines -join "`n")"
    $d = New-PaletteData
    $d.variants.day.neutrals.text.l = 0.5
    $p = Get-TestPalette $d
    $lines = @(Format-ContrastTable $p 'day' (Test-PaletteContrast $p).Measurements)
    Assert-True (@($lines | Where-Object { $_ -match '^\s+text\s+\d+\.\d\d!' }).Count -eq 1) "failing text row:`n$($lines -join "`n")"
}

# --- Placeholders ---------------------------------------------------------------

Test 'Placeholders: colors a template draws' {
    $p = Get-TestPalette (New-PaletteData)
    $text = '{{base|rgb}} {{text}} {{accent}} {{meta.name}} {{port.font}} {{ansi.black}} {{ansi.bright_red}} {{nope}}'
    # ansi.black is raised in night and text in day; bright_red comes from ember.
    Assert-Equal @('accent', 'base', 'ember', 'raised', 'text') @(Get-PlaceholderColor -Text $text -Palette $p) 'names'
    Assert-Equal 0 @(Get-PlaceholderColor -Text 'no placeholders' -Palette $p).Count 'none'
}

Test 'Placeholders: expand every kind' {
    $p = Get-TestPalette (New-PaletteData)
    $v = $p.Variants['night']
    $values = @{ day = @{ theme = 'vs' }; night = @{ theme = 'vs-dark' } }
    $out = Expand-Template -Text '{{moss}} {{ meta.name }} {{variant.key}} {{variant.name}} {{variant.mode}} {{port.theme}} {{ansi.black}} {{success|nohash}} {{accent|name}}' `
        -Palette $p -Variant $v -PortValues $values -Source 'test'
    $want = "$($v.Colors['moss'].Hex) Test night Test Night dark vs-dark $($v.Neutrals['raised'].Hex) $($v.Colors['moss'].Hex.Substring(1)) firelight"
    Assert-Equal $want $out 'expanded'
}

Test 'Placeholders: slug turns a name into an identifier' {
    $p = Get-TestPalette (New-PaletteData)
    $out = Expand-Template -Text '--{{variant.name|slug}}-x {{ meta.name | slug }}' `
        -Palette $p -Variant $p.Variants['day'] -PortValues $null -Source 'test'
    Assert-Equal '--test-day-x test' $out 'slugged'
    $punct = Expand-Template -Text '{{port.label|slug}}' -Palette $p -Variant $p.Variants['night'] `
        -PortValues @{ night = @{ label = ' Inglenook: Night (v2)! ' } } -Source 'test'
    Assert-Equal 'inglenook-night-v2' $punct 'runs of punctuation become one hyphen, trimmed'
}

Test 'Placeholders: the first bad placeholder throws, naming the source' {
    $p = Get-TestPalette (New-PaletteData)
    Assert-Throws { Expand-Template -Text '{{nope}}' -Palette $p -Variant $p.Variants['day'] -PortValues $null -Source 'x.css' } '*Unknown placeholder {{nope}}*x.css*'
}

Test 'Placeholders: every problem is listed, once' {
    $p = Get-TestPalette (New-PaletteData)
    $values = @{ day = @{ only = 'x' }; night = @{} }
    $errs = @(Find-PlaceholderError -Text '{{nope}} {{nope}} {{text|wash}} {{meta.name|rgb}} {{port.only}} {{moss|bogus}} {{moss|slug}} {{ansi.purple}} {{moss}}' -Palette $p -PortValues $values)
    Assert-Equal 7 $errs.Count "errors ($($errs -join '; '))"
    Assert-True (($errs -join "`n") -like '*port.only*night*') 'names the variant missing a port value'
    Assert-True (($errs -join "`n") -like '*Unknown ANSI slot*') 'names a bad ANSI slot'
    Assert-Equal 0 @(Find-PlaceholderError -Text 'plain {{moss|wash}} {{error|wash}}' -Palette $p -PortValues $null).Count 'a good template'
}

Test 'Placeholders: leftovers and encodings' {
    Assert-Equal '{{ moss|wash }}' (Find-Placeholder 'a {{ moss|wash }} b') 'found'
    Assert-Equal $null (Find-Placeholder 'a { moss } b') 'none'
    $path = Join-Path $Tmp 'utf16.txt'
    [System.IO.File]::WriteAllText($path, '{{moss}}', [System.Text.UnicodeEncoding]::new($false, $true))
    $t = Read-TemplateFile $path
    Assert-Equal $false $t.Binary 'UTF-16 is text'
    Assert-Equal '{{moss}}' $t.Text 'UTF-16 text'
    [System.IO.File]::WriteAllBytes($path, [byte[]](0x89, 0x50, 0x00, 0x01))
    Assert-Equal $true (Read-TemplateFile $path).Binary 'binary'
}

# --- Build --------------------------------------------------------------------

function New-TestPort([string]$Name, [hashtable]$Files) {
    $dir = Join-Path $Tmp $Name
    foreach ($rel in $Files.Keys) {
        $path = Join-Path $dir 'template' $rel
        New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
        Set-Content -Path $path -Value $Files[$rel] -NoNewline
    }
    return $dir
}

Test 'Build: statuses across a port''s life' {
    $port = New-TestPort 'life' @{ 'theme.txt' = 'Version {{meta.version}}, error {{error}}'; '{{variant.key}}/name.txt' = '{{variant.name}}' }
    $d = New-PaletteData
    $p = Get-TestPalette $d
    $r = Update-Port -Palette $p -PortDir $port
    Assert-Equal 'new' $r.Status 'first build'
    Assert-Equal 4 $r.Written 'files written'
    Assert-Equal "Version 1.2.3, error $($p.Variants['day'].Colors['ember'].Hex)" (Get-Content -Raw (Join-Path $port 'dist' 'day' 'theme.txt')) 'rendered'
    Assert-True (Test-Path (Join-Path $port 'dist' 'night' 'night' 'name.txt')) 'placeholder in a file name'
    Assert-Equal 'unchanged' (Update-Port -Palette $p -PortDir $port).Status 'rebuild'

    $d.meta.version = '1.2.4'
    $s = Get-PortStatus -Palette (Get-TestPalette $d) -PortDir $port
    Assert-Equal 'version stamp only' $s.Status 'version bump'
    Assert-Equal 2 $s.Files.Count 'files that differ'

    $d.variants.day.colors.ember.l = 0.4
    Assert-Equal 'changed' (Get-PortStatus -Palette (Get-TestPalette $d) -PortDir $port).Status 'color change'
}

Test 'Build: drift kinds' {
    $port = New-TestPort 'drift' @{ 'a.txt' = '{{moss}}'; 'b.txt' = 'b' }
    $p = Get-TestPalette (New-PaletteData)
    $null = Update-Port -Palette $p -PortDir $port
    Set-Content -Path (Join-Path $port 'dist' 'day' 'extra.txt') -Value 'x'
    Remove-Item (Join-Path $port 'dist' 'day' 'b.txt')
    Set-Content -Path (Join-Path $port 'dist' 'night' 'a.txt') -Value 'stale' -NoNewline
    $s = Get-PortStatus -Palette $p -PortDir $port
    Assert-Equal 'changed' $s.Status 'status'
    $kinds = @($s.Files | Sort-Object { $_.Path } | ForEach-Object { "$($_.Path)=$($_.Kind)" })
    Assert-Equal @('day/b.txt=missing', 'day/extra.txt=extra', 'night/a.txt=out of date') $kinds 'files'
}

Test 'Build: CRLF in dist is not drift' {
    $port = New-TestPort 'crlf' @{ 'a.txt' = "one`ntwo" }
    $p = Get-TestPalette (New-PaletteData)
    $null = Update-Port -Palette $p -PortDir $port
    Set-Content -Path (Join-Path $port 'dist' 'day' 'a.txt') -Value "one`r`ntwo" -NoNewline
    Assert-Equal 'unchanged' (Get-PortStatus -Palette $p -PortDir $port).Status 'status'
}

# --- Catalog ------------------------------------------------------------------

function New-TestPorts([hashtable]$Index, [hashtable]$Ports) {
    $root = Join-Path $Tmp ('ports-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $root | Out-Null
    ConvertTo-Json -InputObject $Index -Depth 6 | Set-Content (Join-Path $root 'ports.json')
    foreach ($name in $Ports.Keys) {
        $dir = Join-Path $root $name
        New-Item -ItemType Directory -Path (Join-Path $dir 'template') -Force | Out-Null
        Set-Content (Join-Path $dir 'README.md') '# x'
        if ($null -ne $Ports[$name]) { ConvertTo-Json -InputObject $Ports[$name] -Depth 6 | Set-Content (Join-Path $dir 'port.json') }
    }
    return $root
}
$GoodMeta = @{ name = 'Good'; category = 'editor'; tier = 2; platforms = @('linux', 'web') }

Test 'Catalog: a valid catalog' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; unlisted = @('preview'); planned = @(@{ folder = 'later'; name = 'Later'; category = 'editor'; tier = $null; platforms = @('linux') }) } `
        @{ good = $GoodMeta; preview = $null }
    New-Item -ItemType Directory -Path (Join-Path $root 'good' 'dist' 'day') -Force | Out-Null
    $c = Get-PortCatalog -PortsRoot $root
    Assert-Equal 0 ($c.Errors.Count + $c.StructureErrors.Count) "errors: $($c.Errors + $c.StructureErrors -join '; ')"
    $data = ConvertTo-PortsData $c
    Assert-Equal 1 @($data.ports).Count 'listed ports'
    Assert-Equal @('day') @($data.ports[0].variants) 'variants from dist/'
    Assert-Equal 'Partial' $data.tiers['2'] 'tier names'
    Assert-Equal 'Web' $data.platforms['web'] 'platform names'
    Assert-Equal 'later' $data.planned[0].folder 'planned'
}

Test 'Catalog: reports bad port.json, unlisted, and planned entries' {
    $bad = @{ name = 'Bad'; category = 'nope'; tier = 4; platforms = @('amiga'); extra = 1 }
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; unlisted = @('ghost'); planned = @(@{ folder = 'good'; name = 'Good'; category = 'editor'; tier = 1; platforms = @('linux') }) } `
        @{ good = $GoodMeta; bad = $bad; nometa = $null }
    $all = (Get-PortCatalog -PortsRoot $root).Errors -join "`n"
    foreach ($want in "unknown field 'extra'", "category 'nope'", "needs 'tier'", "platform 'amiga'", 'nometa/port.json does not exist',
                      'unlisted folder Ports/ghost', 'Ports/good exists, so remove it') {
        Assert-True ($all -like "*$want*") "expected an error like '$want' in:`n$all"
    }
}

Test 'Catalog: icons and site.json' {
    $meta = $GoodMeta.Clone()
    $meta.icon = @{ kind = 'glyph'; set = 'Lucide'; name = 'x'; author = 'A'; source = 'https://example.invalid/x'; license = 'ISC' }
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @() } @{ good = $meta }
    $svg = Join-Path $root 'good' 'icon.svg'
    Set-Content $svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"><path d="M0 0h24v24H0z"/></svg>'
    $c = Get-PortCatalog -PortsRoot $root
    Assert-Equal 0 $c.Errors.Count "errors: $($c.Errors -join '; ')"
    Assert-Equal 'Lucide' $c.Ports[0].Icon['set'] 'icon kept'

    Set-Content $svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#ff0000"><text>x</text></svg>'
    Set-Content (Join-Path $root 'good' 'site.json') '{ "copy": ["nothere"], "entries": [{ "path": "x/index.html", "page": "missing.html", "title": "X" }], "guide": "guides/missing.html" }'
    $c = Get-PortCatalog -PortsRoot $root
    $all = $c.Errors -join "`n"
    Assert-True ($all -like '*fill="#ff0000"*' -and $all -like '*<text>*') "icon errors: $all"
    Assert-Equal $null $c.Ports[0].Icon 'invalid icon dropped'
    $site = $c.StructureErrors -join "`n"
    Assert-True ($site -like "*copies 'nothere'*" -and $site -like "*opens 'missing.html'*" -and $site -like "*guide 'guides/missing.html'*") "site.json errors: $site"
}

# --- Wallpaper ----------------------------------------------------------------

function New-Pixels([int]$Count, [byte[]]$Rgb) {
    $b = [byte[]]::new($Count * 3)
    for ($i = 0; $i -lt $b.Length; $i++) { $b[$i] = $Rgb[$i % 3] }
    return , $b
}

Test 'Wallpaper: licenses' {
    foreach ($ok in 'CC0', 'CC0 1.0', 'Public domain', 'CC BY 4.0', 'CC BY-SA 3.0') { Assert-True (Test-WallpaperLicense $ok) "$ok should pass" }
    foreach ($no in 'CC BY-NC 4.0', 'CC BY-ND 2.0', 'CC BY-NC-SA 4.0', 'GFDL', '', 'Copyrighted') { Assert-True (-not (Test-WallpaperLicense $no)) "'$no' should fail" }
}

Test 'Wallpaper: format needs a wide landscape image' {
    Assert-Equal 0 @(Test-WallpaperFormat -Width 1920 -Height 1080).Count 'a 1920 x 1080 image passes'
    Assert-Equal @('1919 px wide, needs at least 1920.') @(Test-WallpaperFormat -Width 1919 -Height 1000) 'too narrow'
    Assert-Equal @('not landscape.') @(Test-WallpaperFormat -Width 2000 -Height 2000) 'square'
    Assert-Equal @('1080 px wide, needs at least 1920.', 'not landscape.') @(Test-WallpaperFormat -Width 1080 -Height 1920) 'portrait phone shot'
}

Test 'Wallpaper: fit of plain, colorful, and busy images' {
    $f = Measure-WallpaperFit -Pixels (New-Pixels 16 @(240, 240, 240)) -Width 4 -Height 4
    Assert-Equal 0.0 $f.Detail 'plain detail'
    Assert-Equal 0.0 $f.Saturation 'gray saturation'
    Assert-Equal 'calm' $f.Grades.Saturation 'gray saturation grade'
    Assert-Equal 'calm' $f.Grades.Detail 'plain detail grade'
    $red = Measure-WallpaperFit -Pixels (New-Pixels 16 @(250, 120, 120)) -Width 4 -Height 4
    Assert-Equal 'colorful' $red.Grades.Saturation 'red saturation grade'
    $check = [byte[]]::new(48)
    for ($p = 0; $p -lt 16; $p++) { $v = if ((($p % 4) + [math]::Floor($p / 4)) % 2) { 255 } else { 160 }; foreach ($c in 0, 1, 2) { $check[3 * $p + $c] = $v } }
    $busy = Measure-WallpaperFit -Pixels $check -Width 4 -Height 4
    Assert-Equal 'busy' $busy.Grades.Detail "checkerboard detail grade ($($busy.Detail))"
    Assert-Throws { Measure-WallpaperFit -Pixels ([byte[]]::new(5)) -Width 2 -Height 1 } '*expected 6 bytes*'
}

Test 'Wallpaper: variant suggested from lightness' {
    # Gray 240 is L* 94, 119 is L* 50, 40 is L* 16.
    Assert-Equal 'day' (Measure-WallpaperFit -Pixels (New-Pixels 16 @(240, 240, 240)) -Width 4 -Height 4).Variant 'light gray'
    Assert-Equal 'both' (Measure-WallpaperFit -Pixels (New-Pixels 16 @(119, 119, 119)) -Width 4 -Height 4).Variant 'middle gray'
    Assert-Equal 'night' (Measure-WallpaperFit -Pixels (New-Pixels 16 @(40, 40, 40)) -Width 4 -Height 4).Variant 'dark gray'
    foreach ($case in @(60, 'day'), @(59.9, 'both'), @(40.1, 'both'), @(40, 'night')) {
        Assert-Equal $case[1] (Get-WallpaperVariant -Lightness $case[0]) "lightness $($case[0])"
    }
}

Test 'Wallpaper: retry delays for a rate-limited download' {
    $now = [datetimeoffset]::new(2026, 11, 16, 12, 0, 0, [timespan]::Zero)
    Assert-Equal 5 (Get-WallpaperRetryDelay -Status 429 -Attempt 1) 'first retry, no Retry-After'
    Assert-Equal 20 (Get-WallpaperRetryDelay -Status 503 -Attempt 3) 'backs off by doubling'
    Assert-Equal 30 (Get-WallpaperRetryDelay -Status 429 -Attempt 1 -RetryAfter '30') 'Retry-After in seconds'
    Assert-Equal 45 (Get-WallpaperRetryDelay -Status 429 -Attempt 1 -RetryAfter 'Mon, 16 Nov 2026 12:00:45 GMT' -Now $now) 'Retry-After as a date'
    Assert-Equal 1 (Get-WallpaperRetryDelay -Status 429 -Attempt 1 -RetryAfter '0') 'never sooner than the gap'
    Assert-Equal 1 (Get-WallpaperRetryDelay -Status 429 -Attempt 1 -RetryAfter 'Mon, 16 Nov 2026 11:59:00 GMT' -Now $now) 'a date in the past'
    Assert-Equal 600 (Get-WallpaperRetryDelay -Status 429 -Attempt 1 -RetryAfter '600') 'a long Retry-After is honored, not cut short'
    Assert-Equal 40 (Get-WallpaperRetryDelay -Status 429 -Attempt 4) 'last retry without Retry-After'
    Assert-Equal 5 (Get-WallpaperRetryDelay -Status 429 -Attempt 1 -RetryAfter 'soon') 'unreadable Retry-After falls back'
    Assert-Equal -1 (Get-WallpaperRetryDelay -Status 404 -Attempt 1) '404 is not retried'
    Assert-Equal -1 (Get-WallpaperRetryDelay -Status 429 -Attempt 5) 'attempts spent'
}

Test 'Wallpaper: candidates filtered and ranked by variant' {
    $c = { param($Name, $L, $S, $D) [pscustomobject]@{ Name = $Name; Fit = @{ Lightness = $L; Saturation = $S; Detail = $D; Variant = (Get-WallpaperVariant -Lightness $L) } } }
    $all = @(
        (& $c 'busy-night' 20 10 3.0)
        (& $c 'calm-night' 25 5 0.2)
        (& $c 'dusk' 50 5 0.1)
        (& $c 'snow' 90 2 0.1)
    )
    Assert-Equal @('calm-night', 'busy-night', 'dusk') @((Select-WallpaperCandidate -Candidate $all -Variant night).Name) 'night: exact marks first, calmest first, then both'
    Assert-Equal @('snow', 'dusk') @((Select-WallpaperCandidate -Candidate $all -Variant day).Name) 'day'
    Assert-Equal @('dusk') @((Select-WallpaperCandidate -Candidate $all -Variant both).Name) 'both'
    Assert-Equal @('snow', 'dusk', 'calm-night', 'busy-night') @((Select-WallpaperCandidate -Candidate $all).Name) 'no variant: calmest first'
}

Test 'Wallpaper: folder needs thumbnails and credits' {
    $dir = Join-Path $Tmp ('wp-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path (Join-Path $dir 'thumbs') -Force | Out-Null
    Set-Content (Join-Path $dir 'good.jpg') 'x'; Set-Content (Join-Path $dir 'thumbs' 'good.jpg') 'x'
    Set-Content (Join-Path $dir 'bare.jpg') 'x'
    Set-Content (Join-Path $dir 'thumbs' 'orphan.jpg') 'x'
    Set-Content (Join-Path $dir 'README.md') @"
# Wallpapers

## Good

| File | [``good.jpg``](good.jpg) |
| Variant | Day |
| Author | A |
| Source | [S](https://example.invalid) |
| License | CC0 |

## Gone

| File | [``gone.jpg``](gone.jpg) |
"@
    $all = (Test-WallpaperFolder -Path $dir) -join "`n"
    foreach ($want in 'bare.jpg has no thumbs/bare.jpg', 'bare.jpg has no section', 'thumbs/orphan.jpg has no wallpaper', 'credits gone.jpg') {
        Assert-True ($all -like "*$want*") "expected '$want' in:`n$all"
    }
    Assert-True ($all -notlike '*good.jpg*') "good.jpg should pass:`n$all"
}

Test 'Wallpaper: folder needs a variant mark, and pairs of one day and one night' {
    $dir = Join-Path $Tmp ('wp-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path (Join-Path $dir 'thumbs') -Force | Out-Null
    foreach ($n in 'day', 'night', 'snow-a', 'snow-b', 'fog', 'odd', 'late-a', 'late-b') {
        Set-Content (Join-Path $dir "$n.jpg") 'x'; Set-Content (Join-Path $dir 'thumbs' "$n.jpg") 'x'
    }
    $image = { param($Name, $Mark) @"
| | |
|---|---|
| File | [``$Name.jpg``]($Name.jpg) |
$(if ($Mark) { "| Variant | $Mark |" })
| Author | A |
| Source | [S](https://example.invalid) |
| License | CC0 |
"@ }
    Set-Content (Join-Path $dir 'README.md') @"
# Wallpapers

## Dunes

### Day

$(& $image 'day' 'Day')

### Night

$(& $image 'night' 'Night')

## Snow

### One

$(& $image 'snow-a' 'Day')

### Two

$(& $image 'snow-b' 'day')

## Fog

$(& $image 'fog' 'Both')

## Odd

$(& $image 'odd' '')

## Late

### Day

$(& $image 'late-a' 'Day')

### Night

$(& $image 'late-b' 'Night')
"@
    $all = (Test-WallpaperFolder -Path $dir) -join "`n"
    foreach ($want in "the Snow pair needs one day and one night image", 'the odd.jpg section has no Variant', "the Late pair comes after a single image") {
        Assert-True ($all -like "*$want*") "expected '$want' in:`n$all"
    }
    foreach ($fine in 'Dunes', 'day.jpg', 'night.jpg', 'fog.jpg') { Assert-True ($all -notlike "*$fine*") "$fine should pass:`n$all" }
    Assert-Equal 3 @(Test-WallpaperFolder -Path $dir).Count "problems:`n$all"
}

Test 'Wallpaper: a port uses a wallpaper only for a variant it is marked for' {
    $dir = Join-Path $Tmp ('wp-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $image = { param($Name, $Mark) "## $Name`n`n| | |`n|---|---|`n| File | [``$Name.jpg``]($Name.jpg) |`n| Variant | $Mark |`n" }
    Set-Content (Join-Path $dir 'README.md') "# Wallpapers`n`n$(& $image 'snow' 'Day')`n$(& $image 'night' 'Night')`n$(& $image 'dusk' 'Both')"
    $url = { param($Name) "url(`"../../../../wallpapers/$Name.jpg`")" }
    $good = @{ night = @{ wallpaper = (& $url 'night') }; day = @{ wallpaper = (& $url 'snow'); other = (& $url 'dusk') } }
    Assert-Equal 0 @(Test-WallpaperUse -Path $dir -Values $good -Source 'values.json').Count 'marked uses pass'
    Assert-Equal 0 @(Test-WallpaperUse -Path $dir -Values @{ night = @{ wallpaper = 'none' } } -Source 'values.json').Count 'no wallpaper passes'
    $bad = @{ night = @{ wallpaper = (& $url 'snow') }; day = @{ wallpaper = (& $url 'gone') } }
    Assert-Equal @(
        "values.json: day uses gone.jpg, which wallpapers/README.md does not mark.",
        "values.json: night uses snow.jpg, which wallpapers/README.md marks day."
    ) @(Test-WallpaperUse -Path $dir -Values $bad -Source 'values.json') 'problems'
}

# --- Entry scripts --------------------------------------------------------------

# Each runs in its own pwsh, as a person would run it. Returns @{ Exit; Text }.
function Invoke-Script([string]$Name, [string[]]$Arguments) {
    $pwsh = (Get-Process -Id $PID).Path
    $out = & $pwsh -NoProfile -File (Join-Path $PSScriptRoot $Name) @Arguments 2>&1
    return @{ Exit = $LASTEXITCODE; Text = ($out | ForEach-Object { "$_" }) -join "`n" }
}

function New-TestImage([string]$Path, [int]$Width, [int]$Height) {
    # A plain gray binary PPM, which ImageSharp reads like a JPEG.
    $head = [System.Text.Encoding]::ASCII.GetBytes("P6`n$Width $Height`n255`n")
    $body = [byte[]]::new($Width * $Height * 3)
    [Array]::Fill($body, [byte]200)
    $fs = [System.IO.File]::Create($Path)
    try { $fs.Write($head, 0, $head.Length); $fs.Write($body, 0, $body.Length) } finally { $fs.Dispose() }
}

Test 'Entry: wallpaper.ps1 -Check passes a wide image and fails a small one' {
    # A local file, so nothing goes to Commons. ImageSharp is fetched once
    # from NuGet if it is not cached yet.
    $wide = Join-Path $Tmp 'wide.ppm'
    New-TestImage $wide 1920 1080
    $r = Invoke-Script 'wallpaper.ps1' @('-Check', $wide)
    Assert-Equal 0 $r.Exit "exit code, output:`n$($r.Text)"
    Assert-True ($r.Text -like '*Passes the format gate*') "no pass line in:`n$($r.Text)"
    Assert-True ($r.Text -like '*suggests day*') "no variant suggestion in:`n$($r.Text)"
    $small = Join-Path $Tmp 'small.ppm'
    New-TestImage $small 200 100
    $r = Invoke-Script 'wallpaper.ps1' @('-Check', $small)
    Assert-Equal 1 $r.Exit "exit code, output:`n$($r.Text)"
    Assert-True ($r.Text -like "*Fails:*- 200 px wide, needs at least 1920.*") "no reason in:`n$($r.Text)"
}

Test 'Entry: contrast.ps1 lists every measurement of the palette and passes' {
    $r = Invoke-Script 'contrast.ps1' @()
    Assert-Equal 0 $r.Exit "exit code, output:`n$($r.Text)"
    Assert-True ($r.Text -match '(?m)^day +text +base +\d+\.\d\d +7\.0 +pass$') "no day text on base line in:`n$($r.Text)"
    Assert-True ($r.Text -match '(\d+) measurements, 0 failing') "no summary in:`n$($r.Text)"
    $r = Invoke-Script 'contrast.ps1' @('-Table', '-Variant', 'night')
    Assert-True ($r.Text -like '*Night*firelight*on_accent*') "no table in:`n$($r.Text)"
}

Test 'Entry: contrast.ps1 -Set tries a value and fails it' {
    $r = Invoke-Script 'contrast.ps1' @('-Set', 'day.neutrals.text.l=0.6', '-Variant', 'day', '-Role', 'text', '-Surface', 'base')
    Assert-Equal 1 $r.Exit "exit code, output:`n$($r.Text)"
    Assert-True ($r.Text -match '(?m)^day +text +base +\d+\.\d\d +7\.0 +FAIL$') "no failing line in:`n$($r.Text)"
    $r = Invoke-Script 'contrast.ps1' @('-Set', 'day.neutrals.nope.l=0.5')
    Assert-Equal 2 $r.Exit "unknown path exit code, output:`n$($r.Text)"
}

Test 'Entry: roles.ps1 reports names and refuses unknown ones' {
    $r = Invoke-Script 'roles.ps1' @('-Role', 'accent')
    Assert-Equal 0 $r.Exit "exit code, output:`n$($r.Text)"
    $r = Invoke-Script 'roles.ps1' @('-Role', 'chartreuse')
    Assert-Equal 1 $r.Exit "unknown name exit code, output:`n$($r.Text)"
}

Test 'Entry: site.ps1 assembles the site with the ports page and the planned ports' {
    $out = Join-Path $Tmp 'site'
    $r = Invoke-Script 'site.ps1' @('-Out', $out)
    Assert-Equal 0 $r.Exit "exit code, output:`n$($r.Text)"
    Assert-True (Test-Path (Join-Path $out 'index.html')) 'no landing page'
    Assert-True (Test-Path (Join-Path $out 'ports' 'index.html')) 'no ports page'
    $js = Get-Content -Raw (Join-Path $out 'ports.js')
    Assert-True ($js -like '*window.THEME_PORTS*"planned":*') "no port list in ports.js"
}

# --- Summary ------------------------------------------------------------------

Remove-Item -Path $Tmp -Recurse -Force -ErrorAction SilentlyContinue
foreach ($f in $script:Failed) { Write-Host "FAIL: $f" -ForegroundColor Red }
Write-Host "$($script:Passed) passed, $($script:Failed.Count) failed."
if ($script:Failed.Count -gt 0) { exit 1 }
exit 0
