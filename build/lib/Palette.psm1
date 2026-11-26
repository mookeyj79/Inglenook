# The palette: loading and validating palette/palette.json, and every color
# calculation the build and the checks share: OKLCH to sRGB hex, gamut,
# contrast, wash, the terminal ANSI colors, and the contrast floor.
# One place, so what the checks measure is what the build writes.

Set-StrictMode -Version Latest

$Invariant = [cultureinfo]::InvariantCulture

# Both variants, always: Day is the light one, Night the dark one.
$VariantModes = [ordered]@{ day = 'light'; night = 'dark' }

# The nine plain neutrals and the twelve named colors, the same in both variants.
$NeutralNames = @('deeper', 'deep', 'base', 'raised', 'hover', 'line', 'faint', 'dim', 'text')
$ColorNames = @('firelight', 'ember', 'oxblood', 'clay', 'brass', 'moss', 'ivy', 'pine', 'steel', 'dusk', 'heather', 'rosewood')

# Roles point at a named color (or, for on_accent, a neutral per variant).
# Every one is required.
$RoleNames = @('accent', 'on_accent', 'error', 'warning', 'success', 'info', 'keyword', 'reference', 'literal', 'type', 'tag')

# Filters for colors. The CONTRIBUTING.md placeholder table is checked
# against this list.
$Filters = [ordered]@{
    ''       = 'hex'
    'nohash' = 'hex without #'
    'rgb'    = 'r, g, b'
    'sgr'    = 'r;g;b, for terminal escape codes such as 38;2;r;g;b'
    'comma'  = 'r,g,b with no spaces, for tools that take a comma list such as ripgrep'
    'wash'   = 'the color washed over base, #rrggbb'
    'clear'  = '#rrggbb00, fully transparent'
    'name'   = 'the neutral or named color drawn, by name'
}

# A channel outside 0..1 by more than this is reported as a gamut warning.
$GamutTolerance = 0.003

# Terminal ANSI slots (ADR 0005). The six hues map to named colors; their
# bright slots are the same hue, slightly stronger, computed here. Black and
# white map to neutrals by brightness.
$AnsiHues = [ordered]@{ red = 'ember'; green = 'moss'; yellow = 'brass'; blue = 'steel'; magenta = 'heather'; cyan = 'pine' }
$AnsiNeutrals = @{
    night = @{ black = 'raised'; bright_black = 'faint'; white = 'dim';  bright_white = 'text' }
    day   = @{ black = 'text';   bright_black = 'faint'; white = 'line'; bright_white = 'raised' }
}
$AnsiBright = @{ night = @{ Lightness = 0.05; Cap = 0.92 }; day = @{ Lightness = -0.05; Cap = 0.0 }; Chroma = 1.1 }
$AnsiSlots = @('black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white') | ForEach-Object { $_ }
$AnsiSlots = @($AnsiSlots) + @($AnsiSlots | ForEach-Object { "bright_$_" })

# Contrast floor (PHILOSOPHY.md). Solid surfaces only, measured as drawn.
$Floor = [ordered]@{
    TextOnBase     = 7.0
    TextTarget     = 10.0
    DimOnBase      = 4.5
    FaintOnBase    = 3.0
    ColorOnBase    = 4.5
    ColorOnSurface = 3.0    # on raised and on deep: short labels
    OnAccent       = 4.5
    TextOnWash     = 4.5
}

function Test-Number($Value) { return $Value -is [double] -or $Value -is [long] -or $Value -is [int] -or $Value -is [decimal] }

