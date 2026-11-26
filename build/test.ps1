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

foreach ($m in 'Palette', 'Placeholders', 'Shell', 'Build', 'Catalog', 'Wallpaper', 'Png', 'Photographer', 'ScreenshotRun') {
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
    # A day yellow at l 0.45 cannot hold chroma 0.1045 in sRGB, but holds 0.09:
    # the bright slot lowers chroma to the gamut edge and stays yellow, not gray.
    $d = New-PaletteData
    $d.variants.day.colors.brass = [ordered]@{ l = 0.5; c = 0.095; h = 100 }
    $y = Get-AnsiColor 'bright_yellow' (Get-TestPalette $d).Variants['day']
    if ($y.C -lt 0.09 -or $y.C -gt 0.1) { throw "day bright yellow: chroma lowered to the gamut edge (0.09 to 0.1), got $($y.C)" }
    if ($y.Clip -gt 0.001) { throw "day bright yellow: inside sRGB, clip $($y.Clip)" }
    Assert-Equal 100.0 $y.H 'clipped bright keeps its hue'
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

Test 'Placeholders: comma gives r,g,b with no spaces, as ripgrep --colors takes it' {
    $d = New-PaletteData
    $d.variants.day.neutrals.base = [ordered]@{ l = 1; c = 0; h = 0 }
    $d.variants.day.colors.ember = [ordered]@{ l = 0; c = 0; h = 0 }
    $p = Get-TestPalette $d
    $out = Expand-Template -Text 'match:fg:{{error|comma}} match:bg:{{base|comma}}' -Palette $p -Variant $p.Variants['day'] -PortValues $null -Source 'test'
    Assert-Equal 'match:fg:0,0,0 match:bg:255,255,255' $out 'comma'
}

Test 'Placeholders: wash takes one format filter after it, as ripgrep needs a wash as r,g,b' {
    $d = New-PaletteData
    $d.variants.day.neutrals.base = [ordered]@{ l = 1; c = 0; h = 0 }
    $d.variants.day.colors.steel = [ordered]@{ l = 0; c = 0; h = 0 }
    $d.variants.day.wash = 0.5
    $p = Get-TestPalette $d
    $v = $p.Variants['day']
    Assert-Equal 'match:bg:128,128,128' (Expand-Template -Text 'match:bg:{{steel|wash|comma}}' -Palette $p -Variant $v -PortValues $null -Source 'test') 'wash then comma'
    Assert-Equal '48;2;128;128;128' (Expand-Template -Text '48;2;{{info | wash | sgr}}' -Palette $p -Variant $v -PortValues $null -Source 'test') 'through a role, with spaces'
    $errs = @(Find-PlaceholderError -Text '{{steel|comma|wash}} {{steel|wash|name}} {{text|wash|comma}} {{steel|wash|comma|sgr}}' -Palette $p -PortValues $null)
    Assert-Equal 4 $errs.Count "only a format filter follows wash, and only one ($($errs -join '; '))"
    Assert-Equal '{{steel|wash|comma|sgr}}' (Find-Placeholder 'a {{steel|wash|comma|sgr}}') 'three filters is still a placeholder, so it is caught as a leftover'
}

Test 'Placeholders: sgr gives the r;g;b of an escape code' {
    $p = Get-TestPalette (New-PaletteData)
    $v = $p.Variants['day']
    $rgb = (Expand-Template -Text '{{moss|rgb}}' -Palette $p -Variant $v -PortValues $null -Source 'test') -replace ', ', ';'
    Assert-Equal "38;2;$rgb" (Expand-Template -Text '38;2;{{moss|sgr}}' -Palette $p -Variant $v -PortValues $null -Source 'test') 'sgr'
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

Test 'Build: a .env template becomes a .sh and a .ps1 with the same values' {
    $port = New-TestPort 'envport' @{ 'tool.env' = "# Test for tool, {{variant.name}}.`n`nTOOL_COLORS=fg:{{base}} --x`nTOOL_OTHER=a b`n" }
    $p = Get-TestPalette (New-PaletteData)
    $r = Update-Port -Palette $p -PortDir $port
    Assert-Equal 4 $r.Written 'files written'
    $hex = $p.Variants['night'].Neutrals['base'].Hex
    $sh = Get-Content -Raw (Join-Path $port 'dist' 'night' 'tool.sh')
    Assert-Equal "# Test for tool, Test Night.`n`nexport TOOL_COLORS='fg:$hex --x'`nexport TOOL_OTHER='a b'`n" $sh 'sh'
    $ps1 = Get-Content -Raw (Join-Path $port 'dist' 'night' 'tool.ps1')
    Assert-Equal "# Test for tool, Test Night.`n`n`$env:TOOL_COLORS = 'fg:$hex --x'`n`$env:TOOL_OTHER = 'a b'`n" $ps1 'ps1'
    Assert-True (-not (Test-Path (Join-Path $port 'dist' 'night' 'tool.env'))) 'the .env itself is not shipped'
    Assert-Equal 'unchanged' (Get-PortStatus -Palette $p -PortDir $port).Status 'rebuild'
}

Test 'Build: a .env line that is not NAME=value, or a value with a quote, does not build' {
    $p = Get-TestPalette (New-PaletteData)
    $bad = New-TestPort 'envbad' @{ 'tool.env' = "# ok`nexport X=1`n" }
    Assert-Throws { Update-Port -Palette $p -PortDir $bad } '*envbad/template/tool.env:2*NAME=value*'
    $quote = New-TestPort 'envquote' @{ 'tool.env' = "X=it's`n" }
    Assert-Throws { Update-Port -Palette $p -PortDir $quote } '*envquote/template/tool.env:1*single quote*'
}

Test 'Build: CRLF in dist is not drift' {
    $port = New-TestPort 'crlf' @{ 'a.txt' = "one`ntwo" }
    $p = Get-TestPalette (New-PaletteData)
    $null = Update-Port -Palette $p -PortDir $port
    Set-Content -Path (Join-Path $port 'dist' 'day' 'a.txt') -Value "one`r`ntwo" -NoNewline
    Assert-Equal 'unchanged' (Get-PortStatus -Palette $p -PortDir $port).Status 'status'
}

# --- Shell files ----------------------------------------------------------------

function New-ShellFile([string]$Name, [string]$Text) {
    $path = Join-Path $Tmp 'shell' $Name
    New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
    Set-Content -Path $path -Value $Text -NoNewline
    return $path
}
$HaveBash = [bool](Get-Command bash -CommandType Application -ErrorAction SilentlyContinue)
$HaveZsh  = [bool](Get-Command zsh -CommandType Application -ErrorAction SilentlyContinue)

Test 'Shell: a clean file in each shell has no problems' {
    foreach ($f in @(
        (New-ShellFile 'ok.sh' "# a comment`nexport TOOL_X='a b'`n"),
        (New-ShellFile 'ok.zsh' "typeset -gA TOOL_STYLES`nTOOL_STYLES[comment]='fg=8'`n"),
        (New-ShellFile 'ok.ps1' "`$env:TOOL_X = 'a b'`n"))) {
        $r = Test-ShellFile -Path $f
        Assert-Equal 0 $r.Problems.Count "problems in $(Split-Path -Leaf $f): $($r.Problems -join '; ')"
    }
}

Test 'Shell: a .sh is checked in both bash and zsh' {
    $r = Test-ShellFile -Path (New-ShellFile 'bashonly.sh' "shopt -s nullglob`n")
    if ($HaveZsh) { Assert-True (($r.Problems -join "`n") -like 'zsh:*shopt*') "zsh did not object: $($r.Problems -join '; ')" }
    else { Assert-True ('zsh' -in $r.Skipped) 'zsh missing but not skipped' }
    if ($HaveBash) { Assert-Equal 0 @($r.Problems | Where-Object { $_ -like 'bash:*' }).Count "bash objected: $($r.Problems -join '; ')" }
    $r = Test-ShellFile -Path (New-ShellFile 'syntax.sh' "if then`n")
    if ($HaveBash) { Assert-True (($r.Problems -join "`n") -like '*bash*') "bash did not object to a syntax error" }
}

Test 'Shell: sourcing must print nothing' {
    $r = Test-ShellFile -Path (New-ShellFile 'noisy.sh' "echo hello`n")
    if ($HaveBash) { Assert-True (($r.Problems -join "`n") -like '*bash*hello*') "no bash problem: $($r.Problems -join '; ')" }
    $r = Test-ShellFile -Path (New-ShellFile 'noisy.ps1' "Write-Output hello`n")
    Assert-True (($r.Problems -join "`n") -like '*PowerShell*hello*') "no PowerShell problem: $($r.Problems -join '; ')"
}

Test 'Shell: a script with a shebang is parsed by its shell, never sourced' {
    # An install script prints and changes settings when it runs, so sourcing it is wrong.
    $r = Test-ShellFile -Path (New-ShellFile 'install.sh' "#!/usr/bin/env bash`nshopt -s nullglob`necho installed`n")
    Assert-Equal 0 $r.Problems.Count "problems: $($r.Problems -join '; ')"
    Assert-Equal 0 $r.Skipped.Count "skipped a shell the shebang does not name: $($r.Skipped -join ', ')"
    $r = Test-ShellFile -Path (New-ShellFile 'broken.sh' "#!/usr/bin/env bash`nif then`n")
    if ($HaveBash) { Assert-True (($r.Problems -join "`n") -like 'bash: does not parse*') "bash did not object: $($r.Problems -join '; ')" }
}

Test 'Shell: a .ps1 that does not parse is a problem' {
    $r = Test-ShellFile -Path (New-ShellFile 'bad.ps1' "`$env:X = 'a`n")
    Assert-True (($r.Problems -join "`n") -like '*does not parse*') "no parse problem: $($r.Problems -join '; ')"
}

Test 'Shell: a .env-built port sources cleanly in every shell' {
    $port = New-TestPort 'envsrc' @{ 'tool.env' = "TOOL_COLORS=--color=bg:{{base}},fg:{{text}} --border`n" }
    $null = Update-Port -Palette (Get-TestPalette (New-PaletteData)) -PortDir $port
    foreach ($f in Get-ChildItem (Join-Path $port 'dist') -Recurse -File) {
        $r = Test-ShellFile -Path $f.FullName
        Assert-Equal 0 $r.Problems.Count "problems in $($f.Name): $($r.Problems -join '; ')"
    }
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

function Set-Recipe([string]$Root, [string]$Name, $Recipe) {
    ConvertTo-Json -InputObject $Recipe -Depth 6 | Set-Content (Join-Path $Root $Name 'screenshot.json')
}
function New-GoodRecipe {
    return [ordered]@{
        kind = 'terminal'; platform = 'linux'; version = '1.0'
        install = @('apt-get install -y app'); apply = @('bash $INGLENOOK_PORT/dist/$INGLENOOK_VARIANT/install.sh')
        stage = @('true'); launch = @('app -- $INGLENOOK_SCENE/run.sh'); window = [ordered]@{ class = 'app' }
    }
}

Test 'Catalog: a valid recipe is kept' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @() } @{ good = $GoodMeta }
    Set-Recipe $root 'good' (New-GoodRecipe)
    $c = Get-PortCatalog -PortsRoot $root
    Assert-Equal 0 $c.Errors.Count "errors: $($c.Errors -join '; ')"
    Assert-Equal 0 $c.RecipeErrors.Count "recipe errors: $($c.RecipeErrors -join '; ')"
    $good = $c.Ports | Where-Object Name -eq 'good'
    Assert-Equal 'terminal' $good.Recipe['kind'] 'recipe kind'
}

Test 'Catalog: every port has a recipe or a shot list' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @(); unlisted = @('hidden') } @{ good = $GoodMeta; bare = $GoodMeta; hidden = $null }
    Set-Recipe $root 'good' (New-GoodRecipe)
    $c = Get-PortCatalog -PortsRoot $root
    $all = $c.RecipeErrors -join "`n"
    foreach ($want in 'Ports/bare has no screenshot.json', 'Ports/hidden has no screenshot.json') {
        Assert-True ($all -like "*$want*") "expected an error like '$want' in:`n$all"
    }
    Assert-True ($all -notlike '*Ports/good*') "port with a recipe flagged:`n$all"
    Assert-Equal $null ($c.Ports | Where-Object Name -eq 'bare').Recipe 'no recipe'
}

Test 'Catalog: reports bad recipes' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @() } `
        @{ odd = $GoodMeta; desk = $GoodMeta; nowin = $GoodMeta; twowin = $GoodMeta; steps = $GoodMeta; manual = $GoodMeta; badmanual = $GoodMeta }
    $r = New-GoodRecipe; $r.timeout = 30; $r.kind = 'movie'; $r.platform = 'amiga'; Set-Recipe $root 'odd' $r
    $r = New-GoodRecipe; $r.kind = 'desktop'; Set-Recipe $root 'desk' $r
    $r = New-GoodRecipe; $r.Remove('window'); $r.Remove('launch'); Set-Recipe $root 'nowin' $r
    $r = New-GoodRecipe; $r.window = @{ class = 'a'; title = 'b' }; Set-Recipe $root 'twowin' $r
    $r = New-GoodRecipe; $r.apply = 'one line'; $r.stage = @(1, ''); $r.version = 2; Set-Recipe $root 'steps' $r
    Set-Recipe $root 'manual' ([ordered]@{ kind = 'document'; platform = 'windows'; manual = 'Needs a license.' })
    Set-Recipe $root 'badmanual' ([ordered]@{ kind = 'document'; platform = 'windows'; manual = ''; install = @('x') })
    $c = Get-PortCatalog -PortsRoot $root
    $all = $c.RecipeErrors -join "`n"
    foreach ($want in "odd/screenshot.json has an unknown field 'timeout'", "odd/screenshot.json has kind 'movie'",
                      "odd/screenshot.json has platform 'amiga'", 'desk/screenshot.json is a desktop recipe, so it takes no ''window''',
                      "nowin/screenshot.json needs 'launch'", "nowin/screenshot.json needs 'window'",
                      "twowin/screenshot.json needs 'window' with one of 'class' or 'title'",
                      "steps/screenshot.json needs 'apply' as a list of shell lines", "steps/screenshot.json needs 'stage' as a list of shell lines",
                      "steps/screenshot.json has a 'version' that is not text",
                      "badmanual/screenshot.json is a manual recipe, so it takes no 'install'", "badmanual/screenshot.json needs 'manual'") {
        Assert-True ($all -like "*$want*") "expected an error like '$want' in:`n$all"
    }
    Assert-True ($all -notmatch '(?m)^Ports/manual/') "manual recipe flagged:`n$all"
    Assert-Equal $null ($c.Ports | Where-Object Name -eq 'odd').Recipe 'invalid recipe dropped'
    Assert-Equal 'Needs a license.' ($c.Ports | Where-Object Name -eq 'manual').Recipe['manual'] 'manual recipe kept'
}

