# PNG files: the stamp in a shot's text chunk, and a decoder that compares two
# shots by their pixels and writes a crop of a grab. Reads and writes PNG files
# only; what a stamp holds and what a comparison means are Photographer.psm1's.

Set-StrictMode -Version Latest

# --- The stamp: a shot's fingerprint and what it was made from, in a text chunk

$PngSignature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
$StampKeyword = 'inglenook'
$CrcTable = [uint32[]]::new(256)
for ($n = 0; $n -lt 256; $n++) {
    $c = [uint32]$n
    for ($k = 0; $k -lt 8; $k++) { $c = if ($c -band 1) { [uint32]3988292384 -bxor ($c -shr 1) } else { $c -shr 1 } }
    $CrcTable[$n] = $c
}

function Get-PngCrc([byte[]]$Bytes) {
    $c = [uint32]::MaxValue
    foreach ($b in $Bytes) { $c = $CrcTable[($c -bxor $b) -band 0xFF] -bxor ($c -shr 8) }
    return $c -bxor [uint32]::MaxValue
}

function ConvertTo-BigEndian([uint32]$Value) {
    $b = [BitConverter]::GetBytes($Value); [Array]::Reverse($b); return $b
}

function Get-PngChunks([string]$Path) {
    # Each chunk as @{ Type; Data; Raw } (Raw: length, type, data and CRC).
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $isPng = $bytes.Length -ge 8
    for ($i = 0; $isPng -and $i -lt 8; $i++) { if ($bytes[$i] -ne $PngSignature[$i]) { $isPng = $false } }
    if (-not $isPng) { throw "$Path is not a PNG." }
    $chunks = [System.Collections.Generic.List[object]]::new()
    $at = 8
    while ($at + 12 -le $bytes.Length) {
        $len = [int](([uint32]$bytes[$at] -shl 24) -bor ([uint32]$bytes[$at + 1] -shl 16) -bor ([uint32]$bytes[$at + 2] -shl 8) -bor $bytes[$at + 3])
        $type = [System.Text.Encoding]::ASCII.GetString($bytes, $at + 4, 4)
        $data = [byte[]]::new($len); [Array]::Copy($bytes, $at + 8, $data, 0, $len)
        $raw = [byte[]]::new($len + 12); [Array]::Copy($bytes, $at, $raw, 0, $len + 12)
        $chunks.Add(@{ Type = $type; Data = $data; Raw = $raw })
        $at += 12 + $len
        if ($type -eq 'IEND') { break }
    }
    return $chunks
}

function Get-StampText($Chunk) {
    # The text of a stamp chunk, or $null if the chunk is not one.
    if ($Chunk.Type -ne 'tEXt') { return $null }
    $data = [byte[]]$Chunk.Data
    $prefix = [System.Text.Encoding]::Latin1.GetBytes("$StampKeyword`0")
    if ($data.Length -lt $prefix.Length) { return $null }
    for ($i = 0; $i -lt $prefix.Length; $i++) { if ($data[$i] -ne $prefix[$i]) { return $null } }
    return [System.Text.Encoding]::Latin1.GetString($data, $prefix.Length, $data.Length - $prefix.Length)
}

function Read-ShotStamp {
    <#
    .SYNOPSIS
        The stamp in a shot's PNG text chunk (keyword 'inglenook') as an ordered
        hashtable, or $null if it has none.
    #>
    param([Parameter(Mandatory)][string]$Path)
    foreach ($c in Get-PngChunks $Path) {
        $text = Get-StampText $c
        if ($null -ne $text) { return ConvertFrom-Json -InputObject $text -AsHashtable }
    }
    return $null
}

function Write-ShotStamp {
    <#
    .SYNOPSIS
        Writes a stamp into a shot's PNG as one tEXt chunk (keyword 'inglenook',
        compact JSON) before IEND, replacing any stamp it had. The image chunks
        are kept byte for byte.
    #>
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)]$Stamp)
    $chunks = Get-PngChunks $Path
    $json = ConvertTo-Json -InputObject $Stamp -Depth 5 -Compress
    $body = [System.Text.Encoding]::Latin1.GetBytes("tEXt$StampKeyword`0$json")
    $out = [System.IO.MemoryStream]::new()
    $out.Write($PngSignature, 0, 8)
    foreach ($c in $chunks) {
        if ($null -ne (Get-StampText $c)) { continue }
        if ($c.Type -eq 'IEND') {
            $out.Write((ConvertTo-BigEndian ($body.Length - 4)), 0, 4)
            $out.Write($body, 0, $body.Length)
            $out.Write((ConvertTo-BigEndian (Get-PngCrc $body)), 0, 4)
        }
        $raw = [byte[]]$c.Raw
        $out.Write($raw, 0, $raw.Length)
    }
    [System.IO.File]::WriteAllBytes($Path, $out.ToArray())
}

