# Building a port: rendering its template/ into dist/<variant>/ for every
# palette variant, and telling how a build compares with the committed dist/.
# build.ps1 writes with it; check.ps1 asks it whether dist/ is current, and
# whether every repo path can be checked out on Windows.

Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'Placeholders.psm1')
Import-Module (Join-Path $PSScriptRoot 'Shell.psm1')

function Read-PortValues([string]$PortDir) {
    $path = Join-Path $PortDir 'values.json'
    if (Test-Path $path) { return Get-Content -Raw -Path $path | ConvertFrom-Json -AsHashtable }
    return $null
}

# A solid image: one opaque color as an 8-bit RGB PNG, for apps whose themes
# take images (GRUB). The data is stored, not compressed, so a color and size
# always give the same bytes on every machine.
$PngCrcTable = [uint32[]]::new(256)
for ($n = 0; $n -lt 256; $n++) {
    $c = [uint32]$n
    for ($k = 0; $k -lt 8; $k++) { $c = if ($c -band 1) { [uint32]3988292384 -bxor ($c -shr 1) } else { $c -shr 1 } }
    $PngCrcTable[$n] = $c
}
# CRC-32 (the PNG and ZIP checksum) of a byte array.
function Get-Crc32([byte[]]$Data) {
    $crc = [uint32]::MaxValue
    foreach ($v in $Data) { $crc = $PngCrcTable[($crc -bxor $v) -band 0xFF] -bxor ($crc -shr 8) }
    return [uint32]($crc -bxor [uint32]::MaxValue)
}
function ConvertTo-PngUInt32([uint32]$Value) { $b = [BitConverter]::GetBytes($Value); [Array]::Reverse($b); return $b }

function New-SolidPng {
    param([Parameter(Mandatory)][string]$Hex, [int]$Width = 1, [int]$Height = 1)
    if ($Hex -notmatch '^#[0-9a-fA-F]{6}$') { throw "A solid image takes one #rrggbb color, not '$Hex'." }
    if ($Width -lt 1 -or $Height -lt 1 -or $Width -gt 256 -or $Height -gt 256) { throw "A solid image is 1 to 256 pixels on each side, not ${Width}x${Height}." }
    $rgb = [byte[]](0..2 | ForEach-Object { [Convert]::ToByte($Hex.Substring(1 + 2 * $_, 2), 16) })
    $raw = [System.IO.MemoryStream]::new()
    for ($y = 0; $y -lt $Height; $y++) {
        $raw.WriteByte(0)
        for ($x = 0; $x -lt $Width; $x++) { $raw.Write($rgb, 0, 3) }
    }
    $data = $raw.ToArray()
    $len = $data.Length
    $z = [System.IO.MemoryStream]::new()
    foreach ($v in 0x78, 0x01, 0x01, ($len -band 0xFF), (($len -shr 8) -band 0xFF), ((-bnot $len) -band 0xFF), (((-bnot $len) -shr 8) -band 0xFF)) { $z.WriteByte([byte]$v) }
    $z.Write($data, 0, $len)
    $a = 1; $b = 0
    foreach ($v in $data) { $a = ($a + $v) % 65521; $b = ($b + $a) % 65521 }
    $z.Write((ConvertTo-PngUInt32 ([uint32](([int64]$b -shl 16) -bor $a))), 0, 4)
    $ihdr = [byte[]](@(ConvertTo-PngUInt32 ([uint32]$Width)) + @(ConvertTo-PngUInt32 ([uint32]$Height)) + @(8, 2, 0, 0, 0))
    $out = [System.IO.MemoryStream]::new()
    $out.Write([byte[]](137, 80, 78, 71, 13, 10, 26, 10), 0, 8)
    foreach ($chunk in @(@('IHDR', $ihdr), @('IDAT', $z.ToArray()), @('IEND', [byte[]]@()))) {
        $body = [byte[]](@([System.Text.Encoding]::ASCII.GetBytes($chunk[0])) + @($chunk[1]))
        $out.Write((ConvertTo-PngUInt32 ([uint32]($body.Length - 4))), 0, 4)
        $out.Write($body, 0, $body.Length)
        $out.Write((ConvertTo-PngUInt32 (Get-Crc32 $body)), 0, 4)
    }
    return $out.ToArray()
}

