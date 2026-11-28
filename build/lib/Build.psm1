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
        $crc = [uint32]::MaxValue
        foreach ($v in $body) { $crc = $PngCrcTable[($crc -bxor $v) -band 0xFF] -bxor ($crc -shr 8) }
        $out.Write((ConvertTo-PngUInt32 ([uint32]($body.Length - 4))), 0, 4)
        $out.Write($body, 0, $body.Length)
        $out.Write((ConvertTo-PngUInt32 ($crc -bxor [uint32]::MaxValue)), 0, 4)
    }
    return $out.ToArray()
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
            if ($target -like '*.ornament') {
                # An ornament: the file name of one in assets/ornaments/, such as
                # 'divider.svg', becomes <name> without .ornament, copied as it is.
                $ornament = $tpl.Text.Trim()
                $from = Join-Path $ornamentDir $ornament
                if ($ornament -notmatch '^[A-Za-z0-9_.-]+$' -or -not (Test-Path -LiteralPath $from -PathType Leaf)) {
                    throw "${source}: a .ornament holds the file name of an ornament, and '$ornament' is not in assets/ornaments/."
                }
                [System.IO.File]::WriteAllBytes($target.Substring(0, $target.Length - 9), [System.IO.File]::ReadAllBytes($from))
                $count++
                continue
            }
            $text = Expand-Template -Text $tpl.Text -Palette $Palette -Variant $variant -PortValues $values -Source $source
            if ($target -like '*.png.fill') {
                # A solid image: one color placeholder and an optional size, such as
                # '{{accent|wash}} 8x8', becomes <name>.png of that color.
                $m = [regex]::Match($text.Trim(), '^(#[0-9a-fA-F]{6})(?:\s+(\d+)x(\d+))?$')
                if (-not $m.Success) { throw "${source}: a .png.fill holds one color placeholder and an optional size, such as '{{accent|wash}} 8x8'." }
                $size = if ($m.Groups[2].Success) { @([int]$m.Groups[2].Value, [int]$m.Groups[3].Value) } else { @(1, 1) }
                $png = New-SolidPng -Hex $m.Groups[1].Value -Width $size[0] -Height $size[1]
                [System.IO.File]::WriteAllBytes($target.Substring(0, $target.Length - 5), $png)
                $count++
                continue
            }
            $outputs = [ordered]@{ $target = $text }
            if ($target -like '*.env') {
                # A shell-variable tool: one .env becomes a .sh and a .ps1.
                $shell = ConvertFrom-EnvText -Text $text -Source $source
                $stem = $target.Substring(0, $target.Length - 4)
                $outputs = [ordered]@{ "$stem.sh" = $shell.sh; "$stem.ps1" = $shell.ps1 }
            }
            foreach ($out in $outputs.Keys) {
                $bytes = [byte[]](@($tpl.Encoding.GetPreamble()) + @($tpl.Encoding.GetBytes($outputs[$out])))
                [System.IO.File]::WriteAllBytes($out, $bytes)
                $count++
            }
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