Test 'Catalog: a guest names a host on the same platform and has only install, apply and stage' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @() } `
        @{ term = $GoodMeta; prompt = $GoodMeta; win = $GoodMeta; lost = $GoodMeta; staged = $GoodMeta; busy = $GoodMeta; nested = $GoodMeta }
    Set-Recipe $root 'term' (New-GoodRecipe)
    $guest = { param($h) [ordered]@{ kind = 'prompt'; platform = 'linux'; host = $h; version = '2'; install = @('i'); apply = @('a') } }
    Set-Recipe $root 'prompt' (& $guest 'term')
    $r = New-GoodRecipe; $r.platform = 'windows'; Set-Recipe $root 'win' $r
    Set-Recipe $root 'lost' (& $guest 'win')
    $r = & $guest 'term'; $r.stage = @('s'); Set-Recipe $root 'staged' $r
    $r = & $guest 'term'; $r.launch = @('l'); $r.window = @{ class = 'x' }; Set-Recipe $root 'busy' $r
    Set-Recipe $root 'nested' (& $guest 'prompt')
    $c = Get-PortCatalog -PortsRoot $root
    $all = $c.RecipeErrors -join "`n"
    foreach ($want in "lost/screenshot.json has host 'win', which is shot on windows, not linux",
                      "busy/screenshot.json has a host, so it takes no 'launch'", "busy/screenshot.json has a host, so it takes no 'window'",
                      "nested/screenshot.json has host 'prompt', which is itself a guest") {
        Assert-True ($all -like "*$want*") "expected an error like '$want' in:`n$all"
    }
    Assert-True ($all -notlike '*Ports/prompt/*') "good guest flagged:`n$all"
    Assert-True ($all -notlike '*Ports/staged/*') "guest with stage flagged:`n$all"
    Assert-Equal 'term' ($c.Ports | Where-Object Name -eq 'prompt').Recipe['host'] 'guest kept'
    Set-Recipe $root 'prompt' (& $guest 'ghost')
    $all = (Get-PortCatalog -PortsRoot $root).RecipeErrors -join "`n"
    Assert-True ($all -like "*prompt/screenshot.json has host 'ghost', which has no screenshot.json*") "missing host not reported:`n$all"
}

function Set-ShotList([string]$Root, [string]$Name, $List) {
    ConvertTo-Json -InputObject $List -Depth 6 | Set-Content (Join-Path $Root $Name 'shots.json')
}
function New-GoodShotList {
    return [ordered]@{ shots = @(
        [ordered]@{ name = 'day'; variant = 'day'; show = 'top' }
        [ordered]@{ name = 'night'; variant = 'night'; show = 'top' }
        [ordered]@{ name = 'roles'; variant = 'night'; show = 'Roles' }
    ) }
}

Test 'Catalog: a valid shot list is kept, in order' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @(); unlisted = @('preview') } @{ preview = $null }
    Set-ShotList $root 'preview' (New-GoodShotList)
    $c = Get-PortCatalog -PortsRoot $root
    Assert-Equal 0 $c.RecipeErrors.Count "errors: $($c.RecipeErrors -join '; ')"
    $p = $c.Ports | Where-Object Name -eq 'preview'
    Assert-Equal @('day', 'night', 'roles') @($p.Shots | ForEach-Object { $_['name'] }) 'shots'
    Assert-Equal 'Roles' $p.Shots[2]['show'] 'section'
    Assert-Equal $null $p.Recipe 'no recipe'
}

Test 'Catalog: reports bad shot lists' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; planned = @() } @{ odd = $GoodMeta; twice = $GoodMeta; onevar = $GoodMeta; both = $GoodMeta; empty = $GoodMeta }
    $l = New-GoodShotList; $l.extra = 1; $l.shots[0].size = 2; $l.shots[1].name = 'Night.png'; $l.shots[2].variant = 'dusk'; $l.shots[2].show = ' '
    Set-ShotList $root 'odd' $l
    $l = New-GoodShotList; $l.shots[2].name = 'night'; Set-ShotList $root 'twice' $l
    Set-ShotList $root 'onevar' ([ordered]@{ shots = @([ordered]@{ name = 'day'; variant = 'day'; show = 'top' }) })
    Set-ShotList $root 'both' (New-GoodShotList); Set-Recipe $root 'both' (New-GoodRecipe)
    Set-ShotList $root 'empty' ([ordered]@{ shots = @() })
    $c = Get-PortCatalog -PortsRoot $root
    $all = $c.RecipeErrors -join "`n"
    foreach ($want in "odd/shots.json has an unknown field 'extra'", "odd/shots.json shots?0? has an unknown field 'size'",
                      "odd/shots.json shots?1? needs 'name'", "odd/shots.json shots?2? needs 'variant'", "odd/shots.json shots?2? needs 'show'",
                      "twice/shots.json names 'night' twice", 'onevar/shots.json has no night shot', 'both/shots.json and screenshot.json are both here',
                      "empty/shots.json needs 'shots'") {
        Assert-True ($all -like "*$want*") "expected an error like '$want' in:`n$all"
    }
    Assert-Equal 0 @($c.Ports | Where-Object Shots).Count 'invalid lists dropped'
}

# --- Photographer ---------------------------------------------------------------

function Get-PlanLines($Steps) { @($Steps | ForEach-Object { "$($_.Port) $($_.Phase) $($_.Line)" }) }

Test 'Catalog: a port the Photographer shoots ships with every image' {
    $root = New-TestPorts @{ categories = @{ editor = 'Editors' }; unlisted = @('preview'); planned = @() } @{ good = $GoodMeta; plain = $GoodMeta; preview = $null }
    Set-Recipe $root 'good' (New-GoodRecipe)
    Set-ShotList $root 'preview' (New-GoodShotList)
    $c = Get-PortCatalog -PortsRoot $root
    $all = @(Get-ShotProblems $c) -join "`n"
    foreach ($want in 'Ports/good/screenshots/day.png is missing', 'Ports/good/screenshots/night.png is missing',
                      'Ports/preview/screenshots/roles.png is missing', 'photograph.ps1 -Port good') {
        Assert-True ($all -like "*$want*") "expected '$want' in:`n$all"
    }
    Assert-True ($all -notlike '*Ports/plain/*') 'a port with no recipe is the recipe check''s to report'
    foreach ($p in 'good/screenshots/day.png', 'good/screenshots/night.png') {
        New-Item -ItemType Directory -Path (Split-Path (Join-Path $root $p)) -Force | Out-Null
        Set-Content (Join-Path $root $p) 'png'
    }
    Assert-True (@(Get-ShotProblems (Get-PortCatalog -PortsRoot $root)) -notlike '*Ports/good/*') 'both images there'
    $m = [ordered]@{ kind = 'document'; platform = 'linux'; manual = 'Needs a license.' }
    Set-Recipe $root 'plain' $m
    Assert-True ((@(Get-ShotProblems (Get-PortCatalog -PortsRoot $root)) -join ' ') -like '*plain/screenshots/day.png is missing*take it by hand*') 'a manual port is told to take them by hand'
}

Test 'Photographer: a port''s own steps, in order' {
    $plan = Get-ShotPlan -Port 'term' -Recipe (New-GoodRecipe)
    Assert-Equal @('term install apt-get install -y app') (Get-PlanLines $plan.Install) 'install'
    Assert-Equal @('term apply bash $INGLENOOK_PORT/dist/$INGLENOOK_VARIANT/install.sh', 'term stage true', 'term launch app -- $INGLENOOK_SCENE/run.sh') (Get-PlanLines $plan.Shot) 'shot'
    Assert-Equal 'terminal' $plan.Kind 'scene kind'
    Assert-Equal 'class' $plan.Window.Kind 'window kind'
    Assert-Equal 'app' $plan.Window.Match 'window match'
}

Test 'Photographer: a guest runs inside its host' {
    $guest = [ordered]@{ kind = 'prompt'; platform = 'linux'; host = 'term'; version = '2'; install = @('gi'); apply = @('ga') }
    $plan = Get-ShotPlan -Port 'prompt' -Recipe $guest -HostPort 'term' -HostRecipe (New-GoodRecipe)
    Assert-Equal @('term install apt-get install -y app', 'prompt install gi') (Get-PlanLines $plan.Install) 'install: host first'
    Assert-Equal @('term apply bash $INGLENOOK_PORT/dist/$INGLENOOK_VARIANT/install.sh', 'term stage true', 'prompt apply ga', 'term launch app -- $INGLENOOK_SCENE/run.sh') `
        (Get-PlanLines $plan.Shot) 'shot: host apply and stage, guest apply, host launch'
    Assert-Equal @('1.0', '2') @($plan.Install | ForEach-Object Version) 'each port keeps its own version'
    Assert-Equal 'prompt' $plan.Kind 'the guest''s scene kind'
    Assert-Equal 'app' $plan.Window.Match 'the host''s window'
}

Test 'Photographer: every guest follows one step order, whatever its host' {
    $hostRecipe = [ordered]@{ kind = 'editor'; platform = 'linux'; install = @('hi1', 'hi2'); apply = @('ha1', 'ha2'); stage = @('hs1', 'hs2')
        launch = @('hl1', 'hl2'); window = @{ title = 'Editor$' } }
    $guest = [ordered]@{ kind = 'icon-theme'; platform = 'linux'; host = 'ed'; install = @('gi1', 'gi2'); apply = @('ga1', 'ga2')
        stage = @('gs1', 'gs2'); launch = @('ignored'); window = @{ class = 'ignored' } }
    $plan = Get-ShotPlan -Port 'icons' -Recipe $guest -HostPort 'ed' -HostRecipe $hostRecipe
    Assert-Equal @('ed install hi1', 'ed install hi2', 'icons install gi1', 'icons install gi2') (Get-PlanLines $plan.Install) 'install: host, then guest'
    Assert-Equal @('ed apply ha1', 'ed apply ha2', 'ed stage hs1', 'ed stage hs2', 'icons apply ga1', 'icons apply ga2', 'icons stage gs1', 'icons stage gs2', 'ed launch hl1', 'ed launch hl2') `
        (Get-PlanLines $plan.Shot) 'shot: host apply and stage, guest apply and stage, host launch; never the guest''s launch'
    Assert-Equal @(1, 2, 1, 2, 1, 2, 1, 2, 1, 2) @($plan.Shot | ForEach-Object Number) 'steps numbered within their own recipe and phase'
    Assert-Equal 'icon-theme' $plan.Kind 'the guest''s scene kind'
    Assert-Equal 'title Editor$' "$($plan.Window.Kind) $($plan.Window.Match)" 'the host''s window, never the guest''s'
}

Test 'Photographer: install steps become the port image, run as root, one layer each' {
    $guest = [ordered]@{ kind = 'prompt'; platform = 'linux'; host = 'term'; install = @('echo "it''s $INGLENOOK_VERSION"'); apply = @('a') }
    $plan = Get-ShotPlan -Port 'prompt' -Recipe $guest -HostPort 'term' -HostRecipe (New-GoodRecipe)
    $text = ConvertTo-PortDockerfile -Base 'inglenook-photograph-base' -Steps $plan.Install
    $want = @(
        'FROM inglenook-photograph-base'
        'USER root'
        'ENV INGLENOOK_VERSION="1.0"'
        'RUN ["bash","-euo","pipefail","-c","apt-get install -y app"]'
        'ENV INGLENOOK_VERSION=""'
        'RUN ["bash","-euo","pipefail","-c","echo \"it''s $INGLENOOK_VERSION\""]'
    )
    Assert-Equal $want @($text -split "`n" | Where-Object { $_ -and $_ -notlike '#*' }) 'Dockerfile'
}

Test 'Photographer: shot steps become one bash script with exactly four variables' {
    $guest = [ordered]@{ kind = 'prompt'; platform = 'linux'; host = 'term'; version = '2'; install = @(); apply = @('echo ''hi''') }
    $plan = Get-ShotPlan -Port 'prompt' -Recipe $guest -HostPort 'term' -HostRecipe (New-GoodRecipe)
    $text = ConvertTo-StepScript -Steps $plan.Shot -Kind $plan.Kind -Variant 'night' -RepoRoot '/inglenook'
    $calls = @($text -split "`n" | Where-Object { $_ -like 'step *' })
    Assert-Equal @(
        "step 'term' 'apply' '1' '1.0' 'bash `$INGLENOOK_PORT/dist/`$INGLENOOK_VARIANT/install.sh'"
        "step 'term' 'stage' '1' '1.0' 'true'"
        "step 'prompt' 'apply' '1' '2' 'echo '\''hi'\'''"
        "step 'term' 'launch' '1' '1.0' 'app -- `$INGLENOOK_SCENE/run.sh'"
    ) $calls 'steps in order, quoted for bash'
    Assert-True ($text -match "(?m)^cd '/inglenook'$") 'runs from the repo root'
    Assert-True ($text -match "(?m)^export INGLENOOK_VARIANT='night' INGLENOOK_SCENE='/inglenook/build/photograph/scenes/prompt'$") 'variant and scene'
    Assert-True ($text -match 'INGLENOOK_PORT="/inglenook/Ports/\$1" INGLENOOK_VERSION="\$4"') 'port folder and version per step'
    $names = @([regex]::Matches($text, 'INGLENOOK_[A-Z]+') | ForEach-Object Value | Sort-Object -Unique)
    Assert-Equal @('INGLENOOK_PORT', 'INGLENOOK_SCENE', 'INGLENOOK_VARIANT', 'INGLENOOK_VERSION') $names 'no other variables'
}

Test 'Photographer: the crop is the window frame plus a 64 px margin, inside the screen' {
    $c = Get-ShotCrop -Kind 'terminal' -Frame @{ X = 250; Y = 150; Width = 1100; Height = 700 }
    Assert-Equal '1228x828+186+86' "$($c.Width)x$($c.Height)+$($c.X)+$($c.Y)" 'margin on every side'
    $c = Get-ShotCrop -Kind 'editor' -Frame @{ X = 20; Y = 900; Width = 1560; Height = 300 }
    Assert-Equal '1600x164+0+836' "$($c.Width)x$($c.Height)+$($c.X)+$($c.Y)" 'clipped to the 1600x1000 screen'
    $c = Get-ShotCrop -Kind 'desktop'
    Assert-Equal '1000x625+0+375' "$($c.Width)x$($c.Height)+$($c.X)+$($c.Y)" 'desktop: fixed bottom-left area'
}