# An SVG rendered to PNG with resvg, for apps whose themes take only raster
# images. The version is pinned in build/photograph/pins.json (resvg.version),
# so every machine draws the same pixels.
$ResvgPinsPath = Join-Path $PSScriptRoot '..' 'photograph' 'pins.json'

# Looked up once per run: the first .png.svg finds and checks it, the rest reuse it.
$script:ResvgCommand = $null

function Get-ResvgCommand {
    if ($script:ResvgCommand) { return $script:ResvgCommand }
    $want = [string](Get-Content -Raw -Path $ResvgPinsPath | ConvertFrom-Json -AsHashtable)['resvg']['version']
    $cmd = Get-Command resvg -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cmd) { throw "A .png.svg template needs resvg $want on the PATH. See CONTRIBUTING.md." }
    $have = (& $cmd.Source --version 2>&1 | Out-String).Trim()
    if ($have -ne $want) { throw "A .png.svg template needs resvg $want (pinned in build/photograph/pins.json), not $have." }
    $script:ResvgCommand = $cmd.Source
    return $script:ResvgCommand
}

function ConvertTo-SvgPng {
    param([Parameter(Mandatory)][string]$Svg, [Parameter(Mandatory)][string]$Source)
    if ($Svg -notmatch '<svg\b[^>]*\swidth="\d+"' -or $Svg -notmatch '<svg\b[^>]*\sheight="\d+"') {
        throw "${Source}: a .png.svg sets its size in pixels on the <svg> element, such as width=`"32`" height=`"32`"."
    }
    $resvg = Get-ResvgCommand
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('inglenook-svg-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
        $in = Join-Path $tmp 'in.svg'; $out = Join-Path $tmp 'out.png'
        [System.IO.File]::WriteAllText($in, $Svg)
        $msg = & $resvg $in $out 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path $out)) { throw "${Source}: resvg could not render it. $($msg.Trim())" }
        return [System.IO.File]::ReadAllBytes($out)
    }
    finally { Remove-Item -Path $tmp -Recurse -Force }
}

# A ZIP archive of a folder's files, stored (not compressed), sorted by path,
# dated 1980-01-01, so the same files always give the same bytes on every
# machine. For apps whose theme is one archive (Telegram's .tdesktop-theme).
function New-StoredZip {
    param([Parameter(Mandatory)][string]$Dir)
    $files = @(Get-ChildItem -Path $Dir -Recurse -File -Force | ForEach-Object {
        @{ Name = ([System.IO.Path]::GetRelativePath($Dir, $_.FullName) -replace '\\', '/'); Path = $_.FullName }
    } | Sort-Object { $_.Name } -Culture '')
    $out = [System.IO.MemoryStream]::new()
    $central = [System.IO.MemoryStream]::new()
    $le16 = { param($v) [BitConverter]::GetBytes([uint16]$v) }
    $le32 = { param($v) [BitConverter]::GetBytes([uint32]$v) }
    $date = 33  # 1980-01-01 in DOS date form; time 0
    foreach ($f in $files) {
        $data = [System.IO.File]::ReadAllBytes($f.Path)
        $name = [System.Text.Encoding]::UTF8.GetBytes($f.Name)
        $crc = Get-Crc32 $data
        $offset = $out.Position
        $common = [byte[]](@(& $le16 20) + @(& $le16 0x0800) + @(& $le16 0) + @(& $le16 0) + @(& $le16 $date) +
            @(& $le32 $crc) + @(& $le32 $data.Length) + @(& $le32 $data.Length) + @(& $le16 $name.Length) + @(& $le16 0))
        foreach ($b in @([byte[]](0x50, 0x4B, 3, 4), $common, $name, $data)) { $out.Write($b, 0, $b.Length) }
        $entry = [byte[]](@(0x50, 0x4B, 1, 2) + @(& $le16 20) + @($common) + @(& $le16 0) + @(& $le16 0) + @(& $le16 0) + @(& $le32 0) + @(& $le32 $offset))
        foreach ($b in @($entry, $name)) { $central.Write($b, 0, $b.Length) }
    }
    $cd = $central.ToArray()
    $start = $out.Position
    $out.Write($cd, 0, $cd.Length)
    $end = [byte[]](@(0x50, 0x4B, 5, 6) + @(& $le16 0) + @(& $le16 0) + @(& $le16 $files.Count) + @(& $le16 $files.Count) +
        @(& $le32 $cd.Length) + @(& $le32 $start) + @(& $le16 0))
    $out.Write($end, 0, $end.Length)
    return $out.ToArray()
}