function ConvertTo-Srgb {
    <#
    .SYNOPSIS
        OKLCH to sRGB. Returns @{ Hex; Channels; Clip }: Channels are the
        unclamped gamma-encoded values (0 to 1 in gamut), Clip is the most
        any channel lies outside 0..1 (0 in gamut). Hex is clamped.
    .DESCRIPTION
        Björn Ottosson's OKLab matrices, then the sRGB transfer function.
    #>
    param([double]$L, [double]$C, [double]$H)
    $rad = $H * [math]::PI / 180
    $a = $C * [math]::Cos($rad)
    $b = $C * [math]::Sin($rad)
    $l_ = $L + 0.3963377774 * $a + 0.2158037573 * $b
    $m_ = $L - 0.1055613458 * $a - 0.0638541728 * $b
    $s_ = $L - 0.0894841775 * $a - 1.2914855480 * $b
    $l3 = $l_ * $l_ * $l_; $m3 = $m_ * $m_ * $m_; $s3 = $s_ * $s_ * $s_
    $lin = @(
        (4.0767416621 * $l3 - 3.3077115913 * $m3 + 0.2309699292 * $s3)
        (-1.2684380046 * $l3 + 2.6097574011 * $m3 - 0.3413193965 * $s3)
        (-0.0041960863 * $l3 - 0.7034186147 * $m3 + 1.7076147010 * $s3)
    )
    $enc = foreach ($x in $lin) {
        $ax = [math]::Abs($x)
        $v = if ($ax -le 0.0031308) { 12.92 * $ax } else { 1.055 * [math]::Pow($ax, 1 / 2.4) - 0.055 }
        if ($x -lt 0) { -$v } else { $v }
    }
    $clip = 0.0
    foreach ($v in $enc) { $clip = [math]::Max($clip, [math]::Max(-$v, $v - 1)) }
    $hex = '#' + (@(foreach ($v in $enc) { ([int][math]::Round([math]::Min(1.0, [math]::Max(0.0, $v)) * 255)).ToString('x2') }) -join '')
    return @{ Hex = $hex; Channels = @($enc); Clip = $clip }
}

function New-Swatch([string]$Name, [double]$L, [double]$C, [double]$H) {
    $s = ConvertTo-Srgb -L $L -C $C -H $H
    return @{ Name = $Name; L = $L; C = $C; H = $H; Hex = $s.Hex; Clip = $s.Clip; Channels = $s.Channels }
}

function Read-Oklch {
    # One {l, c, h} entry, or $null after adding every problem to $Errors.
    param($Raw, [string]$Where, $Errors)
    if ($Raw -isnot [System.Collections.IDictionary]) { $Errors.Add("$Where must be an OKLCH object: { l, c, h }."); return $null }
    $ok = $true
    foreach ($k in @($Raw.Keys)) { if ($k -notin 'l', 'c', 'h') { $Errors.Add("$Where.$k is not an OKLCH key. Use: l, c, h."); $ok = $false } }
    $limits = @{ l = @(0, 1); c = @(0, 0.4); h = @(0, 360) }
    foreach ($k in 'l', 'c', 'h') {
        $n = $Raw[$k]
        if (-not (Test-Number $n)) { $Errors.Add("$Where.$k must be a number."); $ok = $false; continue }
        $lo, $hi = $limits[$k]
        $bad = if ($k -eq 'h') { $n -lt $lo -or $n -ge $hi } else { $n -lt $lo -or $n -gt $hi }
        if ($bad) { $Errors.Add("$Where.$k must be from $lo to $hi$(if ($k -eq 'h') { ' (not including 360)' })."); $ok = $false }
    }
    if (-not $ok) { return $null }
    return @{ L = [double]$Raw['l']; C = [double]$Raw['c']; H = [double]$Raw['h'] }
}