# --- Pixels: decoded, compared exactly, and cropped ----------------------------

# A PNG decoder of our own, so two shots compare by what they show, whatever
# filters or chunks their files hold. Compiled the first time a shot is compared.
$PngPixelsSource = @'
using System;
using System.IO;
using System.IO.Compression;

public static class InglenookPngPixels {
    // Every pixel as 16-bit RGBA, whatever the PNG's color type and bit depth.
    public static ushort[] Decode(byte[] f, out int width, out int height) {
        int at = 8, depth = 0, type = 0, interlace = 0;
        width = 0; height = 0;
        byte[] plte = null, trns = null;
        var idat = new MemoryStream();
        while (at + 8 <= f.Length) {
            int len = (f[at] << 24) | (f[at + 1] << 16) | (f[at + 2] << 8) | f[at + 3];
            string t = System.Text.Encoding.ASCII.GetString(f, at + 4, 4);
            int d = at + 8;
            if (t == "IHDR") {
                width = (f[d] << 24) | (f[d + 1] << 16) | (f[d + 2] << 8) | f[d + 3];
                height = (f[d + 4] << 24) | (f[d + 5] << 16) | (f[d + 6] << 8) | f[d + 7];
                depth = f[d + 8]; type = f[d + 9]; interlace = f[d + 12];
            }
            else if (t == "PLTE") { plte = new byte[len]; Array.Copy(f, d, plte, 0, len); }
            else if (t == "tRNS") { trns = new byte[len]; Array.Copy(f, d, trns, 0, len); }
            else if (t == "IDAT") idat.Write(f, d, len);
            else if (t == "IEND") break;
            at = d + len + 4;
        }
        if (interlace != 0) throw new InvalidDataException("interlaced PNGs are not read");
        int channels = type == 0 ? 1 : type == 2 ? 3 : type == 3 ? 1 : type == 4 ? 2 : 4;
        int bitsPerPixel = channels * depth;
        int bpp = Math.Max(1, bitsPerPixel / 8);
        int stride = (width * bitsPerPixel + 7) / 8;
        var raw = new byte[height * stride];
        idat.Position = 0;
        using (var z = new ZLibStream(idat, CompressionMode.Decompress)) {
            var prev = new byte[stride];
            var line = new byte[stride + 1];
            for (int y = 0; y < height; y++) {
                int got = 0;
                while (got < line.Length) { int n = z.Read(line, got, line.Length - got); if (n == 0) throw new InvalidDataException("truncated image data"); got += n; }
                int filter = line[0];
                for (int x = 0; x < stride; x++) {
                    int a = x >= bpp ? raw[y * stride + x - bpp] : 0;
                    int b = prev[x];
                    int c = x >= bpp ? prev[x - bpp] : 0;
                    int p;
                    switch (filter) {
                        case 0: p = 0; break;
                        case 1: p = a; break;
                        case 2: p = b; break;
                        case 3: p = (a + b) >> 1; break;
                        case 4: { int q = a + b - c, pa = Math.Abs(q - a), pb = Math.Abs(q - b), pc = Math.Abs(q - c); p = (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c); break; }
                        default: throw new InvalidDataException("unknown row filter " + filter);
                    }
                    raw[y * stride + x] = (byte)(line[x + 1] + p);
                }
                Array.Copy(raw, y * stride, prev, 0, stride);
            }
        }
        var px = new ushort[width * height * 4];
        int max = (1 << depth) - 1;
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                var s = new int[channels];
                for (int k = 0; k < channels; k++) {
                    if (depth == 16) { int o = y * stride + (x * channels + k) * 2; s[k] = (raw[o] << 8) | raw[o + 1]; }
                    else if (depth == 8) s[k] = raw[y * stride + x * channels + k];
                    else { int bit = (x * channels + k) * depth; s[k] = (raw[y * stride + bit / 8] >> (8 - depth - bit % 8)) & max; }
                }
                int r, g, bl, al;
                Func<int, int> up = v => depth == 16 ? v : v * 65535 / max;
                switch (type) {
                    case 3:
                        r = plte[s[0] * 3] * 257; g = plte[s[0] * 3 + 1] * 257; bl = plte[s[0] * 3 + 2] * 257;
                        al = trns != null && s[0] < trns.Length ? trns[s[0]] * 257 : 65535; break;
                    case 0: case 4:
                        r = g = bl = up(s[0]);
                        al = type == 4 ? up(s[1]) : (trns != null && ((trns[0] << 8) | trns[1]) == s[0] ? 0 : 65535); break;
                    default:
                        r = up(s[0]); g = up(s[1]); bl = up(s[2]);
                        al = type == 6 ? up(s[3]) : (trns != null && ((trns[0] << 8) | trns[1]) == s[0] && ((trns[2] << 8) | trns[3]) == s[1] && ((trns[4] << 8) | trns[5]) == s[2] ? 0 : 65535); break;
                }
                int i = (y * width + x) * 4;
                px[i] = (ushort)r; px[i + 1] = (ushort)g; px[i + 2] = (ushort)bl; px[i + 3] = (ushort)al;
            }
        }
        return px;
    }

    // { differing pixels, largest channel difference in 16-bit units }.
    public static long[] Compare(ushort[] a, ushort[] b) {
        long differ = 0, delta = 0;
        for (int i = 0; i < a.Length; i += 4) {
            bool off = false;
            for (int k = 0; k < 4; k++) {
                int d = Math.Abs(a[i + k] - b[i + k]);
                if (d > 0) { off = true; if (d > delta) delta = d; }
            }
            if (off) differ++;
        }
        return new long[] { differ, delta };
    }

    // A crop of decoded pixels as an 8-bit RGB PNG (a screen grab is opaque): each row
    // with the filter that leaves the smallest sum, deflated as small as .NET can.
    public static byte[] EncodeRgb(ushort[] px, int width, int x0, int y0, int w, int h) {
        int stride = w * 3;
        var prev = new byte[stride];
        var cur = new byte[stride];
        var cand = new byte[5][];
        for (int f = 0; f < 5; f++) cand[f] = new byte[stride];
        var data = new MemoryStream();
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int i = ((y0 + y) * width + x0 + x) * 4;
                cur[x * 3] = (byte)(px[i] >> 8); cur[x * 3 + 1] = (byte)(px[i + 1] >> 8); cur[x * 3 + 2] = (byte)(px[i + 2] >> 8);
            }
            int best = 0; long bestSum = long.MaxValue;
            for (int f = 0; f < 5; f++) {
                long sum = 0;
                for (int k = 0; k < stride; k++) {
                    int a = k >= 3 ? cur[k - 3] : 0, b = prev[k], c = k >= 3 ? prev[k - 3] : 0, p;
                    switch (f) {
                        case 0: p = 0; break;
                        case 1: p = a; break;
                        case 2: p = b; break;
                        case 3: p = (a + b) >> 1; break;
                        default: { int q = a + b - c, pa = Math.Abs(q - a), pb = Math.Abs(q - b), pc = Math.Abs(q - c); p = (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c); break; }
                    }
                    byte v = (byte)(cur[k] - p);
                    cand[f][k] = v;
                    sum += v < 128 ? v : 256 - v;
                }
                if (sum < bestSum) { bestSum = sum; best = f; }
            }
            data.WriteByte((byte)best);
            data.Write(cand[best], 0, stride);
            var t = prev; prev = cur; cur = t;
        }
        var z = new MemoryStream();
        using (var zs = new ZLibStream(z, CompressionLevel.SmallestSize, true)) { data.Position = 0; data.CopyTo(zs); }
        var ihdr = new byte[13];
        WriteBE(ihdr, 0, (uint)w); WriteBE(ihdr, 4, (uint)h); ihdr[8] = 8; ihdr[9] = 2;
        var png = new MemoryStream();
        png.Write(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 }, 0, 8);
        Chunk(png, "IHDR", ihdr); Chunk(png, "IDAT", z.ToArray()); Chunk(png, "IEND", new byte[0]);
        return png.ToArray();
    }

    static void WriteBE(byte[] b, int at, uint v) { b[at] = (byte)(v >> 24); b[at + 1] = (byte)(v >> 16); b[at + 2] = (byte)(v >> 8); b[at + 3] = (byte)v; }

    static uint[] crcTable;
    static void Chunk(Stream s, string type, byte[] data) {
        if (crcTable == null) {
            crcTable = new uint[256];
            for (uint n = 0; n < 256; n++) { uint c = n; for (int k = 0; k < 8; k++) c = (c & 1) != 0 ? 0xEDB88320u ^ (c >> 1) : c >> 1; crcTable[n] = c; }
        }
        var head = new byte[8];
        WriteBE(head, 0, (uint)data.Length);
        var t = System.Text.Encoding.ASCII.GetBytes(type);
        Array.Copy(t, 0, head, 4, 4);
        uint crc = 0xFFFFFFFFu;
        for (int i = 4; i < 8; i++) crc = crcTable[(crc ^ head[i]) & 0xFF] ^ (crc >> 8);
        foreach (byte x in data) crc = crcTable[(crc ^ x) & 0xFF] ^ (crc >> 8);
        var tail = new byte[4];
        WriteBE(tail, 0, crc ^ 0xFFFFFFFFu);
        s.Write(head, 0, 8); s.Write(data, 0, data.Length); s.Write(tail, 0, 4);
    }
}
'@