Test 'Photographer: a take''s scene settings, for a window and for a desktop' {
    $fill = [pscustomobject]@{ Kind = 'fill'; Name = 'deeper'; Value = '#123456' }
    $plan = Get-ShotPlan -Port 'term' -Recipe (New-GoodRecipe)
    $s = Get-SceneEnv -Plan $plan -Variant 'day' -RecipeFile 'Ports/term/screenshot.json' -Backdrop $fill
    Assert-Equal @('KIND', 'SCREEN', 'BACKDROP_KIND', 'BACKDROP', 'GTK_THEME', 'TIMEOUT', 'RECIPE', 'WINDOW_KIND', 'WINDOW_MATCH', 'SETTLE') @($s.Keys) 'window scene keys'
    Assert-Equal 8 $s.SETTLE 'a window scene is settled when the screen stays still for 8 s'
    Assert-Equal 'terminal' $s.KIND 'kind'
    Assert-Equal '1600x1000' $s.SCREEN 'screen'
    Assert-Equal 'fill #123456' "$($s.BACKDROP_KIND) $($s.BACKDROP)" 'backdrop'
    Assert-Equal 'Adwaita' $s.GTK_THEME 'day: the light stock frame through GTK_THEME'
    Assert-Equal 'Adwaita:dark' (Get-SceneEnv -Plan $plan -Variant 'night' -RecipeFile 'x' -Backdrop $fill).GTK_THEME 'night: the dark stock frame'
    Assert-Equal 'class' $s.WINDOW_KIND 'window kind'
    Assert-Equal 'app' $s.WINDOW_MATCH 'window match'
    Assert-Equal 'Ports/term/screenshot.json' $s.RECIPE 'recipe named in failures'

    $desk = New-GoodRecipe; $desk.kind = 'desktop'; $desk.Remove('window')
    $plan = Get-ShotPlan -Port 'desk' -Recipe $desk
    $image = [pscustomobject]@{ Kind = 'image'; Name = 'a.jpg'; Value = 'wallpapers/a.jpg' }
    $s = Get-SceneEnv -Plan $plan -Variant 'night' -RecipeFile 'Ports/desk/screenshot.json' -Backdrop $image
    Assert-Equal @('KIND', 'SCREEN', 'BACKDROP_KIND', 'BACKDROP', 'GTK_THEME', 'TIMEOUT', 'RECIPE', 'FRAME_THEME', 'CLOCK') @($s.Keys) 'desktop scene keys: no window'
    Assert-Equal 'image wallpapers/a.jpg' "$($s.BACKDROP_KIND) $($s.BACKDROP)" 'a wallpaper backdrop'
    Assert-Equal 'Adwaita-dark' $s.FRAME_THEME 'night frame by theme name'
    Assert-Equal 'Adwaita' (Get-SceneEnv -Plan $plan -Variant 'day' -RecipeFile 'x' -Backdrop $image).FRAME_THEME 'day frame by theme name'
    Assert-Equal '2026-06-01 09:41:00' $s.CLOCK 'fixed clock'
}

Test 'Photographer: a Windows take has the system frame in the variant''s mode, on a screen the runner offers' {
    $r = New-GoodRecipe; $r.platform = 'windows'; $r.window = [ordered]@{ class = 'CASCADIA_HOSTING_WINDOW_CLASS' }
    $plan = Get-ShotPlan -Port 'wt' -Recipe $r
    Assert-Equal 'windows' $plan.Platform 'platform'
    $fill = [pscustomobject]@{ Kind = 'fill'; Name = 'deeper'; Value = '#123456' }
    $s = Get-SceneEnv -Plan $plan -Variant 'night' -RecipeFile 'Ports/wt/screenshot.json' -Backdrop $fill
    Assert-Equal @('KIND', 'SCREEN', 'BACKDROP_KIND', 'BACKDROP', 'MODE', 'TIMEOUT', 'RECIPE', 'WINDOW_KIND', 'WINDOW_MATCH') @($s.Keys) 'Windows scene keys: no GTK_THEME'
    Assert-Equal '1920x1080' $s.SCREEN 'a size the runner offers'
    Assert-Equal 'dark' $s.MODE 'night is Windows dark mode'
    Assert-Equal 'light' (Get-SceneEnv -Plan $plan -Variant 'day' -RecipeFile 'x' -Backdrop $fill).MODE 'day is Windows light mode'
    Assert-Equal '#123456' $s.BACKDROP 'same backdrop as Linux'
    Assert-Equal 'CASCADIA_HOSTING_WINDOW_CLASS' $s.WINDOW_MATCH 'window'
    Assert-Equal 'linux' (Get-ShotPlan -Port 'term' -Recipe (New-GoodRecipe)).Platform 'Linux plan'
    $c = Get-ShotCrop -Kind 'terminal' -Frame @{ X = 20; Y = 900; Width = 1880; Height = 300 } -Platform 'windows'
    Assert-Equal '1920x244+0+836' "$($c.Width)x$($c.Height)+$($c.X)+$($c.Y)" 'clipped to the 1920x1080 screen'
}

Test 'Photographer: Windows steps become one pwsh script with exactly four variables' {
    $r = New-GoodRecipe; $r.platform = 'windows'; $r.version = '1.25'
    $r.apply = @("Write-Output ""it's `$env:INGLENOOK_VARIANT""", "Write-Output $([char]0x2019)curly$([char]0x2019)"); $r.launch = @('Start-Process app')
    $plan = Get-ShotPlan -Port 'wt' -Recipe $r
    $text = ConvertTo-WindowsStepScript -Steps $plan.Shot -Kind $plan.Kind -Variant 'day' -RepoRoot 'D:\a\repo\' -Logs 'D:\work'
    $calls = @($text -split "`n" | Where-Object { $_ -like 'Step *' })
    $q = [string][char]0x2019
    Assert-Equal @(
        "Step 'wt' 'apply' '1' '1.25' 'Write-Output ""it''s `$env:INGLENOOK_VARIANT""'"
        "Step 'wt' 'apply' '2' '1.25' 'Write-Output $q${q}curly$q$q'"
        "Step 'wt' 'stage' '1' '1.25' 'true'"
        "Step 'wt' 'launch' '1' '1.25' 'Start-Process app'"
    ) $calls 'steps in order, quoted for PowerShell'
    Assert-True ($text -match "(?m)^Set-Location -LiteralPath 'D:\\a\\repo'$") "runs from the repo root:`n$text"
    Assert-True ($text -match "(?m)^\`$env:INGLENOOK_VARIANT = 'day'$") 'variant'
    Assert-True ($text -match "(?m)^\`$env:INGLENOOK_SCENE = 'D:\\a\\repo\\build\\photograph\\scenes\\terminal'$") 'scene'
    $names = @([regex]::Matches($text, 'INGLENOOK_[A-Z]+') | ForEach-Object Value | Sort-Object -Unique)
    Assert-Equal @('INGLENOOK_PORT', 'INGLENOOK_SCENE', 'INGLENOOK_VARIANT', 'INGLENOOK_VERSION') $names 'no other variables'
    $install = ConvertTo-WindowsStepScript -Steps $plan.Install -Kind $plan.Kind -RepoRoot 'D:\a\repo' -Logs 'D:\work'
    Assert-True ($install -notmatch 'INGLENOOK_VARIANT|INGLENOOK_SCENE') 'install steps get no variant or scene'
    Assert-True ($install -match "(?m)^Step 'wt' 'install' '1' '1.25' 'apt-get install -y app'$") 'install step'
}