function Read-Palette {
    <#
    .SYNOPSIS
        Loads palette.json. Returns @{ Meta; Variants; Roles; Errors }.
    .DESCRIPTION
        Variants is an ordered map of 'day' and 'night' to
        @{ Key; Name; Mode; Wash; Neutrals; Colors; Roles }. Neutrals and
        Colors map a name to a swatch: @{ Name; L; C; H; Hex; Clip }. Roles
        maps a role to the neutral or named color it points at in that
        variant. Errors lists every problem found. When Errors is not empty,
        Variants may be incomplete: do not build.
    .PARAMETER Data
        The parsed JSON instead of a file, as from ConvertFrom-Json -AsHashtable.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Path')][string]$Path,
        [Parameter(Mandatory, ParameterSetName = 'Data')]$Data
    )
    $errors = [System.Collections.Generic.List[string]]::new()
    $result = @{ Meta = @{}; Variants = [ordered]@{}; Errors = $errors }

    if ($PSCmdlet.ParameterSetName -eq 'Data') { $raw = $Data }
    else {
        if (-not (Test-Path $Path)) { $errors.Add('palette/palette.json does not exist.'); return $result }
        try { $raw = Get-Content -Raw -Path $Path | ConvertFrom-Json -AsHashtable }
        catch { $errors.Add("palette/palette.json is not valid JSON: $($_.Exception.Message)"); return $result }
    }

    if ($raw -isnot [System.Collections.IDictionary]) { $errors.Add('palette/palette.json must be an object.'); return $result }
    foreach ($k in @($raw.Keys)) { if ($k -notin 'meta', 'variants', 'roles') { $errors.Add("'$k' is not a palette section. Use: meta, variants, roles.") } }
    if ($raw['meta'] -is [System.Collections.IDictionary]) { $result.Meta = $raw['meta'] }
    foreach ($k in 'name', 'version') {
        if (-not $result.Meta.Contains($k)) { $errors.Add("meta.$k is missing.") }
    }
    if ($result.Meta.Contains('version') -and [string]$result.Meta['version'] -notmatch '^\d+\.\d+\.\d+$') { $errors.Add('meta.version must be x.y.z.') }
    if ($raw['variants'] -isnot [System.Collections.IDictionary]) { $errors.Add('variants is missing.'); return $result }

    foreach ($vKey in @($raw['variants'].Keys)) {
        if ($vKey -notin $VariantModes.Keys) { $errors.Add("variants.$vKey is not a known variant. Use: $($VariantModes.Keys -join ', ').") }
    }
    foreach ($vKey in $VariantModes.Keys) {
        $v = $raw['variants'][$vKey]
        if ($v -isnot [System.Collections.IDictionary]) { $errors.Add("variant '$vKey' is missing."); continue }
        foreach ($k in @($v.Keys)) { if ($k -notin 'name', 'mode', 'wash', 'neutrals', 'colors') { $errors.Add("variants.$vKey.$k is not a variant key. Use: name, mode, wash, neutrals, colors.") } }
        if (-not ($v['name'] -is [string] -and $v['name'].Trim())) { $errors.Add("variants.$vKey.name is missing.") }
        if ($v['mode'] -ne $VariantModes[$vKey]) { $errors.Add("variants.$vKey.mode must be '$($VariantModes[$vKey])'.") }
        $wash = $v['wash']
        if (-not (Test-Number $wash) -or $wash -le 0 -or $wash -ge 1) {
            $errors.Add("variants.$vKey.wash must be a number between 0 and 1.")
            $wash = $null
        }
        $sets = @{}
        foreach ($set in @(@{ Key = 'neutrals'; Names = $NeutralNames; What = 'neutral' }, @{ Key = 'colors'; Names = $ColorNames; What = 'named color' })) {
            $map = [ordered]@{}
            $src = $v[$set.Key]
            if ($src -isnot [System.Collections.IDictionary]) { $errors.Add("variants.$vKey.$($set.Key) is missing.") }
            else {
                foreach ($n in @($src.Keys)) { if ($n -notin $set.Names) { $errors.Add("variants.$vKey.$($set.Key).$n is not a $($set.What). Use: $($set.Names -join ', ').") } }
                foreach ($n in $set.Names) {
                    if (-not $src.Contains($n)) { $errors.Add("$vKey is missing $($set.What) '$n'."); continue }
                    $o = Read-Oklch $src[$n] "variants.$vKey.$($set.Key).$n" $errors
                    if ($o) { $map[$n] = New-Swatch $n $o.L $o.C $o.H }
                }
            }
            $sets[$set.Key] = $map
        }
        $result.Variants[$vKey] = @{
            Key = $vKey; Name = [string]$v['name']; Mode = [string]$v['mode']
            Wash = if ($null -ne $wash) { [double]$wash } else { $null }
            Neutrals = $sets['neutrals']; Colors = $sets['colors']; Roles = [ordered]@{}
        }
    }

    # Roles: one map for both variants. A value is a named color, or
    # { day, night } naming a neutral or named color per variant.
    $roles = $raw['roles']
    if ($roles -isnot [System.Collections.IDictionary]) { $errors.Add('roles is missing.'); return $result }
    foreach ($r in @($roles.Keys)) {
        if ($r -notin $RoleNames) { $errors.Add("roles.$r is not a role. Use: $($RoleNames -join ', ').") }
    }
    foreach ($r in $RoleNames) {
        if (-not $roles.Contains($r)) { $errors.Add("roles.$r is missing."); continue }
        $val = $roles[$r]
        foreach ($vKey in $VariantModes.Keys) {
            $target = $null
            if ($val -is [string]) {
                $target = $val
                if ($target -notin $ColorNames) { $errors.Add("roles.$r points at '$target', which is not a named color. A role shared by both variants names one of: $($ColorNames -join ', ')."); continue }
            }
            elseif ($val -is [System.Collections.IDictionary]) {
                foreach ($k in @($val.Keys)) { if ($k -notin $VariantModes.Keys) { $errors.Add("roles.$r.$k is not a variant.") } }
                $target = $val[$vKey]
                if (-not ($target -is [string] -and ($target -in $ColorNames -or $target -in $NeutralNames))) {
                    $errors.Add("roles.$r.$vKey must name a neutral or a named color."); continue
                }
            }
            else { $errors.Add("roles.$r must name a color, or be { day, night }."); break }
            if ($result.Variants.Contains($vKey)) { $result.Variants[$vKey].Roles[$r] = $target }
        }
    }
    return $result
}