# The path without its suffix: 'media/divider.svg.ornament' less '.ornament'.
function Remove-Suffix([string]$Path, [string]$Suffix) { return $Path.Substring(0, $Path.Length - $Suffix.Length) }

# The path of one ornament in assets/ornaments/, by file name, such as 'divider.svg'.
function Get-OrnamentPath([string]$Dir, [string]$Name, [string]$Source, [string]$Form) {
    $from = Join-Path $Dir $Name
    if ($Name -notmatch '^[A-Za-z0-9_.-]+$' -or -not (Test-Path -LiteralPath $from -PathType Leaf)) {
        throw "${Source}: $Form names an ornament, and '$Name' is not in assets/ornaments/."
    }
    return $from
}

# A .png.svg's {{ornament:<file>}}: the shapes inside that ornament's <svg>
# element, so the template's own <svg> sets the size and the color.
$OrnamentReference = '\{\{\s*ornament:([^}\s]*)\s*\}\}'
function Expand-OrnamentReference([string]$Text, [string]$Dir, [string]$Source) {
    return [regex]::Replace($Text, $OrnamentReference, {
        param($m)
        $path = Get-OrnamentPath $Dir $m.Groups[1].Value $Source '{{ornament:<file>}}'
        $svg = [System.IO.File]::ReadAllText($path)
        $inner = [regex]::Match($svg, '(?s)<svg\b[^>]*>(.*)</svg>')
        if (-not $inner.Success) { throw "${Source}: assets/ornaments/$($m.Groups[1].Value) is not an <svg> element." }
        return $inner.Groups[1].Value
    })
}

# What the build makes of a template file, by the end of its built name. Each
# handler takes the file's context ($c: Target, Tpl, Source, OrnamentDir, and the
# Palette, Variant and port Values that Expand-Kind fills placeholders from) and returns the files to write, as
# path = text or bytes. A file that ends in none of these is written as rendered.
function Expand-Kind($c, [string]$Text) {
    return Expand-Template -Text $Text -Palette $c.Palette -Variant $c.Variant -PortValues $c.Values -Source $c.Source
}

$TemplateKinds = [ordered]@{
    # The file name of one ornament, such as 'divider.svg', becomes <name>, a copy of it.
    '.ornament' = {
        param($c)
        $from = Get-OrnamentPath $c.OrnamentDir $c.Tpl.Text.Trim() $c.Source 'a .ornament'
        [ordered]@{ (Remove-Suffix $c.Target '.ornament') = [System.IO.File]::ReadAllBytes($from) }
    }
    # One color placeholder and an optional size, such as '{{accent|wash}} 8x8', becomes <name>.png of that color.
    '.png.fill' = {
        param($c)
        $m = [regex]::Match((Expand-Kind $c $c.Tpl.Text).Trim(), '^(#[0-9a-fA-F]{6})(?:\s+(\d+)x(\d+))?$')
        if (-not $m.Success) { throw "$($c.Source): a .png.fill holds one color placeholder and an optional size, such as '{{accent|wash}} 8x8'." }
        $size = if ($m.Groups[2].Success) { @([int]$m.Groups[2].Value, [int]$m.Groups[3].Value) } else { @(1, 1) }
        [ordered]@{ (Remove-Suffix $c.Target '.fill') = (New-SolidPng -Hex $m.Groups[1].Value -Width $size[0] -Height $size[1]) }
    }
    # An SVG with color placeholders and {{ornament:<file>}}, such as an ornament in
    # color="{{oxblood}}", becomes <name>.png at its own width and height.
    '.png.svg' = {
        param($c)
        $svg = Expand-Kind $c (Expand-OrnamentReference -Text $c.Tpl.Text -Dir $c.OrnamentDir -Source $c.Source)
        [ordered]@{ (Remove-Suffix $c.Target '.svg') = (ConvertTo-SvgPng -Svg $svg -Source $c.Source) }
    }
    # A shell-variable tool: one .env becomes a .sh and a .ps1.
    '.env' = {
        param($c)
        $shell = ConvertFrom-EnvText -Text (Expand-Kind $c $c.Tpl.Text) -Source $c.Source
        $stem = Remove-Suffix $c.Target '.env'
        [ordered]@{ "$stem.sh" = $shell.sh; "$stem.ps1" = $shell.ps1 }
    }
}