Test 'Photographer: a Windows step script runs each step, and a failed one names the recipe and its last lines' {
    $root = Join-Path $Tmp ('winsteps-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $root | Out-Null
    $steps = @(
        [pscustomobject]@{ Port = 'wt'; Phase = 'apply'; Number = 1; Version = '9.9'; Line = 'Write-Output "$env:INGLENOOK_VARIANT $env:INGLENOOK_VERSION $(Split-Path -Leaf $env:INGLENOOK_PORT) $(Split-Path -Leaf $env:INGLENOOK_SCENE)"' }
        [pscustomobject]@{ Port = 'wt'; Phase = 'stage'; Number = 1; Version = '9.9'; Line = 'Write-Output ''last words''; Get-Item ''no-such-file''; Write-Output ''unreached''' }
        [pscustomobject]@{ Port = 'wt'; Phase = 'stage'; Number = 2; Version = '9.9'; Line = 'Write-Output unreached' }
    )
    $script = Join-Path $root 'steps.ps1'
    Set-Content -Path $script -Value (ConvertTo-WindowsStepScript -Steps $steps -Kind 'terminal' -Variant 'night' -RepoRoot $root -Logs $root)
    $out = @(& pwsh -NoProfile -NonInteractive -File $script 2>&1 | ForEach-Object { "$_" })
    Assert-Equal 1 $LASTEXITCODE 'exit code'
    Assert-Equal 'night 9.9 wt terminal' ((Get-Content (Join-Path $root 'step-wt-apply-1.log')) -join '') 'four variables reach the step'
    $all = $out -join "`n"
    Assert-True ($all -like '*Ports/wt/screenshot.json, stage step 1 failed:*' -and $all -like '*last words*' -and $all -like '*no-such-file*') "failure: $all"
    Assert-True (-not (Test-Path (Join-Path $root 'step-wt-stage-2.log'))) 'stops at the failed step'
    Assert-True ((Get-Content -Raw (Join-Path $root 'step-wt-stage-1.log')) -notmatch '(?m)^unreached') 'an error stops the step'
}

Test 'Photographer: a Windows take finds the app''s window, never the runner''s own terminal' {
    $own = 'C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.23\WindowsTerminal.exe'
    $app = 'C:\Users\runner\AppData\Local\Programs\terminal-1.25\WindowsTerminal.exe'
    $windows = @(
        @{ Handle = 1; Class = 'CASCADIA_HOSTING_WINDOW_CLASS'; Title = 'Runner'; Path = $own }
        @{ Handle = 2; Class = 'Shell_TrayWnd'; Title = ''; Path = $null }
        @{ Handle = 3; Class = 'CASCADIA_HOSTING_WINDOW_CLASS'; Title = 'Terminal'; Path = $app }
        @{ Handle = 4; Class = 'CASCADIA_HOSTING_WINDOW_CLASS'; Title = 'Terminal'; Path = $app }
    )
    $class = [pscustomobject]@{ Kind = 'class'; Match = 'CASCADIA_HOSTING_WINDOW_CLASS' }
    Assert-Equal 3 (Find-ShotWindow -Windows $windows -Before @($own.ToUpper()) -Window $class).Handle 'frontmost new window; exe paths ignore case'
    Assert-Equal $null (Find-ShotWindow -Windows $windows -Before @($own, $app) -Window $class) 'no new exe, no window'
    Assert-Equal $null (Find-ShotWindow -Windows $windows -Before @($own) -Window ([pscustomobject]@{ Kind = 'class'; Match = 'cascadia_hosting_window_class' })) 'class is exact'
    Assert-Equal 3 (Find-ShotWindow -Windows $windows -Before @() -Window ([pscustomobject]@{ Kind = 'title'; Match = '^Term' })).Handle 'title regex'
    Assert-Equal $null (Find-ShotWindow -Windows @() -Window $class) 'nothing open'
}

Test 'Photographer: the README gets a Day and Night table under its header lines, once' {
    $readme = "# Test for App`n`n**Tier:** 2 Flat\`n**Tested with:** Not tested yet`n`nIntro.`n`n## Install`n"
    $out = Add-ShotTable -Readme $readme -DayName 'Test Day' -NightName 'Test Night'
    $want = "# Test for App`n`n**Tier:** 2 Flat\`n**Tested with:** Not tested yet`n`n" +
        "| Test Day | Test Night |`n|---|---|`n| ![Test Day](screenshots/day.png) | ![Test Night](screenshots/night.png) |`n`n" +
        "Intro.`n`n## Install`n"
    Assert-Equal $want $out 'table added'
    Assert-Equal $want (Add-ShotTable -Readme $out -DayName 'Test Day' -NightName 'Test Night') 'added once'
    $crlf = $readme -replace "`n", "`r`n"
    Assert-True ((Add-ShotTable -Readme $crlf -DayName 'D' -NightName 'L') -like "*Not tested yet`r`n`r`n| D | L |`r`n|---|---|`r`n*") 'keeps CRLF'
}

Test 'Photographer: pins become the base image''s build arguments, and loose pins are refused' {
    $path = Join-Path $Tmp 'pins.json'
    $pins = [ordered]@{
        base = 'example/mint@sha256:' + ('a' * 64); ubuntu_snapshot = '20261124T000000Z'
        mint_packages = [ordered]@{ cinnamon = '6.6.9+zena'; nemo = '6.6.3+zena' }
        font = [ordered]@{ url = 'https://example.invalid/font.zip'; sha256 = 'b' * 64 }
        chromium = '158.0.8127.88~linuxmint1+mint22.3'
    }
    ConvertTo-Json $pins -Depth 4 | Set-Content $path
    $built = Get-BaseBuildArgs -Path $path
    Assert-Equal @("BASE=example/mint@sha256:$('a' * 64)", 'UBUNTU_SNAPSHOT=20261124T000000Z', 'MINT_PACKAGES=cinnamon=6.6.9+zena nemo=6.6.3+zena',
        'FONT_URL=https://example.invalid/font.zip', "FONT_SHA256=$('b' * 64)", 'CHROMIUM_VERSION=158.0.8127.88~linuxmint1+mint22.3') $built 'build args'
    $pins.base = 'example/mint:latest'; $pins.ubuntu_snapshot = 'yesterday'; $pins.mint_packages = @{ cinnamon = '' }; $pins.font.sha256 = 'x'; $pins.chromium = 'latest version'
    ConvertTo-Json $pins -Depth 4 | Set-Content $path
    Assert-Throws { Get-BaseBuildArgs -Path $path } '*base must name an image by digest*ubuntu_snapshot*mint_packages*font*chromium*'
    $pins.Remove('chromium')
    ConvertTo-Json $pins -Depth 4 | Set-Content $path
    Assert-Throws { Get-BaseBuildArgs -Path $path } '*chromium must be*'
}

# A 1x1 PNG, to carry a stamp.
$TinyPng = [Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==')

Test 'Photographer: a stamp round-trips through the PNG text chunk, and a second write replaces it' {
    $png = Join-Path $Tmp 'stamp.png'
    [System.IO.File]::WriteAllBytes($png, $TinyPng)
    Assert-Equal $null (Read-ShotStamp -Path $png) 'no stamp yet'
    Write-ShotStamp -Path $png -Stamp ([ordered]@{ fingerprint = 'abc'; inputs = [ordered]@{ port = '1' } })
    $s = Read-ShotStamp -Path $png
    Assert-Equal 'abc' $s['fingerprint'] 'fingerprint'
    Assert-Equal '1' $s['inputs']['port'] 'group hash'
    Write-ShotStamp -Path $png -Stamp @{ fingerprint = 'def' }
    Assert-Equal 'def' (Read-ShotStamp -Path $png)['fingerprint'] 'replaced'
    $bytes = [System.IO.File]::ReadAllBytes($png)
    Assert-Equal 1 ([regex]::Matches([System.Text.Encoding]::Latin1.GetString($bytes), 'tEXtinglenook').Count) 'one stamp chunk'
    Assert-Equal ($TinyPng.Length + 12 + 'inglenook'.Length + 1 + '{"fingerprint":"def"}'.Length) $bytes.Length 'image chunks kept as they were'
    Assert-Equal 'IEND' ([System.Text.Encoding]::ASCII.GetString($bytes, $bytes.Length - 8, 4)) 'IEND stays last'
    $txt = Join-Path $Tmp 'not.png'; Set-Content $txt 'hello'
    Assert-Throws { Write-ShotStamp -Path $txt -Stamp @{} } '*not a PNG*'
}

# A small repo with a terminal, a prompt it hosts, an editor, and an icon theme
# it hosts, each with
# shots stamped with its current fingerprint. Returns the repo root.
function New-ShotPalette([string]$Version = '1.0.4', [scriptblock]$Change) {
    # A valid palette for a shot repo: the backdrop's color comes from it.
    $d = New-PaletteData
    $d.meta.version = $Version
    if ($Change) { & $Change $d }
    return (ConvertTo-Json -InputObject $d -Depth 8) + "`n"
}
function New-ShotRepo {
    $root = Join-Path $Tmp ('shots-' + [guid]::NewGuid().ToString('N'))
    $files = @{
        'palette/palette.json' = (New-ShotPalette)
        'Ports/term/dist/day/install.sh' = "# Inglenook 1.0.4`nset term day`n"
        'Ports/term/dist/night/install.sh' = "# Inglenook 1.0.4`nset term night`n"
        'Ports/term/template/install.sh' = "set term {{text}}`n"
        'Ports/term/README.md' = "# Term`n"; 'Ports/term/MAPPING.md' = "x`n"; 'Ports/term/port.json' = "{}`n"; 'Ports/term/icon.svg' = "<svg/>`n"
        'Ports/prompt/dist/day/prompt.toml' = "day = 1`n"
        'Ports/prompt/dist/night/prompt.toml' = "night = 1`n"
        'Ports/editor/dist/day/theme.json' = "{}`n"
        'Ports/editor/dist/night/theme.json' = "{}`n"
        'Ports/icons/dist/day/icons.json' = "{}`n"
        'Ports/icons/dist/night/icons.json' = "{}`n"
        'build/photograph/pins.json' = "{}`n"
        'build/photograph/linux/shoot.sh' = "grab`n"
        'build/photograph.ps1' = "shoot`n"; 'build/lib/Photographer.psm1' = "rules`n"; 'build/lib/Png.psm1' = "png`n"
        'build/photograph/scenes/terminal/run.sh' = "ls`n"
        'build/photograph/scenes/prompt/run.sh' = "cd`n"
        'build/photograph/scenes/editor/main.py' = "print()`n"
        'wallpapers/other.jpg' = "other`n"
    }
    foreach ($k in $files.Keys) {
        $path = Join-Path $root $k
        New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
        [System.IO.File]::WriteAllText($path, $files[$k])
    }
    $recipes = @{
        term = [ordered]@{ kind = 'terminal'; platform = 'linux'; version = '3.52.0'; install = @('i'); apply = @('a'); stage = @(); launch = @('l'); window = @{ class = 't' } }
        prompt = [ordered]@{ kind = 'prompt'; platform = 'linux'; host = 'term'; version = '1.24.0'; install = @('i'); apply = @('a') }
        editor = [ordered]@{ kind = 'editor'; platform = 'linux'; install = @('i'); apply = @('a'); stage = @(); launch = @('l'); window = @{ class = 'e' } }
        icons = [ordered]@{ kind = 'icon-theme'; platform = 'linux'; host = 'editor'; version = '5.0.0'; install = @('i'); apply = @('a') }
    }
    foreach ($name in $recipes.Keys) { Set-Recipe (Join-Path $root 'Ports') $name $recipes[$name] }
    foreach ($name in $recipes.Keys) {
        $dir = Join-Path $root 'Ports' $name 'screenshots'
        New-Item -ItemType Directory -Path $dir | Out-Null
        $f = Get-PortFingerprint $root $name
        foreach ($v in 'day', 'night') {
            [System.IO.File]::WriteAllBytes((Join-Path $dir "$v.png"), $TinyPng)
            Write-ShotStamp -Path (Join-Path $dir "$v.png") -Stamp @{ fingerprint = $f.Fingerprint }
        }
    }
    return $root
}
function Get-PortFingerprint([string]$Root, [string]$Name) {
    $recipe = Get-Content -Raw (Join-Path $Root 'Ports' $Name 'screenshot.json') | ConvertFrom-Json -AsHashtable
    return Get-ShotFingerprint -RepoRoot $Root -Port $Name -Recipe $recipe
}
function Get-StaleNames([string]$Root) {
    @(foreach ($name in 'editor', 'icons', 'prompt', 'term') {
        if (Test-ShotStale -Dir (Join-Path $Root 'Ports' $name 'screenshots') -Fingerprint (Get-PortFingerprint $Root $name).Fingerprint) { $name }
    })
}

Test 'Photographer: one SHA-256 in lowercase hex, of text as UTF-8 or of bytes' {
    $abc = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
    Assert-Equal $abc (Get-Sha256 'abc') 'text'
    Assert-Equal $abc (Get-Sha256 ([byte[]](97, 98, 99))) 'bytes'
    Assert-Equal 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' (Get-Sha256 ([byte[]]@())) 'no bytes'
}

Test 'Photographer: a fresh repo has no stale port, and the fingerprint does not depend on where the repo is' {
    $a = New-ShotRepo; $b = New-ShotRepo
    Assert-Equal @() (Get-StaleNames $a) 'stale'
    Assert-Equal (Get-PortFingerprint $a 'prompt').Fingerprint (Get-PortFingerprint $b 'prompt').Fingerprint 'same inputs, same fingerprint'
    $f = Get-PortFingerprint $a 'prompt'
    Assert-Equal @('port', 'host', 'recipe', 'scene', 'photographer', 'backdrop') @($f.Inputs.Keys) 'input groups'
    Assert-True ($f.Inputs['host'] -ne '') 'a guest has a host group'
    Assert-Equal '' (Get-PortFingerprint $a 'editor').Inputs['host'] 'a port with no host has an empty host group'
}

Test 'Photographer: changing one input makes exactly the ports that use it stale' {
    $cases = [ordered]@{
        'Ports/term/dist/day/install.sh'          = @('prompt', 'term')
        'Ports/term/screenshot.json'                = @('prompt', 'term')
        'Ports/prompt/dist/night/prompt.toml'      = @('prompt')
        'Ports/prompt/screenshot.json'              = @('prompt')
        'Ports/editor/dist/day/new.json'           = @('editor', 'icons')
        'Ports/editor/screenshot.json'              = @('editor', 'icons')
        'Ports/icons/dist/day/icons.json'          = @('icons')
        'build/photograph/scenes/terminal/run.sh'   = @('term')
        'build/photograph/scenes/prompt/run.sh'     = @('prompt')
        'build/photograph/scenes/editor/main.py'    = @('editor', 'icons')
        'build/photograph/scenes/icon-theme/run.sh' = @()
        'build/photograph/pins.json'                = @('editor', 'icons', 'prompt', 'term')
        'build/photograph/linux/shoot.sh'           = @('editor', 'icons', 'prompt', 'term')
        'build/photograph.ps1'                      = @('editor', 'icons', 'prompt', 'term')
        'build/lib/Photographer.psm1'               = @('editor', 'icons', 'prompt', 'term')
        'build/lib/Png.psm1'                        = @('editor', 'icons', 'prompt', 'term')
    }
    # A recipe change is an app version moving: a version number is not a version stamp there.
    foreach ($path in $cases.Keys) {
        $root = New-ShotRepo
        $file = Join-Path $root $path
        if ($path -like '*.json' -and (Test-Path $file)) { $r = Get-Content -Raw $file | ConvertFrom-Json -AsHashtable; $r['version'] = '3.53.0'; Set-Content $file (ConvertTo-Json $r -Depth 5) }
        else { New-Item -ItemType Directory -Path (Split-Path $file) -Force | Out-Null; Add-Content -Path $file -Value 'changed' }
        Assert-Equal $cases[$path] (Get-StaleNames $root) "after changing $path"
    }
}

Test 'Photographer: the backdrop color makes every port stale, and other palette colors none' {
    $root = New-ShotRepo
    Set-Content (Join-Path $root 'palette/palette.json') (New-ShotPalette -Change { param($d) $d.variants.night.colors.moss.l = 0.7; $d.variants.day.neutrals.text.l = 0.25 }) -NoNewline
    Assert-Equal @() (Get-StaleNames $root) 'a color the backdrop does not use'
    Set-Content (Join-Path $root 'palette/palette.json') (New-ShotPalette -Change { param($d) $d.variants.night.neutrals.deeper.l = 0.15 }) -NoNewline
    Assert-Equal @('editor', 'icons', 'prompt', 'term') (Get-StaleNames $root) 'the night backdrop moved'
}

Test 'Photographer: the backdrop is the deeper fill of each variant, or a wallpaper' {
    $root = New-ShotRepo
    $p = Read-Palette -Path (Join-Path $root 'palette/palette.json')
    foreach ($v in 'day', 'night') {
        $b = Get-SceneBackdrop -RepoRoot $root -Variant $v
        Assert-Equal "fill deeper $($p.Variants[$v].Neutrals['deeper'].Hex)" "$($b.Kind) $($b.Name) $($b.Value)" "$v backdrop"
        Assert-Equal "a plain $($b.Value) fill (deeper)" (Format-SceneBackdrop $b) "$v in words"
    }
    $w = Get-SceneBackdrop -RepoRoot $root -Variant 'day' -Backdrop 'other.jpg'
    Assert-Equal 'image wallpapers/other.jpg' "$($w.Kind) $($w.Value)" 'a wallpaper'
    Assert-Equal 'wallpapers/other.jpg' (Format-SceneBackdrop $w) 'a wallpaper in words'
    Assert-Throws { Get-SceneBackdrop -RepoRoot $root -Variant 'day' -Backdrop 'gone.jpg' } '*does not exist*'
    Assert-Throws { Get-SceneBackdrop -RepoRoot $root -Variant 'day' -Backdrop 'moss' } '*not a palette neutral*'
}

Test 'Photographer: version stamps, line endings, docs, templates and unused scenes change nothing' {
    $root = New-ShotRepo
    $f = Join-Path $root 'Ports/term/dist/day/install.sh'
    [System.IO.File]::WriteAllText($f, "# Inglenook 1.1.0`r`nset term day`r`n")
    [System.IO.File]::WriteAllText((Join-Path $root 'Ports/term/dist/night/install.sh'), "# Inglenook 1.1.0`nset term night`n")
    [System.IO.File]::WriteAllText((Join-Path $root 'palette/palette.json'), (New-ShotPalette '1.1.0'))
    foreach ($p in 'Ports/term/README.md', 'Ports/term/MAPPING.md', 'Ports/term/port.json', 'Ports/term/icon.svg', 'Ports/term/template/install.sh',
                   'build/photograph/scenes/desktop/run.sh', 'wallpapers/other.jpg', 'Ports/term/screenshots/notes.txt') {
        $file = Join-Path $root $p
        New-Item -ItemType Directory -Path (Split-Path $file) -Force | Out-Null
        Add-Content -Path $file -Value 'changed'
    }
    Assert-Equal @() (Get-StaleNames $root) 'stale'
}

Test 'Photographer: only the palette version is a version stamp, so another version number in dist/ counts' {
    $root = New-ShotRepo
    $f = Join-Path $root 'Ports/term/dist/day/install.sh'
    [System.IO.File]::WriteAllText($f, "# Inglenook 1.0.4`nset term day`nneeds 2.0.0`n")
    foreach ($name in 'prompt', 'term') {
        $fp = (Get-PortFingerprint $root $name).Fingerprint
        foreach ($v in 'day', 'night') { Write-ShotStamp -Path (Join-Path $root 'Ports' $name 'screenshots' "$v.png") -Stamp @{ fingerprint = $fp } }
    }
    Assert-Equal @() (Get-StaleNames $root) 'restamped'
    [System.IO.File]::WriteAllText($f, "# Inglenook 1.0.4`nset term day`nneeds 2.1.0`n")
    Assert-Equal @('prompt', 'term') (Get-StaleNames $root) 'an app version in dist/ is not a stamp'
}

Test 'Photographer: an icon theme is shot in the editor scene itself' {
    $text = ConvertTo-StepScript -Steps @() -Kind 'icon-theme' -Variant 'day' -RepoRoot '/inglenook'
    Assert-True ($text -match "(?m)^export INGLENOOK_VARIANT='day' INGLENOOK_SCENE='/inglenook/build/photograph/scenes/editor'$") 'the editor scene folder'
    $root = New-ShotRepo
    Assert-Equal (Get-PortFingerprint $root 'editor').Inputs['scene'] (Get-PortFingerprint $root 'icons').Inputs['scene'] 'the same scene group as the editor'
}

Test 'Photographer: a port with no shots, one shot, or an unstamped shot is stale' {
    $root = New-ShotRepo
    $dir = Join-Path $root 'Ports/term/screenshots'
    $fp = (Get-PortFingerprint $root 'term').Fingerprint
    Remove-Item (Join-Path $dir 'night.png')
    Assert-True (Test-ShotStale -Dir $dir -Fingerprint $fp) 'one shot missing'
    [System.IO.File]::WriteAllBytes((Join-Path $dir 'night.png'), $TinyPng)
    Assert-True (Test-ShotStale -Dir $dir -Fingerprint $fp) 'unstamped shot'
    Assert-True (Test-ShotStale -Dir (Join-Path $root 'Ports/none/screenshots') -Fingerprint $fp) 'no shots'
}

Test 'Photographer: the stamp keeps the fingerprint and, beside it, what the PR''s why line needs' {
    $root = New-ShotRepo
    $pins = Join-Path $root 'build/photograph/pins.json'
    Set-Content $pins '{ "ubuntu_snapshot": "20261124T000000Z" }'
    $f = Get-PortFingerprint $root 'prompt'
    $term = Get-Content -Raw (Join-Path $root 'Ports/term/screenshot.json') | ConvertFrom-Json -AsHashtable
    $prompt = Get-Content -Raw (Join-Path $root 'Ports/prompt/screenshot.json') | ConvertFrom-Json -AsHashtable
    $s = New-ShotStamp -Fingerprint $f -Recipe $prompt -HostRecipe $term -PinsPath $pins -RunnerImage 'ubuntu24 20261120.1'
    Assert-Equal @('fingerprint', 'inputs', 'app_version', 'host_version', 'package_date', 'runner_image') @($s.Keys) 'fields'
    Assert-Equal $f.Fingerprint $s['fingerprint'] 'fingerprint'
    Assert-Equal $f.Inputs['scene'] $s['inputs']['scene'] 'group hashes'
    Assert-Equal @('1.24.0', '3.52.0', '20261124T000000Z', 'ubuntu24 20261120.1') @($s['app_version'], $s['host_version'], $s['package_date'], $s['runner_image']) 'versions'
    $s = New-ShotStamp -Fingerprint (Get-PortFingerprint $root 'editor') -Recipe @{ kind = 'editor' } -PinsPath $pins -RunnerImage 'local'
    Assert-Equal @('', '') @($s['app_version'], $s['host_version']) 'no version, no host'
}

# The preview in a small repo: its dist/ names one wallpaper, and it has assets
# and a shot list. Its shots are stamped with its current fingerprint.
function New-PreviewRepo {
    $root = New-ShotRepo
    $files = @{
        'Ports/preview/dist/day/index.html' = "<p>Inglenook 1.0.4</p><style>body { background: url(../../../../wallpapers/other.jpg) }</style>`n"
        'Ports/preview/dist/night/index.html' = "<p>Inglenook 1.0.4</p>`n"
        'Ports/preview/assets/fonts/a.woff2' = "font`n"
        'Ports/preview/template/index.html' = "<p>{{meta.version}}</p>`n"
        'Ports/preview/README.md' = "# Preview`n"
    }
    foreach ($k in $files.Keys) {
        $path = Join-Path $root $k
        New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
        [System.IO.File]::WriteAllText($path, $files[$k])
    }
    Set-ShotList (Join-Path $root 'Ports') 'preview' (New-GoodShotList)
    $dir = Join-Path $root 'Ports/preview/screenshots'
    New-Item -ItemType Directory -Path $dir | Out-Null
    $f = Get-PreviewFingerprint -RepoRoot $root -Port 'preview'
    foreach ($n in 'day', 'night', 'roles') {
        [System.IO.File]::WriteAllBytes((Join-Path $dir "$n.png"), $TinyPng)
        Write-ShotStamp -Path (Join-Path $dir "$n.png") -Stamp @{ fingerprint = $f.Fingerprint }
    }
    return $root
}
function Test-PreviewStale([string]$Root) {
    $f = Get-PreviewFingerprint -RepoRoot $Root -Port 'preview'
    return Test-ShotStale -Dir (Join-Path $Root 'Ports/preview/screenshots') -Fingerprint $f.Fingerprint -Names @('day', 'night', 'roles')
}

Test 'Photographer: the preview is stale when its page, assets, shot list, Photographer or own wallpapers change, version stamp included' {
    Assert-Equal @('port', 'assets', 'shots', 'photographer', 'wallpapers') @((Get-PreviewFingerprint -RepoRoot (New-PreviewRepo) -Port 'preview').Inputs.Keys) 'input groups'
    Assert-True (-not (Test-PreviewStale (New-PreviewRepo))) 'fresh'
    foreach ($path in 'Ports/preview/dist/night/index.html', 'Ports/preview/assets/fonts/a.woff2', 'Ports/preview/shots.json',
                      'build/photograph/linux/preview.py', 'build/photograph/pins.json', 'wallpapers/other.jpg') {
        $root = New-PreviewRepo
        Add-Content -Path (Join-Path $root $path) -Value 'changed'
        Assert-True (Test-PreviewStale $root) "after changing $path"
    }
    $root = New-PreviewRepo
    $f = Join-Path $root 'Ports/preview/dist/day/index.html'
    [System.IO.File]::WriteAllText($f, ([System.IO.File]::ReadAllText($f)).Replace('1.0.4', '1.0.5'))
    Assert-True (Test-PreviewStale $root) 'the version stamp counts for the preview'
}

Test 'Photographer: scenes, templates and docs leave the preview fresh, and a missing image makes it stale' {
    $root = New-PreviewRepo
    foreach ($p in 'build/photograph/scenes/terminal/run.sh',
                   'Ports/preview/template/index.html', 'Ports/preview/README.md') {
        Add-Content -Path (Join-Path $root $p) -Value 'changed'
    }
    [System.IO.File]::WriteAllText((Join-Path $root 'Ports/preview/dist/day/index.html'), "<p>Inglenook 1.0.4</p><style>body { background: url(../../../../wallpapers/other.jpg) }</style>`r`n")
    Assert-True (-not (Test-PreviewStale $root)) 'fresh'
    Remove-Item (Join-Path $root 'Ports/preview/screenshots/roles.png')
    Assert-True (Test-PreviewStale $root) 'a missing section shot'
}

# Tiny PNGs for the take verdict. Pixels is a list of RGBA quads (0-255), row by
# row. -Rgb drops alpha (for opaque pixels), -Filter sets every row's filter
# (0 None, 1 Sub, 2 Up, 3 Average, 4 Paeth), so the same pixels can be encoded
# two ways.
function New-TestPng([string]$Path, [int]$Width, [int[][]]$Pixels, [switch]$Rgb, [int]$Filter = 0, [hashtable]$Stamp) {
    $height = [int]($Pixels.Count / $Width)
    $bpp = if ($Rgb) { 3 } else { 4 }
    $stride = $Width * $bpp
    $raw = [byte[]]::new($height * $stride)
    for ($i = 0; $i -lt $Pixels.Count; $i++) { for ($c = 0; $c -lt $bpp; $c++) { $raw[$i * $bpp + $c] = [byte]$Pixels[$i][$c] } }
    $paeth = { param($a, $b, $c) $p = $a + $b - $c; $pa = [math]::Abs($p - $a); $pb = [math]::Abs($p - $b); $pc = [math]::Abs($p - $c)
               if ($pa -le $pb -and $pa -le $pc) { $a } elseif ($pb -le $pc) { $b } else { $c } }
    $filtered = [System.IO.MemoryStream]::new()
    for ($y = 0; $y -lt $height; $y++) {
        $filtered.WriteByte([byte]$Filter)
        for ($x = 0; $x -lt $stride; $x++) {
            $cur = [int]$raw[$y * $stride + $x]
            $a = if ($x -ge $bpp) { [int]$raw[$y * $stride + $x - $bpp] } else { 0 }
            $b = if ($y -gt 0) { [int]$raw[($y - 1) * $stride + $x] } else { 0 }
            $c = if ($x -ge $bpp -and $y -gt 0) { [int]$raw[($y - 1) * $stride + $x - $bpp] } else { 0 }
            $pred = switch ($Filter) { 0 { 0 } 1 { $a } 2 { $b } 3 { [math]::Floor(($a + $b) / 2) } 4 { & $paeth $a $b $c } }
            $filtered.WriteByte([byte](($cur - $pred + 256) % 256))
        }
    }
    $z = [System.IO.MemoryStream]::new()
    $zs = [System.IO.Compression.ZLibStream]::new($z, [System.IO.Compression.CompressionLevel]::Optimal)
    $bytes = $filtered.ToArray(); $zs.Write($bytes, 0, $bytes.Length); $zs.Dispose()
    $chunk = {
        param([string]$Type, [byte[]]$Data)
        $body = [byte[]]([System.Text.Encoding]::ASCII.GetBytes($Type) + $Data)
        $len = [BitConverter]::GetBytes([uint32]$Data.Length); [Array]::Reverse($len)
        $c = [BitConverter]::GetBytes([uint32](Get-TestCrc $body)); [Array]::Reverse($c)
        [byte[]]($len + $body + $c)
    }
    $ihdr = [byte[]]::new(13)
    $w = [BitConverter]::GetBytes([uint32]$Width); [Array]::Reverse($w); [Array]::Copy($w, 0, $ihdr, 0, 4)
    $h = [BitConverter]::GetBytes([uint32]$height); [Array]::Reverse($h); [Array]::Copy($h, 0, $ihdr, 4, 4)
    $ihdr[8] = 8; $ihdr[9] = if ($Rgb) { 2 } else { 6 }
    $out = [byte[]](137, 80, 78, 71, 13, 10, 26, 10) + (& $chunk 'IHDR' $ihdr) + (& $chunk 'IDAT' $z.ToArray()) + (& $chunk 'IEND' ([byte[]]@()))
    [System.IO.File]::WriteAllBytes($Path, [byte[]]$out)
    if ($Stamp) { Write-ShotStamp -Path $Path -Stamp $Stamp }
    return $Path
}
function Get-TestCrc([byte[]]$Bytes) {
    $c = [uint32]::MaxValue
    foreach ($b in $Bytes) {
        $c = $c -bxor $b
        for ($k = 0; $k -lt 8; $k++) { $c = if ($c -band 1) { [uint32]3988292384 -bxor ($c -shr 1) } else { $c -shr 1 } }
    }
    return $c -bxor [uint32]::MaxValue
}
# Four pixels: a shot, and the same shot with one pixel off by 3.
$ShotA = @(@(10, 20, 30, 255), @(200, 100, 50, 255), @(0, 0, 0, 255), @(255, 255, 255, 255))
$ShotB = @(@(10, 20, 30, 255), @(200, 100, 53, 255), @(0, 0, 0, 255), @(255, 255, 255, 255))
$ShotC = @(@(90, 20, 30, 255), @(200, 100, 50, 255), @(0, 0, 0, 255), @(255, 255, 255, 255))

Test 'Photographer: shots compare by decoded pixels, not by bytes' {
    $a = New-TestPng (Join-Path $Tmp 'cmp-a.png') 2 $ShotA
    $a2 = New-TestPng (Join-Path $Tmp 'cmp-a2.png') 2 $ShotA -Rgb -Filter 4 -Stamp @{ fingerprint = 'x' }
    $a3 = New-TestPng (Join-Path $Tmp 'cmp-a3.png') 4 $ShotA -Filter 3
    $b = New-TestPng (Join-Path $Tmp 'cmp-b.png') 2 $ShotB -Filter 1
    $r = Compare-ShotPixels -Path $a -Other $a2
    Assert-True $r.Same 'same pixels, other encoding and a stamp'
    Assert-Equal 0 $r.Differ 'differing pixels'
    $r = Compare-ShotPixels -Path $a -Other $b
    Assert-True (-not $r.Same) 'one pixel off'
    Assert-Equal @(1, 3) @($r.Differ, $r.MaxDelta) 'differing pixels and the largest channel difference'
    $r = Compare-ShotPixels -Path $a -Other $a3
    Assert-True (-not $r.Same -and $r.Size -eq '2x2 against 4x1') "other size: $($r.Size)"
}

Test 'Photographer: an unchanged shot takes the new stamp when its fingerprint is old, pixels untouched' {
    $committed = New-TestPng (Join-Path $Tmp 'restamp-old.png') 2 $ShotA -Stamp @{ fingerprint = 'old' }
    $take = New-TestPng (Join-Path $Tmp 'restamp-take.png') 2 $ShotA -Filter 2 -Stamp @{ fingerprint = 'new'; runner_image = 'r2' }
    $pixels = [System.IO.File]::ReadAllBytes($committed)
    Assert-True (Update-ShotStamp -Committed $committed -Take $take) 'old fingerprint: restamped'
    $s = Read-ShotStamp -Path $committed
    Assert-Equal 'new' $s['fingerprint'] 'the take''s stamp'
    Assert-Equal 'r2' $s['runner_image'] 'the whole stamp'
    $after = [System.IO.File]::ReadAllBytes($committed)
    $idatAt = { param($b) for ($i = 0; $i -lt $b.Length - 4; $i++) { if ($b[$i] -eq 0x49 -and $b[$i + 1] -eq 0x44 -and $b[$i + 2] -eq 0x41 -and $b[$i + 3] -eq 0x54) { return $i } } }
    $len = { param($b, $at) ([int]$b[$at - 4] -shl 24) -bor ([int]$b[$at - 3] -shl 16) -bor ([int]$b[$at - 2] -shl 8) -bor [int]$b[$at - 1] }
    $a1 = & $idatAt $pixels; $a2 = & $idatAt $after
    Assert-Equal ([Convert]::ToBase64String($pixels[$a1..($a1 + (& $len $pixels $a1) + 3)])) ([Convert]::ToBase64String($after[$a2..($a2 + (& $len $after $a2) + 3)])) 'image data kept byte for byte'
    Assert-True (-not (Update-ShotStamp -Committed $committed -Take $take)) 'same fingerprint: left alone'
    $other = New-TestPng (Join-Path $Tmp 'restamp-other.png') 2 $ShotA -Stamp @{ fingerprint = 'new'; runner_image = 'r3' }
    Assert-True (-not (Update-ShotStamp -Committed $committed -Take $other)) 'only the runner image moved: left alone'
    Assert-Equal 'r2' (Read-ShotStamp -Path $committed)['runner_image'] 'not rewritten'
    $bare = New-TestPng (Join-Path $Tmp 'restamp-bare.png') 2 $ShotA
    Assert-True (Update-ShotStamp -Committed $bare -Take $take) 'no stamp at all: restamped'
}

Test 'Photographer: the take verdict, for every committed shot and take' {
    $png = { param($n, $px) New-TestPng (Join-Path $Tmp "take-$n.png") 2 $px -Filter 2 }
    $old = & $png 'old' $ShotA; $same = & $png 'same' $ShotA; $new = & $png 'new' $ShotB; $new2 = & $png 'new2' $ShotB; $odd = & $png 'odd' $ShotC
    $third = & $png 'third' @(@(1, 1, 1, 255), @(2, 2, 2, 255), @(3, 3, 3, 255), @(4, 4, 4, 255))
    $cases = @(
        # committed, takes, verdict, shot
        @($old,  @($same),             'unchanged', $old),
        @($old,  @($new),              'retake',    $null),
        @($old,  @($new, $same),       'unchanged', $old),
        @($old,  @($new, $new2),       'changed',   $new2),
        @($old,  @($new, $odd),        'retake',    $null),
        @($old,  @($new, $odd, $same), 'unchanged', $old),
        @($old,  @($new, $odd, $new2), 'changed',   $new2),
        @($old,  @($odd, $new, $odd),  'changed',   $odd),
        @($old,  @($new, $odd, $odd),  'changed',   $odd),
        @($old,  @($new, $odd, $old),  'unchanged', $old),
        @($old,  @($odd, $new, $same), 'unchanged', $old),
        @($null, @($new),              'retake',    $null),
        @($null, @($new, $new2),       'changed',   $new2),
        @($null, @($new, $odd),        'retake',    $null),
        @($null, @($new, $odd, $new2), 'changed',   $new2),
        @($null, @($new, $odd, $same), 'failed',    $null),
        @($old,  @($new, $odd, $third), 'failed',   $null)
    )
    foreach ($c in $cases) {
        $v = Get-TakeVerdict -Committed $c[0] -Takes $c[1]
        $what = "committed $(if ($c[0]) { 'A' } else { 'none' }), takes $(@($c[1] | ForEach-Object { Split-Path -LeafBase $_ }) -join ', ')"
        Assert-Equal $c[2] $v.Verdict "verdict, $what"
        Assert-Equal $c[3] $v.Shot "shot, $what"
    }
    Assert-Throws { Get-TakeVerdict -Committed $old -Takes @($new, $odd, $new2, $new) } '*at most three takes*'
}

Test 'Photographer: the why line names what moved, or only the runner image' {
    $stamp = {
        param([hashtable]$Change = @{})
        $s = [ordered]@{ fingerprint = 'f'; inputs = [ordered]@{ port = 'p'; host = 'h'; recipe = 'r'; scene = 's'; photographer = 'g'; backdrop = 'b'; wallpapers = 'w' }
                         app_version = '1.104.0'; host_version = '3.52.0'; package_date = '20261124T000000Z'; runner_image = 'ubuntu24 20261120.1' }
        foreach ($k in $Change.Keys) { if ($s['inputs'].Contains($k)) { $s['inputs'][$k] = $Change[$k] } else { $s[$k] = $Change[$k] } }
        $s
    }
    $why = { param($old, $new) Get-ShotWhy -Old $old -New $new -App 'VS Code' -HostApp 'GNOME Terminal' }
    $old = & $stamp
    Assert-Equal 'port files changed' (& $why $old (& $stamp @{ port = 'p2' })) 'port'
    Assert-Equal 'VS Code 1.104.0 → 1.108.1' (& $why $old (& $stamp @{ app_version = '1.108.1'; recipe = 'r2' })) 'app version, recipe change not repeated'
    Assert-Equal 'GNOME Terminal 3.52.0 → 3.54.0; host port changed' (& $why $old (& $stamp @{ host_version = '3.54.0'; host = 'h2' })) 'host version'
    Assert-Equal 'recipe changed; scene changed; Photographer changed; backdrop changed; wallpapers changed' `
        (& $why $old (& $stamp @{ recipe = 'r2'; scene = 's2'; photographer = 'g2'; backdrop = 'b2'; wallpapers = 'w2' })) 'every group, in order'
    Assert-Equal 'package date 20261124T000000Z → 20261201T000000Z; Photographer changed' (& $why $old (& $stamp @{ package_date = '20261201T000000Z'; photographer = 'g2' })) 'package date'
    Assert-Equal 'no input changed; runner image ubuntu24 20261120.1 → ubuntu24 20261201.2' (& $why $old (& $stamp @{ runner_image = 'ubuntu24 20261201.2' })) 'runner only'
    Assert-Equal 'no input changed' (& $why $old (& $stamp)) 'nothing'
    Assert-Equal 'first shot' (& $why $null (& $stamp)) 'no committed shot'
    Assert-Equal 'the committed shot has no stamp' (& $why @{ } (& $stamp)) 'unstamped'
}

Test 'Photographer: a crop of a grab is written losslessly as RGB' {
    $px = @(@(1, 2, 3, 255), @(4, 5, 6, 255), @(7, 8, 9, 255), @(10, 11, 12, 255), @(13, 14, 15, 255), @(16, 17, 18, 255),
            @(200, 201, 202, 255), @(4, 5, 7, 255), @(250, 0, 9, 255), @(10, 11, 12, 255), @(0, 0, 0, 255), @(255, 255, 255, 255))
    $grab = New-TestPng (Join-Path $Tmp 'grab.png') 3 $px -Filter 4
    $out = Join-Path $Tmp 'grab-crop.png'
    Export-ShotCrop -Path $grab -Crop @{ X = 1; Y = 1; Width = 2; Height = 3 } -Out $out
    $want = New-TestPng (Join-Path $Tmp 'grab-want.png') 2 @($px[4], $px[5], $px[7], $px[8], $px[10], $px[11]) -Rgb
    Assert-True (Compare-ShotPixels -Path $out -Other $want).Same 'same pixels as the area'
    $bytes = [System.IO.File]::ReadAllBytes($out)
    Assert-Equal 2 ([int]$bytes[25]) 'color type RGB'
    Assert-Throws { Export-ShotCrop -Path $grab -Crop @{ X = 2; Y = 0; Width = 2; Height = 1 } -Out $out } '*not inside the 3x4 grab*'
}

# --- Screenshot run ---------------------------------------------------------------

function Set-TestRunners([string]$Root, [hashtable]$Runners) {
    Set-Content (Join-Path $Root 'build/photograph/pins.json') (ConvertTo-Json @{ runners = $Runners })
    # Pins are an input: restamp every shot so the repo starts fresh again.
    foreach ($name in 'editor', 'icons', 'prompt', 'term') {
        $f = Get-PortFingerprint $Root $name
        foreach ($v in 'day', 'night') { Write-ShotStamp -Path (Join-Path $Root 'Ports' $name 'screenshots' "$v.png") -Stamp @{ fingerprint = $f.Fingerprint } }
    }
}
function Get-TargetNames($Targets) { @($Targets.Shoot | ForEach-Object { "$($_.port)@$($_.runner)" }) }

Test 'Run: a run shoots the stale ports on their platform''s runner, and lists the rest' {
    $root = New-ShotRepo
    Set-TestRunners $root @{ linux = 'ubuntu-24.04' }
    New-Item -ItemType Directory -Path (Join-Path $root 'Ports/paid') | Out-Null
    Set-Recipe (Join-Path $root 'Ports') 'paid' ([ordered]@{ kind = 'document'; platform = 'windows'; manual = 'Needs a license.' })
    New-Item -ItemType Directory -Path (Join-Path $root 'Ports/win') | Out-Null
    Set-Recipe (Join-Path $root 'Ports') 'win' ([ordered]@{ kind = 'terminal'; platform = 'windows'; install = @('i'); apply = @('a'); stage = @('s'); launch = @('l'); window = @{ title = 'W' } })
    $t = Get-ShotTargets -RepoRoot $root
    Assert-Equal @() @($t.Errors) 'recipe errors'
    Assert-Equal @() (Get-TargetNames $t) 'fresh linux ports'
    Assert-Equal @('paid: Needs a license.') @($t.Manual | ForEach-Object { "$($_.port): $($_.reason)" }) 'stale manual ports'
    Assert-Equal @('win: windows') @($t.Skipped | ForEach-Object { "$($_.port): $($_.platform)" }) 'stale ports with no runner'
    Add-Content (Join-Path $root 'Ports/term/dist/day/install.sh') 'changed'
    Assert-Equal @('prompt@ubuntu-24.04', 'term@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $root)) 'stale'
    Assert-Equal @('editor@ubuntu-24.04', 'icons@ubuntu-24.04', 'prompt@ubuntu-24.04', 'term@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $root -All)) 'all'
    Assert-Equal @('editor@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $root -Port 'editor')) 'one port, even fresh'
    $t = Get-ShotTargets -RepoRoot $root -Port 'win'
    Assert-Equal @() (Get-TargetNames $t) 'a port with no runner is not shot'
    Assert-Equal 'win' $t.Skipped[0].port 'but listed'
    Assert-Throws { Get-ShotTargets -RepoRoot $root -Port 'ghost' } '*ghost*no screenshot.json*'
}

Test 'Run: a pull request shoots the ports whose inputs or committed shots it changed' {
    $base = New-ShotRepo
    Set-TestRunners $base @{ linux = 'ubuntu-24.04' }
    $copy = { $r = Join-Path $Tmp ('head-' + [guid]::NewGuid().ToString('N')); Copy-Item -Path $base -Destination $r -Recurse; $r }
    $head = & $copy
    Assert-Equal @() (Get-TargetNames (Get-ShotTargets -RepoRoot $head -BaseRoot $base)) 'no change'
    Add-Content (Join-Path $head 'Ports/prompt/dist/day/prompt.toml') 'changed'
    Add-Content (Join-Path $head 'Ports/editor/README.md') 'docs only'
    Assert-Equal @('prompt@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $head -BaseRoot $base)) 'changed input'
    $head = & $copy
    Write-ShotStamp -Path (Join-Path $head 'Ports/editor/screenshots/day.png') -Stamp @{ fingerprint = 'other' }
    Assert-Equal @('editor@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $head -BaseRoot $base)) 'changed committed shot'
    $head = & $copy
    Remove-Item -Recurse (Join-Path $base 'Ports/editor')
    # A new host is a changed input of its guests too.
    Assert-Equal @('editor@ubuntu-24.04', 'icons@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $head -BaseRoot $base)) 'new port'
}

Test 'Run: a Windows port is shot on a fresh job per take of each variant, and runner labels are pinned' {
    $root = New-ShotRepo
    Set-TestRunners $root @{ linux = 'ubuntu-24.04'; windows = 'windows-2025' }
    New-Item -ItemType Directory -Path (Join-Path $root 'Ports/win') | Out-Null
    Set-Recipe (Join-Path $root 'Ports') 'win' ([ordered]@{ kind = 'terminal'; platform = 'windows'; install = @('i'); apply = @('a'); stage = @('s'); launch = @('l'); window = @{ class = 'W' } })
    $t = Get-ShotTargets -RepoRoot $root
    Assert-Equal @('win@windows-2025 day 1', 'win@windows-2025 day 2', 'win@windows-2025 day 3', 'win@windows-2025 night 1', 'win@windows-2025 night 2', 'win@windows-2025 night 3') `
        @($t.Shoot | ForEach-Object { "$($_.port)@$($_.runner) $($_.variant) $($_.take)" }) 'one job per take: the most the take verdict asks for'
    Assert-Equal @() @($t.Skipped) 'nothing skipped'
    Assert-Equal @('editor@ubuntu-24.04  ') @((Get-ShotTargets -RepoRoot $root -Port 'editor').Shoot | ForEach-Object { "$($_.port)@$($_.runner) $($_.variant) $($_.take)" }) 'Linux: one job for both, every take in it'
    Set-TestRunners $root @{ linux = 'ubuntu-24.04'; windows = 'windows-latest' }
    Assert-True ((@((Get-ShotTargets -RepoRoot $root).Errors) -join "`n") -like '*windows runner*windows-latest*never -latest*') 'a -latest label is an error'
}

Test 'Run: the preview''s shot list is shot on the Linux runner when stale, chosen, or changed by a pull request' {
    $base = New-PreviewRepo
    Set-TestRunners $base @{ linux = 'ubuntu-24.04' }
    $f = Get-PreviewFingerprint -RepoRoot $base -Port 'preview'
    foreach ($n in 'day', 'night', 'roles') { Write-ShotStamp -Path (Join-Path $base "Ports/preview/screenshots/$n.png") -Stamp @{ fingerprint = $f.Fingerprint } }
    Assert-Equal @() (Get-TargetNames (Get-ShotTargets -RepoRoot $base)) 'fresh'
    Assert-Equal @('preview@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $base -Port 'preview')) 'chosen'
    Assert-True ((Get-TargetNames (Get-ShotTargets -RepoRoot $base -All)) -contains 'preview@ubuntu-24.04') 'all'
    $head = Join-Path $Tmp ('head-' + [guid]::NewGuid().ToString('N')); Copy-Item -Path $base -Destination $head -Recurse
    Assert-Equal @() (Get-TargetNames (Get-ShotTargets -RepoRoot $head -BaseRoot $base)) 'no change'
    Write-ShotStamp -Path (Join-Path $head 'Ports/preview/screenshots/roles.png') -Stamp @{ fingerprint = 'other' }
    Assert-Equal @('preview@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $head -BaseRoot $base)) 'a changed section shot'
    Add-Content (Join-Path $base 'Ports/preview/assets/fonts/a.woff2') 'changed'
    Assert-Equal @('preview@ubuntu-24.04') (Get-TargetNames (Get-ShotTargets -RepoRoot $base)) 'stale'
}

# What photograph.ps1 -Report leaves for one port: result.json and the last take of each variant.
function New-TestResult([string]$Dir, [string]$Port, [string]$Status, [hashtable]$Verdicts = @{}, [string]$Why = '', [string]$Failure = '') {
    $d = Join-Path $Dir $Port
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    $variants = [ordered]@{}
    foreach ($v in 'day', 'night') {
        if (-not $Verdicts.Contains($v)) { continue }
        $px = if ($Verdicts[$v] -eq 'changed') { $ShotB } else { $ShotA }
        New-TestPng (Join-Path $d "$v.png") 2 $px -Stamp @{ fingerprint = "new-$Port" } | Out-Null
        $variants[$v] = [ordered]@{ verdict = $Verdicts[$v]; takes = 2; committed = $true; compare = [ordered]@{ same = ($Verdicts[$v] -eq 'unchanged'); differ = 1; max_delta = 3; size = '' } }
    }
    $r = [ordered]@{ port = $Port; app = $Port.ToUpper(); status = $Status; why = $Why; error = $Failure; variants = $variants }
    ConvertTo-Json $r -Depth 6 | Set-Content (Join-Path $d 'result.json')
}

Test 'Run: delivery copies only changed images, and adds missing README tables' {
    $root = New-ShotRepo
    $results = Join-Path $Tmp ('results-' + [guid]::NewGuid().ToString('N'))
    New-TestResult $results 'term' 'changed' @{ day = 'changed'; night = 'unchanged' } 'port files changed'
    New-TestResult $results 'editor' 'unchanged' @{ day = 'unchanged'; night = 'unchanged' }
    New-TestResult $results 'prompt' 'failed' @{ day = 'changed' } '' 'apply step 1 failed'
    Set-Content (Join-Path $root 'Ports/prompt/README.md') "# Prompt`n`n**Tier:** 2`n`nInstall it."
    Set-Content (Join-Path $root 'Ports/editor/README.md') "# Editor`n`n| Day | Night |`n|---|---|`n| ![Day](screenshots/day.png) | ![Night](screenshots/night.png) |"
    Copy-Item (Join-Path $root 'Ports/term/screenshots/night.png') ([System.IO.Path]::Combine($Tmp, 'restamp-before.png')) -Force
    $d = Copy-ShotDelivery -RepoRoot $root -Results $results -DayName 'Day' -NightName 'Night'
    Assert-Equal @('Ports/term/screenshots/day.png') @($d.Images) 'images'
    Assert-Equal @('prompt', 'term') @($d.Tables) 'tables added'
    Assert-True (Compare-ShotPixels -Path (Join-Path $root 'Ports/term/screenshots/day.png') -Other (Join-Path $results 'term/day.png')).Same 'changed image copied'
    $night = Join-Path $root 'Ports/term/screenshots/night.png'
    Assert-Equal @('Ports/editor/screenshots/day.png', 'Ports/editor/screenshots/night.png', 'Ports/term/screenshots/night.png') @($d.Restamped) 'unchanged images with an old fingerprint: stamp only'
    Assert-Equal 'new-term' (Read-ShotStamp -Path $night)['fingerprint'] 'the new stamp written'
    Assert-True (Compare-ShotPixels -Path $night -Other ([System.IO.Path]::Combine($Tmp, 'restamp-before.png'))).Same 'unchanged image keeps its pixels'
    Assert-True (-not (@($d.Restamped) -like 'Ports/prompt/*')) 'a failed port is not restamped'
    Assert-True ((Get-Content -Raw (Join-Path $root 'Ports/prompt/README.md')) -like '*| Day | Night |*') 'table under the header'
    Assert-Equal @('editor', 'prompt', 'term') @($d.Results | ForEach-Object port) 'results read'
}

Test 'Run: delivery and the run summary cover every image of a shot list' {
    $root = New-PreviewRepo
    $results = Join-Path $Tmp ('results-' + [guid]::NewGuid().ToString('N'))
    $d = Join-Path $results 'preview'
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    $variants = [ordered]@{}
    foreach ($n in 'day', 'night', 'roles') {
        $verdict = if ($n -eq 'roles') { 'changed' } else { 'unchanged' }
        New-TestPng (Join-Path $d "$n.png") 2 $(if ($verdict -eq 'changed') { $ShotB } else { $ShotA }) | Out-Null
        $variants[$n] = [ordered]@{ verdict = $verdict; takes = 2; committed = $true; compare = [ordered]@{ same = ($verdict -eq 'unchanged'); differ = 1; max_delta = 3; size = '' } }
    }
    $r = [ordered]@{ port = 'preview'; app = 'preview'; status = 'changed'; why = 'port files changed'; error = ''; variants = $variants }
    ConvertTo-Json $r -Depth 6 | Set-Content (Join-Path $d 'result.json')
    $out = Copy-ShotDelivery -RepoRoot $root -Results $results -DayName 'Day' -NightName 'Night'
    Assert-Equal @('Ports/preview/screenshots/roles.png') @($out.Images) 'the changed section shot'
    Assert-True (@($out.Tables) -notcontains 'preview') 'no README table for the preview'
    $read = Get-Content -Raw (Join-Path $d 'result.json') | ConvertFrom-Json -AsHashtable
    $summary = ConvertTo-ShotSummary -Result $read
    Assert-True ($summary -like '*- day: unchanged*' -and $summary -like '*- roles: changed*') "summary: $summary"
    $body = New-DeliveryBody -Results @($read) -Images @($out.Images) -Repo 'o/r' -Base 'aaa111' -Commit 'bbb222'
    Assert-True ($body -like '*| Roles |*bbb222/Ports/preview/screenshots/roles.png*') "body: $body"
}

Test 'Run: the rolling PR body shows old and new images, why, failures, manual ports and the hand-edit warning' {
    $results = Join-Path $Tmp ('results-' + [guid]::NewGuid().ToString('N'))
    New-TestResult $results 'term' 'changed' @{ day = 'changed'; night = 'unchanged' } 'port files changed'
    New-TestResult $results 'prompt' 'failed' @{} '' "photograph: Ports/prompt/screenshot.json, apply step 1 failed: cp x`n    cp: no such file"
    $results = @(Get-ChildItem $results -Directory | ForEach-Object { Get-Content -Raw (Join-Path $_.FullName 'result.json') | ConvertFrom-Json -AsHashtable })
    $body = New-DeliveryBody -Results $results -Images @('Ports/term/screenshots/day.png') -Restamped @('Ports/term/screenshots/night.png') -Tables @('prompt') `
        -Manual @(@{ port = 'paid'; reason = 'Needs a license.' }) -Skipped @(@{ port = 'win'; platform = 'windows' }) `
        -Repo 'o/r' -Base 'aaa111' -Commit 'bbb222' -RunUrl 'https://example.invalid/run/1'
    foreach ($want in '*## TERM*', '*port files changed*', '*https://github.com/o/r/raw/aaa111/Ports/term/screenshots/day.png*',
                      '*https://github.com/o/r/raw/bbb222/Ports/term/screenshots/day.png*', '*Failed*prompt*apply step 1 failed*cp: no such file*',
                      '*paid*Needs a license.*', '*win*windows*', '*README table*prompt*', '*hand edits*lost*', '*example.invalid/run/1*') {
        Assert-True ($body -like $want) "body lacks $want`:`n$body"
    }
    Assert-True ($body -notlike '*raw/bbb222/Ports/term/screenshots/night.png*') "unchanged variant shown:`n$body"
    Assert-True ($body -like '*## Stamp only*``Ports/term/screenshots/night.png``*') "stamp-only image not listed:`n$body"
    Assert-True ($body -like '*no pixel*') "stamp only says no pixel changed:`n$body"
    Assert-True ($body -notmatch '—') 'no em dash'
    $note = New-DeliveryNote -Results $results -RunUrl 'https://example.invalid/run/1'
    Assert-True ($note -like '*Nothing to deliver*' -and $note -like '*prompt*') "close note: $note"
}

# What photograph.ps1 -Variant -Report leaves: result-<variant>.json beside that variant's last take.
function New-TestPart([string]$Dir, [string]$Port, [string]$Variant, [string]$Status, [string]$Verdict, [string]$Why = '', [string]$Failure = '') {
    $d = Join-Path $Dir $Port
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    $variants = [ordered]@{}
    if ($Verdict) {
        New-TestPng (Join-Path $d "$Variant.png") 2 $(if ($Verdict -eq 'changed') { $ShotB } else { $ShotA }) | Out-Null
        $variants[$Variant] = [ordered]@{ verdict = $Verdict; takes = 2; committed = $true; compare = $null }
    }
    $r = [ordered]@{ port = $Port; app = $Port.ToUpper(); variant = $Variant; status = $Status; why = $Why; error = $Failure; variants = $variants }
    ConvertTo-Json $r -Depth 6 | Set-Content (Join-Path $d "result-$Variant.json")
}

Test 'Run: a port shot in a job per variant is delivered only when both variants succeed' {
    $results = Join-Path $Tmp ('results-' + [guid]::NewGuid().ToString('N'))
    New-TestPart $results 'both' 'day' 'changed' 'changed' 'first shot'
    New-TestPart $results 'both' 'night' 'unchanged' 'unchanged'
    New-TestPart $results 'half' 'day' 'changed' 'changed' 'first shot'
    New-TestPart $results 'broke' 'day' 'changed' 'changed' 'first shot'
    New-TestPart $results 'broke' 'night' 'failed' '' '' 'launch step 1 failed'
    New-TestResult $results 'term' 'unchanged' @{ day = 'unchanged'; night = 'unchanged' }
    $merged = @(Read-ShotResults -Results $results)
    Assert-Equal @('both changed', 'broke failed', 'half failed', 'term unchanged') @($merged | ForEach-Object { "$($_['port']) $($_['status'])" }) 'merged'
    $both = $merged | Where-Object { $_['port'] -eq 'both' }
    Assert-Equal @('day', 'night') @($both['variants'].Keys) 'both variants'
    Assert-Equal 'first shot' $both['why'] 'why'
    Assert-True (($merged | Where-Object { $_['port'] -eq 'half' })['error'] -like '*night job left no result*') 'missing variant named'
    Assert-True (($merged | Where-Object { $_['port'] -eq 'broke' })['error'] -like '*night: launch step 1 failed*') 'failed variant named'
    Assert-Equal 6 @(Read-ShotResults -Results $results -Parts).Count 'parts as they are'
    $root = New-ShotRepo
    foreach ($p in 'both', 'half', 'broke') { New-Item -ItemType Directory -Path (Join-Path $root "Ports/$p") -Force | Out-Null }
    $d = Copy-ShotDelivery -RepoRoot $root -Results $results -DayName 'Day' -NightName 'Night'
    Assert-Equal @('Ports/both/screenshots/day.png') @($d.Images) 'only the complete port''s changed image'
    $part = Get-Content -Raw (Join-Path $results 'both/result-day.json') | ConvertFrom-Json -AsHashtable
    Assert-True ((ConvertTo-ShotSummary -Result $part) -like '*both*, day): changed*') 'a job''s summary names its variant'
}

# What photograph.ps1 -Variant -Take -Report leaves: result-<variant>-<take>.json, and the take in takes/.
function New-TestTake([string]$Dir, [string]$Port, [string]$Variant, [int]$Take, $Pixels, [string]$Failure = '') {
    $d = Join-Path $Dir $Port
    New-Item -ItemType Directory -Path (Join-Path $d 'takes') -Force | Out-Null
    $variants = [ordered]@{}
    if ($Pixels) {
        New-TestPng (Join-Path $d 'takes' "$Variant-$Take.png") 2 $Pixels -Stamp @{ fingerprint = "new-$Port" } | Out-Null
        $variants[$Variant] = [ordered]@{ verdict = 'shot'; take = $Take; takes = 1; committed = $true; compare = $null }
    }
    $r = [ordered]@{ port = $Port; app = $Port.ToUpper(); variant = $Variant; take = $Take; status = $(if ($Pixels) { 'shot' } else { 'failed' })
                     why = 'port files changed'; error = $Failure; variants = $variants }
    ConvertTo-Json $r -Depth 6 | Set-Content (Join-Path $d "result-$Variant-$Take.json")
}

Test 'Run: takes shot in a job each get the take verdict in order, and a later take counts only when asked for' {
    $ShotD = @(@(10, 20, 30, 255), @(200, 100, 50, 255), @(0, 0, 0, 255), @(255, 255, 250, 255))
    $root = Join-Path $Tmp ('takes-' + [guid]::NewGuid().ToString('N'))
    $results = Join-Path $Tmp ('results-' + [guid]::NewGuid().ToString('N'))
    $cases = [ordered]@{
        same    = @($ShotA, $ShotB, $null)    # take 1 is the committed shot; take 3 failed, unasked
        back    = @($ShotB, $ShotA, $ShotC)   # take 2 is the committed shot
        confirm = @($ShotB, $ShotB, $null)    # takes 1 and 2 agree
        third   = @($ShotB, $ShotC, $ShotB)   # take 3 agrees with take 1
        flaky   = @($ShotB, $ShotC, $ShotD)   # no two agree
        broke   = @($ShotB, $null, $ShotB)    # take 2 was asked for and failed
    }
    foreach ($port in $cases.Keys) {
        $shots = Join-Path $root 'Ports' $port 'screenshots'
        New-Item -ItemType Directory -Path $shots -Force | Out-Null
        foreach ($v in 'day', 'night') { New-TestPng (Join-Path $shots "$v.png") 2 $ShotA | Out-Null }
        for ($t = 1; $t -le 3; $t++) {
            $px = $cases[$port][$t - 1]
            New-TestTake $results $port 'day' $t $px $(if ($px) { '' } else { 'launch step 1 failed' })
            New-TestTake $results $port 'night' $t $ShotA
        }
    }
    $merged = @(Read-ShotResults -Results $results -RepoRoot $root)
    $got = @($merged | ForEach-Object { $x = $_['variants']; "$($_['port']) $($_['status'])$(if ($x.Contains('day')) { " $($x['day']['verdict'])/$($x['day']['takes'])" })" })
    Assert-Equal @('back unchanged unchanged/2', 'broke failed', 'confirm changed changed/2', 'flaky failed', 'same unchanged unchanged/1', 'third changed changed/3') $got 'verdicts'
    $broke = $merged | Where-Object { $_['port'] -eq 'broke' }
    Assert-True ($broke['error'] -like '*day: take 2: launch step 1 failed*') "the failed take named: $($broke['error'])"
    Assert-True (($merged | Where-Object { $_['port'] -eq 'flaky' })['error'] -like '*day: three takes differ*') 'no two takes agree'
    Assert-Equal 'port files changed' ($merged | Where-Object { $_['port'] -eq 'confirm' })['why'] 'why of a changed port'
    Assert-Equal '' ($merged | Where-Object { $_['port'] -eq 'same' })['why'] 'no why when unchanged'
    Assert-Equal 1 ($merged | Where-Object { $_['port'] -eq 'same' })['variants']['night']['takes'] 'night matched on take 1'

    $d = Copy-ShotDelivery -RepoRoot $root -Results $results -DayName 'Day' -NightName 'Night'
    Assert-Equal @('Ports/confirm/screenshots/day.png', 'Ports/third/screenshots/day.png') @($d.Images) 'only changed images'
    Assert-True (Compare-ShotPixels -Path (Join-Path $root 'Ports/third/screenshots/day.png') -Other (Join-Path $results 'third/takes/day-3.png')).Same 'the confirming take is delivered'
    Assert-Equal @('Ports/back/screenshots/day.png', 'Ports/back/screenshots/night.png', 'Ports/confirm/screenshots/night.png',
                   'Ports/same/screenshots/day.png', 'Ports/same/screenshots/night.png', 'Ports/third/screenshots/night.png') @($d.Restamped) 'stamp only: unchanged images of ports that did not fail'
    Assert-Equal 'new-same' (Read-ShotStamp -Path (Join-Path $root 'Ports/same/screenshots/day.png'))['fingerprint'] 'restamped from a take'
    $part = Get-Content -Raw (Join-Path $results 'confirm/result-day-2.json') | ConvertFrom-Json -AsHashtable
    Assert-True ((ConvertTo-ShotSummary -Result $part) -like '*confirm*, day, take 2): shot*') "a take job's summary names its take: $(ConvertTo-ShotSummary -Result $part)"
    Assert-Equal 36 @(Read-ShotResults -Results $results -Parts).Count 'parts as they are'
}

Test 'Run: a pull request run reports whether each shot matches the committed one' {
    $r = @{ port = 'term'; app = 'Term'; status = 'changed'; why = 'port files changed'; error = ''; variants = [ordered]@{
        day = @{ verdict = 'unchanged'; takes = 1; committed = $true; compare = @{ same = $true; differ = 0; max_delta = 0; size = '' } }
        night = @{ verdict = 'changed'; takes = 2; committed = $true; compare = @{ same = $false; differ = 1200; max_delta = 3; size = '' } } } }
    $lines = ConvertTo-ShotSummary -Result $r
    Assert-True ($lines -like '*term*day*matches*') "day: $lines"
    Assert-True ($lines -like '*night*1200 pixels differ*up to 3 of 255*') "night: $lines"
    $r.variants.night = @{ verdict = 'changed'; takes = 2; committed = $false; compare = $null }
    Assert-True ((ConvertTo-ShotSummary -Result $r) -like '*night*no committed shot*') 'no committed shot'
    $r.variants.night = @{ verdict = 'changed'; takes = 2; committed = $true; compare = @{ same = $false; differ = 9; max_delta = 255; size = '2x2 against 4x1' } }
    Assert-True ((ConvertTo-ShotSummary -Result $r) -like '*night*2x2 against 4x1*') 'size'
    $f = ConvertTo-ShotSummary -Result @{ port = 'p'; app = 'P'; status = 'failed'; why = ''; error = "step failed`n  last line"; variants = @{} }
    Assert-True ($f -like '*p*failed*last line*') "failed: $f"
}

# A manual port in a shot repo: a recipe, a port.json name, and no shots.
function Add-ManualPort([string]$Root) {
    New-Item -ItemType Directory -Path (Join-Path $Root 'Ports/paid/dist/day') -Force | Out-Null
    Set-Content (Join-Path $Root 'Ports/paid/dist/day/theme.css') 'body {}'
    Set-Content (Join-Path $Root 'Ports/paid/port.json') '{ "name": "Paid App" }'
    Set-Content (Join-Path $Root 'Ports/paid/README.md') "# Paid`n`n**Tier:** 2`n`nInstall it."
    Set-Recipe (Join-Path $Root 'Ports') 'paid' ([ordered]@{ kind = 'document'; platform = 'linux'; manual = 'Needs a license.' })
}

Test 'Run: a manual port is listed stale with what changed, and fresh once its hand-taken shots are stamped' {
    $root = New-ShotRepo
    Add-ManualPort $root
    $t = Get-ShotTargets -RepoRoot $root
    Assert-Equal @() (Get-TargetNames $t) 'a manual port is never shot'
    $m = $t.Manual[0]
    Assert-Equal 'paid|Paid App|Needs a license.|document||False|' "$($m.port)|$($m.app)|$($m.reason)|$($m.kind)|$($m.scene)|$($m.shots)|$($m.why)" 'no shots yet'
    Assert-Equal (Get-PortFingerprint $root 'paid').Fingerprint $m.fingerprint 'fingerprint'
    $dir = Join-Path $root 'Ports/paid/screenshots'
    New-Item -ItemType Directory -Path $dir | Out-Null
    $stamp = New-ManualShotStamp -Fingerprint (Get-PortFingerprint $root 'paid')
    foreach ($v in 'day', 'night') { New-TestPng (Join-Path $dir "$v.png") 2 $ShotA -Stamp $stamp | Out-Null }
    $t = Get-ShotTargets -RepoRoot $root
    Assert-Equal @() @($t.Manual) 'stamped: not stale'
    Assert-Equal @('paid: Paid App') @($t.ManualFresh | ForEach-Object { "$($_.port): $($_.app)" }) 'fresh manual ports'
    Add-Content (Join-Path $root 'Ports/paid/dist/day/theme.css') 'p {}'
    $m = (Get-ShotTargets -RepoRoot $root).Manual[0]
    Assert-Equal 'True|port files changed' "$($m.shots)|$($m.why)" 'stale after a dist change'
    New-Item -ItemType Directory -Path (Join-Path $root 'build/photograph/scenes/document') | Out-Null
    Set-Content (Join-Path $root 'build/photograph/scenes/document/doc.md') '# Doc'
    $m = (Get-ShotTargets -RepoRoot $root).Manual[0]
    Assert-Equal 'build/photograph/scenes/document' $m.scene 'scene folder, once it exists'
    Assert-Equal 'port files changed; scene changed' $m.why 'every change named'
}

function New-ManualEntry([string]$Fingerprint = 'f1', [bool]$Shots = $false) {
    [ordered]@{ port = 'paid'; app = 'Paid App'; reason = 'Needs a license.'; kind = 'document'; scene = ''; fingerprint = $Fingerprint
                shots = $Shots; why = $(if ($Shots) { 'port files changed' } else { '' }) }
}
function New-TestIssue([int]$Number, [string]$State, [string]$Body = '', [string[]]$Comments = @(), [string]$Title = 'Screenshots for Paid App') {
    [ordered]@{ number = $Number; title = $Title; state = $State; body = $Body; comments = @(foreach ($c in $Comments) { [ordered]@{ body = $c } }) }
}
function Get-ActionLines($Actions) { @($Actions | Where-Object { $_ } | ForEach-Object { "$($_.action) $($_.number)".Trim() }) }

Test 'Run: a stale manual port gets one issue, created, reopened or kept, with one comment per new fingerprint' {
    $names = @{ DayName = 'Day'; NightName = 'Night'; Backdrops = @{ day = 'a plain #eeeeee fill (deeper)'; night = 'a plain #111111 fill (deeper)' }; RunUrl = 'https://example.invalid/run/1' }
    $other = New-TestIssue 5 'OPEN' -Title 'Screenshots for Other'

    $a = @(Get-ManualIssueActions -Manual @(New-ManualEntry) -Issues @($other) @names)
    Assert-Equal @('create') (Get-ActionLines $a) 'none yet: created'
    Assert-Equal 'Screenshots for Paid App' $a[0].title 'title'
    foreach ($want in '*Needs a license.*', '*no screenshots yet*', '*Day*a plain #eeeeee fill (deeper)*Ports/paid/screenshots/day.png*',
                      '*Night*a plain #111111 fill (deeper)*Ports/paid/screenshots/night.png*', '*pwsh build/photograph.ps1 -Port paid*',
                      '*document scene has no staged content*', '*example.invalid/run/1*', '*<!-- inglenook-screenshots paid f1 -->*') {
        Assert-True ($a[0].body -like $want) "body lacks $want`:`n$($a[0].body)"
    }
    Assert-True ($a[0].body -notmatch '—') 'no em dash'
    $created = New-TestIssue 7 'OPEN' $a[0].body

    Assert-Equal @() (Get-ActionLines (Get-ManualIssueActions -Manual @(New-ManualEntry) -Issues @($created) @names)) 'same fingerprint: nothing'
    $a = @(Get-ManualIssueActions -Manual @(New-ManualEntry 'f2' $true) -Issues @($created) @names)
    Assert-Equal @('comment 7') (Get-ActionLines $a) 'new fingerprint: one comment'
    Assert-True ($a[0].body -like '*stale: port files changed.*<!-- inglenook-screenshots paid f2 -->*') "comment: $($a[0].body)"
    $told = New-TestIssue 7 'OPEN' $created.body @('thanks', $a[0].body)
    Assert-Equal @() (Get-ActionLines (Get-ManualIssueActions -Manual @(New-ManualEntry 'f2' $true) -Issues @($told) @names)) 'told in a comment: nothing'

    $closed = @((New-TestIssue 3 'CLOSED'), (New-TestIssue 7 'CLOSED' $created.body))
    Assert-Equal @('reopen 7') (Get-ActionLines (Get-ManualIssueActions -Manual @(New-ManualEntry) -Issues $closed @names)) 'closed by hand, same fingerprint: reopened'
    Assert-Equal @('reopen 7', 'comment 7') (Get-ActionLines (Get-ManualIssueActions -Manual @(New-ManualEntry 'f2' $true) -Issues $closed @names)) 'stale again: reopened with a comment'

    $two = @((New-TestIssue 9 'OPEN' 'x'), (New-TestIssue 4 'OPEN' $created.body))
    Assert-Equal @('close 9') (Get-ActionLines (Get-ManualIssueActions -Manual @(New-ManualEntry) -Issues $two @names)) 'two open: the newer closes as a duplicate'
}

Test 'Run: a fresh manual port''s open issue closes' {
    $names = @{ DayName = 'Day'; NightName = 'Night' }
    $fresh = @([ordered]@{ port = 'paid'; app = 'Paid App' })
    $issues = @((New-TestIssue 7 'OPEN'), (New-TestIssue 3 'CLOSED'), (New-TestIssue 5 'OPEN' -Title 'Screenshots for Other'))
    $a = @(Get-ManualIssueActions -Fresh $fresh -Issues $issues @names)
    Assert-Equal @('close 7') (Get-ActionLines $a) 'open one closed'
    Assert-True ($a[0].body -like '*fresh*') "note: $($a[0].body)"
    Assert-Equal @() (Get-ActionLines (Get-ManualIssueActions -Fresh $fresh -Issues @($issues[1]) @names)) 'already closed: nothing'
    Assert-Equal @() (Get-ActionLines (Get-ManualIssueActions @names)) 'no manual port: nothing'
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

Test 'Entry: photograph.ps1 -Port on a manual recipe stamps the hand-taken shots and adds the table' {
    # A shot repo with the real script, modules and palette, so it runs as in the repo. No Docker.
    $root = New-ShotRepo
    Add-ManualPort $root
    Copy-Item (Join-Path $PSScriptRoot 'photograph.ps1') (Join-Path $root 'build/photograph.ps1') -Force
    Copy-Item (Join-Path $PSScriptRoot 'lib' '*.psm1') (Join-Path $root 'build/lib') -Force
    Copy-Item (Join-Path $PSScriptRoot '..' 'palette' 'palette.json') (Join-Path $root 'palette/palette.json') -Force
    $script = Join-Path $root 'build/photograph.ps1'
    $run = { $out = & (Get-Process -Id $PID).Path -NoProfile -File $script -Port paid 2>&1; @{ Exit = $LASTEXITCODE; Text = ($out | ForEach-Object { "$_" }) -join "`n" } }
    $dir = Join-Path $root 'Ports/paid/screenshots'

    $r = & $run
    Assert-Equal 1 $r.Exit "no shots: exit code, output:`n$($r.Text)"
    Assert-True ($r.Text -like '*manual recipe, so its screenshots are taken by hand: Needs a license.*no day.png or night.png yet*Ports/paid/screenshots/day.png*run this again*') "no shots: output:`n$($r.Text)"
    New-Item -ItemType Directory -Path $dir | Out-Null
    New-TestPng (Join-Path $dir 'day.png') 2 $ShotA | Out-Null
    $r = & $run
    Assert-True ($r.Exit -eq 1 -and $r.Text -like '*no night.png yet*') "one shot: $($r.Exit)`n$($r.Text)"
    Set-Content (Join-Path $dir 'night.png') 'not an image'
    $r = & $run
    Assert-True ($r.Exit -eq 1 -and $r.Text -like '*night.png is not a PNG*') "not a PNG: $($r.Exit)`n$($r.Text)"
    Assert-Equal $null (Read-ShotStamp -Path (Join-Path $dir 'day.png')) 'neither stamped when one fails'

    New-TestPng (Join-Path $dir 'night.png') 2 $ShotB | Out-Null
    $r = & $run
    Assert-Equal 0 $r.Exit "both shots: exit code, output:`n$($r.Text)"
    $f = (Get-PortFingerprint $root 'paid').Fingerprint
    Assert-True (-not (Test-ShotStale -Dir $dir -Fingerprint $f)) "stamped, fresh:`n$($r.Text)"
    Assert-Equal 'by hand' (Read-ShotStamp -Path (Join-Path $dir 'night.png'))['runner_image'] 'stamp says by hand'
    Assert-True (Compare-ShotPixels -Path (Join-Path $dir 'night.png') -Other (New-TestPng (Join-Path $Tmp 'b.png') 2 $ShotB)).Same 'pixels kept'
    $readme = Get-Content -Raw (Join-Path $root 'Ports/paid/README.md')
    $v = (Read-Palette -Path (Join-Path $root 'palette/palette.json')).Variants
    Assert-True ($readme.Contains("| $($v['day'].Name) | $($v['night'].Name) |") -and $readme.Contains("![$($v['day'].Name)](screenshots/day.png)")) "table:`n$readme"
    $r = & $run
    Assert-True ($r.Exit -eq 0 -and $r.Text -like '*already stamped*') "again: $($r.Exit)`n$($r.Text)"
    Assert-Equal $readme (Get-Content -Raw (Join-Path $root 'Ports/paid/README.md')) 'table added once'
}

# --- Summary ------------------------------------------------------------------

Remove-Item -Path $Tmp -Recurse -Force -ErrorAction SilentlyContinue
foreach ($f in $script:Failed) { Write-Host "FAIL: $f" -ForegroundColor Red }
Write-Host "$($script:Passed) passed, $($script:Failed.Count) failed."
if ($script:Failed.Count -gt 0) { exit 1 }
exit 0