function Get-VariantKeys { return @($VariantModes.Keys) }
function Get-NeutralNames { return $NeutralNames }
function Get-ColorNames { return $ColorNames }
function Get-RoleNames { return $RoleNames }
function Get-AnsiSlots { return $AnsiSlots }
# Every name a template can draw directly: neutrals, named colors, roles.
function Get-PaletteNames { return @($NeutralNames) + @($ColorNames) + @($RoleNames) }
function Get-ColorFilters { return @($Filters.Keys | Where-Object { $_ }) }
function Get-ContrastFloor { return $Floor }

function ConvertFrom-Hex([string]$Hex) {
    return @(foreach ($i in 1, 3, 5) { [Convert]::ToInt32($Hex.Substring($i, 2), 16) })
}

function Get-Blend {
    # The solid color of $Fg mixed into $Bg by $Weight (0 to 1), as #rrggbb.
    param([string]$Fg, [string]$Bg, [double]$Weight)
    $f = ConvertFrom-Hex $Fg
    $b = ConvertFrom-Hex $Bg
    $out = foreach ($i in 0, 1, 2) { ([int][math]::Round($f[$i] * $Weight + $b[$i] * (1 - $Weight))).ToString('x2') }
    return '#' + ($out -join '')
}

function Get-Contrast {
    # WCAG 2.x contrast ratio of two #rrggbb colors.
    param([string]$A, [string]$B)
    $lum = {
        param($Hex)
        $c = foreach ($v in (ConvertFrom-Hex $Hex)) {
            $s = $v / 255
            if ($s -le 0.04045) { $s / 12.92 } else { [math]::Pow(($s + 0.055) / 1.055, 2.4) }
        }
        0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2]
    }
    $la = & $lum $A
    $lb = & $lum $B
    if ($la -lt $lb) { $la, $lb = $lb, $la }
    return ($la + 0.05) / ($lb + 0.05)
}