function Write-PortFiles {
    # Renders the port into $OutRoot/<variant>/, replacing what is there.
    # Returns the number of files written. Throws on a bad placeholder.
    param($Palette, [string]$PortDir, [string]$OutRoot)
    $name = Split-Path -Leaf $PortDir
    $templateDir = Join-Path $PortDir 'template'
    $files = @(Get-ChildItem -Path $templateDir -Recurse -File -Force)
    $values = Read-PortValues $PortDir
    # A port sits at <repo>/Ports/<name>/, so its ornaments are at <repo>/assets/ornaments/.
    $ornamentDir = Join-Path (Split-Path -Parent (Split-Path -Parent $PortDir)) 'assets' 'ornaments'
    $count = 0
    foreach ($variant in $Palette.Variants.Values) {
        $outDir = Join-Path $OutRoot $variant.Key
        if (Test-Path $outDir) { Remove-Item -Path $outDir -Recurse -Force }
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
        foreach ($file in $files) {
            $rel = [System.IO.Path]::GetRelativePath($templateDir, $file.FullName)
            $source = "Ports/$name/template/$($rel -replace '\\', '/')"
            $relOut = Expand-Template -Text $rel -Palette $Palette -Variant $variant -PortValues $values -Source "$source (file name)"
            $target = Join-Path $outDir $relOut
            $targetDir = Split-Path -Parent $target
            if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
            $tpl = Read-TemplateFile -Path $file.FullName
            if ($tpl.Binary) { [System.IO.File]::WriteAllBytes($target, $tpl.Bytes); $count++; continue }
            $c = @{ Target = $target; Tpl = $tpl; Source = $source; OrnamentDir = $ornamentDir; Palette = $Palette; Variant = $variant; Values = $values }
            $kind = @($TemplateKinds.Keys | Where-Object { $target -like "*$_" }) | Select-Object -First 1
            $outputs = if ($kind) { & $TemplateKinds[$kind] $c } else { [ordered]@{ $target = (Expand-Kind $c $tpl.Text) } }
            foreach ($out in $outputs.Keys) {
                $data = $outputs[$out]
                $bytes = if ($data -is [string]) { [byte[]](@($tpl.Encoding.GetPreamble()) + @($tpl.Encoding.GetBytes($data))) } else { [byte[]]$data }
                [System.IO.File]::WriteAllBytes($out, $bytes)
                $count++
            }
        }
        # A folder named <name>.zip, such as {{variant.slug}}.tdesktop-theme.zip/,
        # becomes the ZIP archive <name> of its built files.
        $packs = @(Get-ChildItem -Path $outDir -Recurse -Directory -Force | Where-Object Name -like '*.zip' |
            Sort-Object { $_.FullName.Length } -Descending)
        foreach ($pack in $packs) {
            $inside = @(Get-ChildItem -Path $pack.FullName -Recurse -File -Force).Count
            $zip = New-StoredZip -Dir $pack.FullName
            Remove-Item -Path $pack.FullName -Recurse -Force
            [System.IO.File]::WriteAllBytes((Remove-Suffix $pack.FullName '.zip'), $zip)
            # The one archive replaces the files inside it, which were counted as written.
            $count = $count - $inside + 1
        }
    }
    return $count
}

# A version stamp is the palette version ({{meta.version}}) as a template writes it:
# x.y.z, not inside a longer dotted number.
$VersionNumber = '\d+\.\d+\.\d+'

function Remove-VersionStamp {
    <#
    .SYNOPSIS
        The text with each version stamp read as X.Y.Z. With -Version, only
        that version is a stamp (the palette's, in a tree whose dist/ is
        current); without it, any x.y.z is, for comparing two builds of
        different palette versions.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text, [string]$Version)
    $number = if ($Version) { [regex]::Escape($Version) } else { $VersionNumber }
    return $Text -creplace "(?<![\d.])$number(?!\.?\d)", 'X.Y.Z'
}

function Get-Snapshot([string]$Root) {
    # Relative path -> content. Text has line endings normalized, so a CRLF
    # checkout is not a change; binary files are compared by hash.
    $snap = @{}
    if (-not (Test-Path $Root)) { return $snap }
    foreach ($f in Get-ChildItem -Path $Root -Recurse -File -Force) {
        $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName) -replace '\\', '/'
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        $snap[$rel] = if ([Array]::IndexOf($bytes, [byte]0) -ge 0) { 'bin:' + (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash }
                      else { 'txt:' + ([System.Text.Encoding]::UTF8.GetString($bytes) -replace "`r`n", "`n") }
    }
    return $snap
}