function Import-PngPixels {
    if (-not ('InglenookPngPixels' -as [type])) { Add-Type -TypeDefinition $PngPixelsSource -Language CSharp }
}

function Compare-ShotPixels {
    <#
    .SYNOPSIS
        Compares two shots by their decoded pixels, exactly. Returns
        @{ Same; Differ; MaxDelta; Size }: how many pixels differ, the largest
        difference in one channel (of 255), and, when the sizes differ, both
        sizes ("1300x900 against 1280x900"; Same is then false).
    #>
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Other)
    Import-PngPixels
    $w1 = 0; $h1 = 0; $w2 = 0; $h2 = 0
    $a = [InglenookPngPixels]::Decode([System.IO.File]::ReadAllBytes($Path), [ref]$w1, [ref]$h1)
    $b = [InglenookPngPixels]::Decode([System.IO.File]::ReadAllBytes($Other), [ref]$w2, [ref]$h2)
    if ($w1 -ne $w2 -or $h1 -ne $h2) {
        return [pscustomobject]@{ Same = $false; Differ = [math]::Max($w1 * $h1, $w2 * $h2); MaxDelta = 255; Size = "${w1}x${h1} against ${w2}x${h2}" }
    }
    $r = [InglenookPngPixels]::Compare($a, $b)
    return [pscustomobject]@{ Same = ($r[0] -eq 0); Differ = [int]$r[0]; MaxDelta = [int][math]::Ceiling($r[1] / 257); Size = '' }
}