function Get-WashColor {
    # A named color washed over the variant's base, as #rrggbb. This is what
    # {{color|wash}} writes and what the wash contrast is measured on.
    param($Variant, [string]$Color)
    return Get-Blend $Variant.Colors[$Color].Hex $Variant.Neutrals['base'].Hex $Variant.Wash
}

function Get-AnsiColor {
    <#
    .SYNOPSIS
        The color for a terminal ANSI slot in a variant:
        @{ Slot; Source; Hex; Bright }, or $null for an unknown slot. Source
        is the neutral or named color the slot comes from.
    .DESCRIPTION
        A bright hue slot is its normal color, slightly stronger: lightness
        moves by the variant's step (Night lighter, capped; Day darker) and
        chroma is multiplied, with the hue kept.
    #>
    param([string]$Slot, $Variant)
    $n = $AnsiNeutrals[$Variant.Key]
    if ($n -and $n.ContainsKey($Slot)) { return @{ Slot = $Slot; Source = $n[$Slot]; Hex = $Variant.Neutrals[$n[$Slot]].Hex; Bright = $false } }
    $bright = $Slot -like 'bright_*'
    $hue = $Slot -replace '^bright_', ''
    if (-not $AnsiHues.Contains($hue)) { return $null }
    $src = $AnsiHues[$hue]
    $c = $Variant.Colors[$src]
    if (-not $bright) { return @{ Slot = $Slot; Source = $src; Hex = $c.Hex; Bright = $false } }
    $step = $AnsiBright[$Variant.Key]
    $l = $c.L + $step.Lightness
    if ($step.Lightness -gt 0) { $l = [math]::Min($l, $step.Cap) } else { $l = [math]::Max($l, $step.Cap) }
    # Computed colors stay inside sRGB: where the stronger chroma would clip,
    # chroma is lowered until it fits, so hue and lightness are kept.
    $ch = $c.C * $AnsiBright.Chroma
    $s = ConvertTo-Srgb -L $l -C $ch -H $c.H
    while ($s.Clip -gt 0.001 -and $ch -gt 0) { $ch = [math]::Max(0.0, $ch - 0.002); $s = ConvertTo-Srgb -L $l -C $ch -H $c.H }
    return @{ Slot = $Slot; Source = $src; Hex = $s.Hex; Bright = $true; L = $l; C = $ch; H = $c.H; Clip = $s.Clip }
}

function Get-PaletteEntry {
    <#
    .SYNOPSIS
        What a name stands for in a variant: a neutral, a named color, a
        role, or ansi.<slot>. Returns @{ Name; Kind; Source; Hex; Washable },
        or $null for a name the palette does not have.
    .DESCRIPTION
        Source is the neutral or named color drawn. Washable is true when
        that is a named color, since only named colors are checked on a wash.
    #>
    param($Variant, [string]$Name)
    if ($Name -match '^ansi\.(.+)$') {
        $a = Get-AnsiColor -Slot $Matches[1] -Variant $Variant
        if (-not $a) { return $null }
        return @{ Name = $Name; Kind = 'ansi'; Source = $a.Source; Hex = $a.Hex; Washable = (-not $a.Bright -and $a.Source -in $ColorNames) }
    }
    $kind = 'neutral'; $src = $Name
    if ($Variant.Roles.Contains($Name)) { $kind = 'role'; $src = $Variant.Roles[$Name] }
    elseif ($Variant.Colors.Contains($Name)) { $kind = 'color' }
    elseif (-not $Variant.Neutrals.Contains($Name)) { return $null }
    $sw = if ($Variant.Colors.Contains($src)) { $Variant.Colors[$src] } else { $Variant.Neutrals[$src] }
    return @{ Name = $Name; Kind = $kind; Source = $src; Hex = $sw.Hex; Washable = ($src -in $ColorNames) }
}