function Compare-Snapshot($Old, $New) {
    # @{ Status; Files }. Status is 'new', 'unchanged', 'version stamp only'
    # (only x.y.z version numbers differ), or 'changed'. Files lists each
    # differing path with 'missing' (in New only), 'extra' (in Old only), or
    # 'out of date'.
    $files = [System.Collections.Generic.List[object]]::new()
    if ($Old.Count -eq 0) { return @{ Status = 'new'; Files = $files } }
    $stampOnly = $false
    $changed = $false
    foreach ($k in @(@($Old.Keys) + @($New.Keys) | Sort-Object -Unique)) {
        if (-not $Old.ContainsKey($k)) { $files.Add(@{ Path = $k; Kind = 'missing' }); $changed = $true; continue }
        if (-not $New.ContainsKey($k)) { $files.Add(@{ Path = $k; Kind = 'extra' }); $changed = $true; continue }
        if ($Old[$k] -ceq $New[$k]) { continue }
        $files.Add(@{ Path = $k; Kind = 'out of date' })
        if ((Remove-VersionStamp $Old[$k]) -ceq (Remove-VersionStamp $New[$k])) { $stampOnly = $true }
        else { $changed = $true }
    }
    $status = if ($changed) { 'changed' } elseif ($stampOnly) { 'version stamp only' } else { 'unchanged' }
    return @{ Status = $status; Files = $files }
}

function Get-PortStatus {
    <#
    .SYNOPSIS
        How a fresh build of the port compares with its committed dist/,
        without touching dist/. Returns @{ Status; Files } (see Update-Port).
    #>
    param($Palette, [string]$PortDir)
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('inglenook-' + [guid]::NewGuid().ToString('N'))
    try {
        $null = Write-PortFiles -Palette $Palette -PortDir $PortDir -OutRoot $tmp
        return Compare-Snapshot (Get-Snapshot (Join-Path $PortDir 'dist')) (Get-Snapshot $tmp)
    }
    finally {
        if (Test-Path $tmp) { Remove-Item -Path $tmp -Recurse -Force }
    }
}

function Update-Port {
    <#
    .SYNOPSIS
        Builds the port into its dist/. Returns @{ Status; Files; Written }.
    .DESCRIPTION
        Status says what changed in dist/: 'new', 'unchanged',
        'version stamp only' (only the palette version moved), or 'changed'.
        Files lists each path that differed. Throws on a bad placeholder.
    #>
    param($Palette, [string]$PortDir)
    $dist = Join-Path $PortDir 'dist'
    $old = Get-Snapshot $dist
    $written = Write-PortFiles -Palette $Palette -PortDir $PortDir -OutRoot $dist
    $result = Compare-Snapshot $old (Get-Snapshot $dist)
    $result['Written'] = $written
    return $result
}

# Characters Windows does not allow in a file or folder name.
$WindowsForbidden = '<>:"|?*'

function Find-WindowsPathError {
    # Every path in $Path (repo-relative, '/' between parts) that Windows can
    # not check out, as messages: a forbidden or control character in any part,
    # or a part that ends in a space or a dot. Empty when every path is fine.
    param([string[]]$Path)
    $errs = [System.Collections.Generic.List[string]]::new()
    foreach ($p in $Path) {
        $why = $null
        foreach ($part in $p -split '/') {
            foreach ($c in $part.ToCharArray()) {
                if ($WindowsForbidden.Contains($c)) { $why = "has '$c', which Windows does not allow in a file name"; break }
                if ([int]$c -lt 32) { $why = 'has a control character'; break }
            }
            if (-not $why -and $part.EndsWith(' ')) { $why = "has a part, '$part', that ends in a space" }
            if (-not $why -and $part.EndsWith('.') -and $part -notin '.', '..') { $why = "has a part, '$part', that ends in a dot" }
            if ($why) { break }
        }
        if ($why) { $errs.Add("$p $why. Windows can not check it out.") }
    }
    return @($errs)
}

Export-ModuleMember -Function Get-PortStatus, Update-Port, Remove-VersionStamp, Find-WindowsPathError