function Export-ShotCrop {
    <#
    .SYNOPSIS
        Writes an area of a screen grab (PNG) as its own PNG: 8-bit RGB, each row
        filtered and the whole deflated for size. Lossless: it decodes to the
        same pixels as the area. Crop is @{ X; Y; Width; Height }, inside the grab.
    #>
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)]$Crop, [Parameter(Mandatory)][string]$Out)
    Import-PngPixels
    $w = 0; $h = 0
    $px = [InglenookPngPixels]::Decode([System.IO.File]::ReadAllBytes($Path), [ref]$w, [ref]$h)
    if ($Crop.X -lt 0 -or $Crop.Y -lt 0 -or $Crop.Width -lt 1 -or $Crop.Height -lt 1 -or $Crop.X + $Crop.Width -gt $w -or $Crop.Y + $Crop.Height -gt $h) {
        throw "The crop $($Crop.Width)x$($Crop.Height)+$($Crop.X)+$($Crop.Y) is not inside the ${w}x${h} grab $Path."
    }
    [System.IO.File]::WriteAllBytes($Out, [InglenookPngPixels]::EncodeRgb($px, $w, $Crop.X, $Crop.Y, $Crop.Width, $Crop.Height))
}

Export-ModuleMember -Function Read-ShotStamp, Write-ShotStamp, Compare-ShotPixels, Export-ShotCrop