function Format-PaletteColor {
    <#
    .SYNOPSIS
        A palette name's color in a variant, formatted by a filter. Throws on
        an unknown name or filter, or |wash on something that is not a named color.
    #>
    param($Variant, [string]$Name, [string]$Filter = '')
    $e = Get-PaletteEntry -Variant $Variant -Name $Name
    if (-not $e) { throw "unknown color '$Name'" }
    if (-not $Filters.Contains($Filter)) { throw "unknown filter '$Filter'. Use one of: $((Get-ColorFilters) -join ', ')" }
    if ($Filter -eq 'wash' -and -not $e.Washable) {
        throw "|wash only applies to named colors and the roles and ANSI slots that point at one, not '$Name'"
    }
    $hex = $e.Hex
    switch ($Filter) {
        ''       { return $hex }
        'nohash' { return $hex.Substring(1) }
        'rgb'    { return (ConvertFrom-Hex $hex) -join ', ' }
        'sgr'    { return (ConvertFrom-Hex $hex) -join ';' }
        'comma'  { return (ConvertFrom-Hex $hex) -join ',' }
        'clear'  { return $hex + '00' }
        'wash'   { return Get-WashColor $Variant $e.Source }
        'name'   { return $e.Source }
    }
}

function Get-GamutWarning {
    # Every neutral, named color, and bright ANSI color that clips by more
    # than the tolerance, as messages. Clipped colors are clamped, not refused.
    param($Palette)
    $out = [System.Collections.Generic.List[string]]::new()
    $say = {
        param([string]$Where, $Sw)
        if ($Sw.Clip -gt $GamutTolerance) {
            $out.Add(('{0} oklch({1} {2} {3}) is outside sRGB by {4:0.000}; it is clamped to {5}.' -f $Where,
                $Sw.L.ToString('0.####', $Invariant), $Sw.C.ToString('0.####', $Invariant), $Sw.H.ToString('0.##', $Invariant), $Sw.Clip, $Sw.Hex))
        }
    }
    foreach ($v in $Palette.Variants.Values) {
        foreach ($sw in @($v.Neutrals.Values) + @($v.Colors.Values)) { & $say "$($v.Key).$($sw.Name)" $sw }
        foreach ($hue in $AnsiHues.Keys) { & $say "$($v.Key).ansi.bright_$hue" (Get-AnsiColor -Slot "bright_$hue" -Variant $v) }
    }
    return $out.ToArray()
}

function Test-PaletteContrast {
    <#
    .SYNOPSIS
        Measures the contrast floor in PHILOSOPHY.md on a valid palette.
        Returns @{ Failures; Measurements }: Failures as a message list,
        Measurements as every ratio taken, passing or not, each
        @{ Variant; Role; Surface; Ratio; Floor; Pass }.
    .DESCRIPTION
        Every surface is solid and measured as drawn. On base: text, dim,
        faint, and every named color. On raised and on deep: every named
        color (short labels). on_accent on the accent. Text on a wash of
        every named color over base.
    #>
    param($Palette)
    $failures = [System.Collections.Generic.List[string]]::new()
    $measurements = [System.Collections.Generic.List[object]]::new()
    foreach ($v in $Palette.Variants.Values) {
        $k = $v.Key
        $measure = {
            param([string]$Role, [string]$Fg, [string]$Surface, [string]$Bg, [double]$Min)
            $ratio = Get-Contrast $Fg $Bg
            $measurements.Add([pscustomobject]@{ Variant = $k; Role = $Role; Surface = $Surface; Ratio = $ratio; Floor = $Min; Pass = $ratio -ge $Min })
            if ($ratio -lt $Min) { $failures.Add(('{0}.{1} on {2} is {3:0.00}:1, needs {4}:1.' -f $k, $Role, $Surface, $ratio, $Min)) }
        }
        $n = { param($x) $v.Neutrals[$x].Hex }
        & $measure 'text' (& $n 'text') 'base' (& $n 'base') $Floor.TextOnBase
        & $measure 'dim' (& $n 'dim') 'base' (& $n 'base') $Floor.DimOnBase
        & $measure 'faint' (& $n 'faint') 'base' (& $n 'base') $Floor.FaintOnBase
        foreach ($c in $v.Colors.Values) {
            & $measure $c.Name $c.Hex 'base' (& $n 'base') $Floor.ColorOnBase
            & $measure $c.Name $c.Hex 'raised' (& $n 'raised') $Floor.ColorOnSurface
            & $measure $c.Name $c.Hex 'deep' (& $n 'deep') $Floor.ColorOnSurface
        }
        $accent = Get-PaletteEntry $v 'accent'
        $on = Get-PaletteEntry $v 'on_accent'
        & $measure 'on_accent' $on.Hex 'accent' $accent.Hex $Floor.OnAccent
        foreach ($c in $v.Colors.Values) {
            & $measure 'text' (& $n 'text') "$($c.Name) wash" (Get-WashColor $v $c.Name) $Floor.TextOnWash
        }
    }
    return @{ Failures = $failures; Measurements = $measurements }
}

function Format-ContrastTable {
    <#
    .SYNOPSIS
        The contrast measurements of one variant as a table: one row per
        foreground, one column per surface. Returns lines of text.
    #>
    param($Palette, [string]$Variant, $Measurements)
    $v = $Palette.Variants[$Variant]
    $ms = @($Measurements | Where-Object Variant -eq $Variant)
    $get = { param($Role, $Surface) $m = @($ms | Where-Object { $_.Role -eq $Role -and $_.Surface -eq $Surface }); if ($m) { $m[0] } }
    $cell = { param($m) if (-not $m) { '' } else { $m.Ratio.ToString('0.00', $Invariant) + $(if ($m.Pass) { '' } else { '!' }) } }
    $f = $Floor
    $fmt = '  {0,-11} {1,7} {2,7} {3,7} {4,10}'
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("$($v.Name)")
    $lines.Add(($fmt -f '', 'base', 'raised', 'deep', 'text on'))
    $lines.Add(($fmt -f '', '', '', '', 'its wash'))
    foreach ($r in 'text', 'dim', 'faint') { $lines.Add(($fmt -f $r, (& $cell (& $get $r 'base')), '', '', '')) }
    foreach ($c in $v.Colors.Keys) {
        $lines.Add(($fmt -f $c, (& $cell (& $get $c 'base')), (& $cell (& $get $c 'raised')), (& $cell (& $get $c 'deep')), (& $cell (& $get 'text' "$c wash"))))
    }
    $lines.Add(('  {0,-11} {1,7}   on {2}' -f 'on_accent', (& $cell (& $get 'on_accent' 'accent')), $v.Roles['accent']))
    $lines.Add(('  Floors: text {0} (target about {1}), dim {2}, faint {3}, named colors {4} on base and {5} on raised and deep, text on a wash {6}, on_accent {7}. ! is under the floor.' -f
        $f.TextOnBase, $f.TextTarget, $f.DimOnBase, $f.FaintOnBase, $f.ColorOnBase, $f.ColorOnSurface, $f.TextOnWash, $f.OnAccent))
    return $lines.ToArray()
}

Export-ModuleMember -Function Read-Palette, Get-VariantKeys, Get-NeutralNames, Get-ColorNames, Get-RoleNames, Get-AnsiSlots, Get-PaletteNames,
    Get-ColorFilters, Get-ContrastFloor, ConvertTo-Srgb, ConvertFrom-Hex, Get-Blend, Get-Contrast, Get-WashColor, Get-AnsiColor,
    Get-PaletteEntry, Format-PaletteColor, Get-GamutWarning, Test-PaletteContrast, Format-ContrastTable
