#requires -Version 7.0
<#
.SYNOPSIS
    Finds, checks, and adds wallpapers: optional found images to go with the theme.

.DESCRIPTION
    Wallpapers come from Wikimedia Commons, where every file has a structured
    license and author. They are chosen by taste (ADR 0007). Two rules are
    gates:

        Format    a landscape JPEG at least 1920 px wide
        License   allows redistribution (CC0, public domain, CC BY, CC BY-SA)

    Lightness, saturation, and detail are grades. They rank search results
    and suggest a variant from lightness: day at L* 60 or above, night at 40
    or below, both in between. They never refuse an image.

    -Search lists Commons candidates and grades each from a small preview.
    -Check grades images from their full Commons originals (or local files)
    instead of a preview, and prints each one's credit: author, date,
    source, and license.
    -Add copies Commons files into wallpapers/, unmodified, writes the 640 px
    thumbnails, and prints the credit section for wallpapers/README.md, with
    the variant mark given. It refuses an image that fails a gate.

    -Check and -Add take several files at once: separate titles with | (which
    no Commons title contains), names and variants with commas. Their Commons
    details come in one request, and each original and its details are cached,
    so -Add after -Check downloads nothing again.

    Commons limits how fast one machine may ask. Requests are spaced out, even
    across parallel runs. If Commons still says it is busy (429 or 503), the
    script prints how long to wait and exits 3: wait that long, then run the
    same command again. Retrying sooner extends the block.
    -Web writes wallpapers/web/<name>.jpg, a 2400 px copy of a wallpaper for
    the preview site, so its page stays light.

    Images are read with SixLabors.ImageSharp (Apache 2.0 for open source
    projects), downloaded once from NuGet, checked against a pinned hash, and
    cached with every download and Commons detail in a temp folder outside
    the repo (inglenook-wallpapers).

.PARAMETER Search
    Words to look for on Commons, such as "cabin interior", "reading room", or
    "fireplace".

.PARAMETER Limit
    For -Search: how many candidates to show. Default 10.

.PARAMETER All
    For -Search: also show candidates that fail a gate, with the reason.

.PARAMETER Variant
    For -Search: keep images suggested for this variant (day, night, or
    both), exact suggestions first. For -Add: the variant mark, required:
    one for every file, or one per file, in the order of -Add.

.PARAMETER Check
    Local image paths, or Commons titles such as "File:Example.jpg".

.PARAMETER Add
    Commons titles such as "File:Example.jpg". Needs -Name.

.PARAMETER Name
    For -Add: one short name per file, such as "cabin-window-plants".
    Lowercase words joined by hyphens.

.EXAMPLE
    pwsh build/wallpaper.ps1 -Search "cabin interior window"

.EXAMPLE
    pwsh build/wallpaper.ps1 -Search "library fireplace" -Variant night

.EXAMPLE
    pwsh build/wallpaper.ps1 -Check wallpapers/cabin-window-plants.jpg

.EXAMPLE
    pwsh build/wallpaper.ps1 -Check "File:One.jpg|File:Two.jpg|File:Three.jpg"

.PARAMETER Web
    The short name of a wallpaper in wallpapers/, such as "cabin-seating".

.EXAMPLE
    pwsh build/wallpaper.ps1 -Add "File:Example.jpg" -Name cabin-window-plants -Variant day

.EXAMPLE
    pwsh build/wallpaper.ps1 -Add "File:One.jpg|File:Two.jpg" -Name reading-room,library-fire -Variant day,night

.EXAMPLE
    pwsh build/wallpaper.ps1 -Web cabin-seating
#>
[CmdletBinding(DefaultParameterSetName = 'Search')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Search', Position = 0)]
    [string]$Search,

    [Parameter(ParameterSetName = 'Search')]
    [ValidateRange(1, 50)]
    [int]$Limit = 10,

    [Parameter(ParameterSetName = 'Search')]
    [switch]$All,

    [Parameter(ParameterSetName = 'Search')]
    [Parameter(Mandatory, ParameterSetName = 'Add')]
    [string[]]$Variant,

    [Parameter(Mandatory, ParameterSetName = 'Check')]
    [string[]]$Check,

    [Parameter(Mandatory, ParameterSetName = 'Add')]
    [string[]]$Add,

    [Parameter(Mandatory, ParameterSetName = 'Add')]
    [string[]]$Name,

    [Parameter(Mandatory, ParameterSetName = 'Web')]
    [string]$Web
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'lib' 'Wallpaper.psm1') -Force

$RepoRoot      = Split-Path -Parent $PSScriptRoot
$WallpaperDir  = Join-Path $RepoRoot 'wallpapers'
$CacheDir      = Join-Path ([System.IO.Path]::GetTempPath()) 'inglenook-wallpapers'
$CommonsApi    = 'https://commons.wikimedia.org/w/api.php'
$UserAgent     = 'wallpaper-finder/1.0 (PowerShell)'

$ImageSharpVersion = '3.2.0'
$ImageSharpSha256  = '60d345f55451db74bbefb3231950c2524c12fe038173b08dabce4a844f22b179'

$Rules     = Get-WallpaperRules
$MinWidth  = $Rules.Format.MinWidth
$FitWidth  = 480
$CheckWidth = 1920   # a standard Commons thumbnail size; grades are taken from a 480 px copy anyway
$ThumbWidth = 640
$WebWidth = 2400     # the preview site's copy: sharp enough behind the page, a few hundred KB
$RateLimitExit = 3

function Split-List([string[]]$Values, [string]$Separator) {
    # From pwsh -File every list arrives as one string, so split it here.
    return @($Values | ForEach-Object { $_ -split $Separator } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
$Variants = @(Split-List $Variant ',')
foreach ($v in $Variants) { if ($v -notin 'day', 'night', 'both') { throw "-Variant '$v' is not day, night, or both." } }

# --- Downloads and ImageSharp -------------------------------------------------

function Get-CachePath([string]$Name) {
    if (-not (Test-Path $CacheDir)) { New-Item -ItemType Directory -Path $CacheDir | Out-Null }
    return Join-Path $CacheDir $Name
}

function Wait-RequestSlot {
    # Waits until the last request from any running copy of the finder is at
    # least the minimum gap old, then stamps now. The cache folder is shared,
    # so a lock file there keeps parallel searches from bursting.
    $gap = (Get-WallpaperRules).Polite.MinGapSeconds
    $lock = Get-CachePath 'request.lock'
    $stream = $null
    while (-not $stream) {
        try { $stream = [System.IO.File]::Open($lock, 'OpenOrCreate', 'ReadWrite', 'None') }
        catch [System.IO.IOException] { Start-Sleep -Milliseconds 200 }
    }
    try {
        $buf = [byte[]]::new(32)
        $n = $stream.Read($buf, 0, $buf.Length)
        $last = [long]0
        if ($n -and [long]::TryParse([Text.Encoding]::ASCII.GetString($buf, 0, $n), [ref]$last)) {
            $wait = $gap * 1000 - ([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() - $last)
            if ($wait -gt 0) { Start-Sleep -Milliseconds ([math]::Min($wait, $gap * 1000)) }
        }
        $stamp = [Text.Encoding]::ASCII.GetBytes([string][DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())
        $stream.SetLength(0); $stream.Write($stamp, 0, $stamp.Length)
    }
    finally { $stream.Dispose() }
}

function Invoke-Polite([scriptblock]$Request) {
    # Runs a web request in its turn. When the server says it is busy (429 or
    # 503), says how long it asks to wait and exits: no retry loop, which
    # would only extend the block. Finished downloads stay cached.
    Wait-RequestSlot
    try { return & $Request }
    catch {
        $resp = $_.Exception.PSObject.Properties['Response']?.Value
        if (-not $resp -or -not $resp.PSObject.Properties['StatusCode']) { throw }
        $status = [int]$resp.StatusCode
        $after = if ($resp.Headers.RetryAfter) { $resp.Headers.RetryAfter.ToString() } else { $null }
        $wait = Get-WallpaperRetryDelay -Status $status -Attempt 1 -RetryAfter $after
        if ($wait -lt 0) { throw }
        $words = if ($wait -ge 120) { "$([math]::Ceiling($wait / 60)) min" } else { "$wait s" }
        Write-Host "Commons is rate limiting this machine ($status). Wait $words, then run the same command again."
        Write-Host 'What is already downloaded is cached and is not fetched again. Retrying sooner extends the block.'
        exit $RateLimitExit
    }
}

function Save-Url([string]$Url, [string]$Path) {
    if (Test-Path $Path) { return $Path }
    $part = "$Path.part"
    try { Invoke-Polite { Invoke-WebRequest -Uri $Url -OutFile $part -UserAgent $UserAgent }; Move-Item $part $Path -Force }
    catch { Remove-Item $part -ErrorAction SilentlyContinue; throw "Could not download $Url : $($_.Exception.Message)" }
    return $Path
}

function Import-ImageSharp {
    if ('SixLabors.ImageSharp.Image' -as [type]) { return }
    $dll = Get-CachePath "SixLabors.ImageSharp.$ImageSharpVersion.dll"
    if (-not (Test-Path $dll)) {
        $id = 'sixlabors.imagesharp'
        $pkg = Save-Url "https://api.nuget.org/v3-flatcontainer/$id/$ImageSharpVersion/$id.$ImageSharpVersion.nupkg" (Get-CachePath "$id.$ImageSharpVersion.nupkg")
        $zip = [System.IO.Compression.ZipFile]::OpenRead($pkg)
        try {
            $entry = $zip.GetEntry('lib/net6.0/SixLabors.ImageSharp.dll')
            if (-not $entry) { throw "The ImageSharp package has no lib/net6.0/SixLabors.ImageSharp.dll." }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, "$dll.part", $true)
        }
        finally { $zip.Dispose() }
        $hash = (Get-FileHash "$dll.part" -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($hash -ne $ImageSharpSha256) {
            Remove-Item "$dll.part"
            throw "SixLabors.ImageSharp.dll has hash $hash, expected $ImageSharpSha256. Not loading it."
        }
        Move-Item "$dll.part" $dll -Force
    }
    Add-Type -Path $dll
}

function Read-Image([string]$Path) {
    Import-ImageSharp
    return [SixLabors.ImageSharp.Image]::Load[SixLabors.ImageSharp.PixelFormats.Rgb24]($Path)
}

function Copy-Image($Image, [int]$Width) {
    # A resized copy. Height keeps the aspect ratio.
    $ops = [Action[SixLabors.ImageSharp.Processing.IImageProcessingContext]] {
        param($c)
        [void][SixLabors.ImageSharp.Processing.ResizeExtensions]::Resize($c, $Width, 0)
    }.GetNewClosure()
    return [SixLabors.ImageSharp.Processing.ProcessingExtensions]::Clone($Image, $ops)
}

function Get-Pixels($Image) {
    # RGB bytes, row by row, via ImageSharp's binary PPM writer.
    $enc = [SixLabors.ImageSharp.Formats.Pbm.PbmEncoder]::new()
    $enc.ColorType = 'Rgb'; $enc.Encoding = 'Binary'; $enc.ComponentType = 'Byte'
    $ms = [System.IO.MemoryStream]::new()
    $Image.Save($ms, $enc)
    $all = $ms.ToArray()
    $lines = 0; $i = 0
    while ($lines -lt 3) { if ($all[$i] -eq 10) { $lines++ }; $i++ }   # P6, size, max value
    $out = [byte[]]::new($all.Length - $i)
    [Array]::Copy($all, $i, $out, 0, $out.Length)
    return , $out
}

# --- Measuring ----------------------------------------------------------------

function Measure-Image($Image) {
    # Grades from a small copy, so a preview grades like the full size.
    $copy = Copy-Image $Image ([math]::Min($FitWidth, $Image.Width))
    $fit = Measure-WallpaperFit -Pixels (Get-Pixels $copy) -Width $copy.Width -Height $copy.Height
    $copy.Dispose()
    return $fit
}

function Format-Fit($Fit) {
    # One line: the measures, their grades, and the suggested variant.
    return 'lightness {0} (suggests {1}), saturation {2} ({3}), detail {4} ({5})' -f `
        $Fit.Lightness, $Fit.Variant, $Fit.Saturation, $Fit.Grades.Saturation, $Fit.Detail, $Fit.Grades.Detail
}

function Write-Report($Fit, $Problems, [string]$Gates = 'the format and license gates') {
    Write-Host 'Grades'
    Write-Host ('  {0,-11} {1,6}   mean L*, 0 to 100: suggests {2}' -f 'lightness', $Fit.Lightness, $Fit.Variant)
    foreach ($k in $Rules.Grades.Keys) {
        $g = $Rules.Grades[$k]
        Write-Host ('  {0,-11} {1,6}   {2}: {3} (over {4} is {5})' -f $g.Label, $Fit[$k], $g.Unit, $Fit.Grades[$k], $g.Max, $g.Bad)
    }
    Write-Host ''
    if ($Problems.Count) {
        Write-Host 'Fails:'
        foreach ($p in $Problems) { Write-Host "  - $p" }
    }
    else { Write-Host "Passes $Gates." }
}

# --- Commons ------------------------------------------------------------------

function Invoke-Commons([hashtable]$Query) {
    $Query['action'] = 'query'; $Query['format'] = 'json'; $Query['formatversion'] = '2'
    $pairs = foreach ($k in $Query.Keys) { "$k=$([uri]::EscapeDataString([string]$Query[$k]))" }
    $uri = "$CommonsApi`?$($pairs -join '&')"
    return Invoke-Polite { Invoke-RestMethod -Uri $uri -UserAgent $UserAgent }
}

$InfoProps = @{
    prop = 'imageinfo'; iiprop = 'url|size|mime|extmetadata'; iiurlwidth = $FitWidth
    iiextmetadatafilter = 'LicenseShortName|LicenseUrl|Artist|DateTimeOriginal|ImageDescription'
}

function Remove-Html([string]$Text) {
    $t = [regex]::Replace($Text, '<[^>]+>', '')
    return ([System.Net.WebUtility]::HtmlDecode($t) -replace '\s+', ' ').Trim()
}

function Get-ArtistName([string]$Html) {
    # Commons often follows the name with notes. The first link is the name.
    $m = [regex]::Match($Html, '<a\b[^>]*>(.*?)</a>', 'Singleline')
    if ($m.Success) { return Remove-Html $m.Groups[1].Value }
    return Remove-Html $Html
}

function Get-ArtistLink([string]$Html) {
    $m = [regex]::Match($Html, 'href="([^"]+)"')
    if (-not $m.Success) { return $null }
    $u = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
    if ($u.StartsWith('//')) { $u = "https:$u" }
    return $u
}

function ConvertTo-Candidate($Page) {
    $ii = $Page.imageinfo[0]
    $meta = $ii.extmetadata
    $field = { param($k) if ($meta.PSObject.Properties[$k]) { [string]$meta.$k.value } else { '' } }
    $clean = { param($u) ($u -replace '\?utm_[^#]*$', '') }
    return [pscustomobject]@{
        Title       = $Page.title
        Width       = [int]$ii.width
        Height      = [int]$ii.height
        Mime        = $ii.mime
        Url         = & $clean $ii.url
        ThumbUrl    = & $clean $ii.thumburl
        Page        = $ii.descriptionurl
        License     = Remove-Html (& $field 'LicenseShortName')
        LicenseUrl  = & $field 'LicenseUrl'
        Author      = Get-ArtistName (& $field 'Artist')
        AuthorUrl   = Get-ArtistLink (& $field 'Artist')
        Date        = (Remove-Html (& $field 'DateTimeOriginal')) -replace '^(\d{4}-\d{2}-\d{2}).*$', '$1'
        Description = Remove-Html (& $field 'ImageDescription')
    }
}

function Get-RuleProblems($Candidate) {
    # The gates: license and format (JPEG, size, shape). A local file is
    # @{ Width; Height } only: no license or type to check.
    $p = [System.Collections.Generic.List[string]]::new()
    if (-not $Candidate.PSObject.Properties['License']) {
        foreach ($f in Test-WallpaperFormat -Width $Candidate.Width -Height $Candidate.Height) { $p.Add($f) }
        return , $p
    }
    if (-not (Test-WallpaperLicense $Candidate.License)) { $p.Add("license '$($Candidate.License)' does not clearly allow redistribution.") }
    if ($Candidate.Mime -ne 'image/jpeg') { $p.Add("$($Candidate.Mime), not a JPEG.") }
    foreach ($f in Test-WallpaperFormat -Width $Candidate.Width -Height $Candidate.Height) { $p.Add($f) }
    return , $p
}

function Get-SafeFileName([string]$Title) { return ($Title -replace '[^A-Za-z0-9._-]', '_') }

function Get-Candidates([string[]]$Titles) {
    # Each title's candidate, or the reason there is none, as a hashtable by
    # title. Details are cached; the rest come in one request per 50 titles.
    $out = @{}
    $ask = [System.Collections.Generic.List[string]]::new()
    foreach ($t in $Titles) {
        $title = if ($t -match '^File:') { $t } else { "File:$t" }
        $meta = Get-CachePath ('meta-' + (Get-SafeFileName $title) + '.json')
        if (Test-Path $meta) { $out[$t] = Get-Content -Raw $meta | ConvertFrom-Json }
        else { $ask.Add($t) }
    }
    for ($i = 0; $i -lt $ask.Count; $i += 50) {
        $chunk = @($ask[$i..([math]::Min($i + 49, $ask.Count - 1))])
        $full = @($chunk | ForEach-Object { if ($_ -match '^File:') { $_ } else { "File:$_" } })
        $res = Invoke-Commons (@{ titles = ($full -join '|') } + $InfoProps)
        $renamed = @{}
        if ($res.query.PSObject.Properties['normalized']) { foreach ($n in $res.query.normalized) { $renamed[$n.from] = $n.to } }
        for ($j = 0; $j -lt $chunk.Count; $j++) {
            $title = if ($renamed.ContainsKey($full[$j])) { $renamed[$full[$j]] } else { $full[$j] }
            $page = @($res.query.pages | Where-Object { $_.title -eq $title })[0]
            if (-not $page -or $page.PSObject.Properties['missing'] -or -not $page.PSObject.Properties['imageinfo']) { $out[$chunk[$j]] = "Commons has no file '$($full[$j])'."; continue }
            $c = ConvertTo-Candidate $page
            $json = ConvertTo-Json -InputObject $c
            Set-Content -Path (Get-CachePath ('meta-' + (Get-SafeFileName $full[$j]) + '.json')) -Value $json
            $out[$chunk[$j]] = $c
        }
    }
    return $out
}

function Save-Original($Candidate) {
    # The original, byte for byte, downloaded once and cached for -Check and -Add.
    return Save-Url $Candidate.Url (Get-CachePath ('full-' + (Get-SafeFileName $Candidate.Title)))
}

function Write-Credit($Candidate) {
    Write-Host 'Credit'
    $credit = Get-WallpaperCredit -Candidate $Candidate
    foreach ($k in $credit.Keys) { Write-Host ('  {0,-11} {1}' -f $k, $credit[$k]) }
}

# --- Search -------------------------------------------------------------------

if ($PSCmdlet.ParameterSetName -eq 'Search') {
    if ($Variants.Count -gt 1) { throw '-Search takes one -Variant.' }
    $Variant = if ($Variants.Count) { $Variants[0] } else { $null }
    $q = @{
        generator = 'search'; gsrnamespace = '6'; gsrlimit = '50'
        gsrsearch = "$Search filetype:bitmap filemime:image/jpeg filew:>$($MinWidth - 1)"
    } + $InfoProps
    $res = Invoke-Commons $q
    $pages = if ($res.PSObject.Properties['query']) { @($res.query.pages | Sort-Object index) } else { @() }
    if (-not $pages) { Write-Host 'Nothing found. Try broader words: cabin, window, plants, library, fireplace, reading room.'; return }

    Write-Host "Grading up to $($pages.Count) Commons results for '$Search' from previews..."
    $graded = foreach ($pg in $pages) {
        $c = ConvertTo-Candidate $pg
        $problems = Get-RuleProblems $c
        $fit = $null
        if ($problems.Count -eq 0 -or $All) {
            try {
                $img = Read-Image (Save-Url $c.ThumbUrl (Get-CachePath ('thumb-' + (Get-SafeFileName $c.Title))))
                $fit = Measure-Image $img
                $img.Dispose()
            }
            catch { $problems.Add("could not measure: $($_.Exception.Message)") }
        }
        [pscustomobject]@{ Candidate = $c; Fit = $fit; Problems = $problems }
    }
    $measured = @($graded | Where-Object { $_.Problems.Count -eq 0 })
    $want = if ($Variant) { @{ Variant = $Variant } } else { @{} }
    $pass = @(Select-WallpaperCandidate -Candidate $measured @want)
    $other = $measured.Count - $pass.Count
    $fail = @($graded | Where-Object { $_.Problems.Count -gt 0 })

    $show = { param($g)
        $c = $g.Candidate
        Write-Host "  $($c.Title)"
        $by = if (-not $c.Author) { 'unknown' } elseif ($c.Author.Length -gt 50) { $c.Author.Substring(0, 47) + '...' } else { $c.Author }
        Write-Host "    $($c.Width) x $($c.Height), $($c.License), by $by"
        if ($g.Fit) { Write-Host "    $(Format-Fit $g.Fit)" }
        Write-Host "    $($c.Page)"
        foreach ($p in $g.Problems) { Write-Host "    - $p" }
    }

    Write-Host ''
    $for = if ($Variant) { " for $Variant" } else { '' }
    Write-Host "Pass the gates$for ($($pass.Count)), calmest first:"
    if ($pass) { foreach ($g in $pass | Select-Object -First $Limit) { & $show $g } }
    else { Write-Host '  none. Try other words, or -All to see why each failed.' }
    if ($other) { Write-Host ''; Write-Host "$other more pass the gates but suggest another variant." }
    if ($All -and $fail) {
        Write-Host ''
        Write-Host "Fail ($($fail.Count)):"
        foreach ($g in $fail | Select-Object -First $Limit) { & $show $g }
    }
    elseif ($fail) { Write-Host ''; Write-Host "$($fail.Count) failed a gate. Add -All to see why." }
    Write-Host ''
    Write-Host 'Previews only. Look at a candidate, then run -Check "<title>" on the full image.'
    return
}

# --- Check ----------------------------------------------------------------------

if ($PSCmdlet.ParameterSetName -eq 'Check') {
    $items = @(Split-List $Check '\|')
    $titles = @($items | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
    $found = if ($titles) { Get-Candidates $titles } else { @{} }
    $failed = 0
    foreach ($item in $items) {
        if ($items.Count -gt 1) { Write-Host ''; Write-Host "--- $item" }
        $candidate = $null
        if (Test-Path -LiteralPath $item -PathType Leaf) { $path = (Resolve-Path -LiteralPath $item).Path }
        else {
            $candidate = $found[$item]
            if ($candidate -is [string]) { Write-Host $candidate; $failed++; continue }
            # The original, which -Add copies: one download, cached, serves both.
            $path = Save-Original $candidate
        }
        $img = Read-Image $path
        $size = if ($candidate) { "$($candidate.Width) x $($candidate.Height)" } else { "$($img.Width) x $($img.Height)" }
        Write-Host "$item ($size)"
        if ($candidate) { Write-Host "$($candidate.License), by $($candidate.Author). $($candidate.Page)" }
        Write-Host ''
        # Get-RuleProblems returns its list whole; looping over the call would add
        # that list as one blank problem.
        # Both kinds go through it, so the local-file smoke test in test.ps1
        # covers the same path as a Commons title.
        $gated = if ($candidate) { $candidate } else { [pscustomobject]@{ Width = $img.Width; Height = $img.Height } }
        $problems = Get-RuleProblems $gated
        $fit = Measure-Image $img
        $img.Dispose()
        $gates = if ($candidate) { 'the format and license gates' } else { 'the format gate (license is checked for Commons titles)' }
        Write-Report $fit $problems $gates
        if ($candidate) { Write-Host ''; Write-Credit $candidate }
        if ($problems.Count) { $failed++ }
    }
    if ($items.Count -gt 1) { Write-Host ''; Write-Host "$($items.Count - $failed) of $($items.Count) pass." }
    if ($failed) { exit 1 }
    return
}

# --- Web ------------------------------------------------------------------------

if ($PSCmdlet.ParameterSetName -eq 'Web') {
    $source = Join-Path $WallpaperDir "$Web.jpg"
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "wallpapers/$Web.jpg does not exist." }
    $out = Join-Path $WallpaperDir 'web' "$Web.jpg"
    New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null
    $img = Read-Image $source
    try {
        $small = Copy-Image $img $WebWidth
        $enc = [SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder]::new()
        $enc.Quality = 80
        [SixLabors.ImageSharp.ImageExtensions]::Save($small, $out, $enc)
        $small.Dispose()
    }
    finally { $img.Dispose() }
    Write-Host "Wrote wallpapers/web/$Web.jpg ($([math]::Round((Get-Item $out).Length / 1KB)) KB)."
    return
}

# --- Add ------------------------------------------------------------------------

$adds = @(Split-List $Add '\|')
$names = @(Split-List $Name '[,|]')
if ($names.Count -ne $adds.Count) { throw "-Add has $($adds.Count) file(s) and -Name $($names.Count) name(s). Give one name per file." }
if ($Variants.Count -notin 1, $adds.Count) { throw "-Variant needs one mark for every file, or one per file ($($adds.Count))." }
foreach ($n in $names) {
    if ($n -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { throw "-Name '$n' must be lowercase words joined by hyphens, such as 'cabin-window-plants'." }
    if ((Test-Path (Join-Path $WallpaperDir "$n.jpg")) -or (Test-Path (Join-Path $WallpaperDir 'thumbs' "$n.jpg"))) { throw "wallpapers/$n.jpg or its thumbnail already exists." }
}
if (@($names | Sort-Object -Unique).Count -ne $names.Count) { throw '-Name has the same name twice.' }

$found = Get-Candidates $adds
$failed = 0
$sections = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $adds.Count; $i++) {
    $c = $found[$adds[$i]]
    $short = $names[$i]
    $mark = if ($Variants.Count -eq 1) { $Variants[0] } else { $Variants[$i] }
    if ($adds.Count -gt 1) { Write-Host ''; Write-Host "--- $($adds[$i]) as $short ($mark)" }
    if ($c -is [string]) { Write-Host "Not adding: $c"; $failed++; continue }
    $problems = Get-RuleProblems $c
    if ($problems.Count) { Write-Host "Not adding $($c.Title): $($problems -join ' ')"; $failed++; continue }

    $target = Join-Path $WallpaperDir "$short.jpg"
    $thumb  = Join-Path $WallpaperDir 'thumbs' "$short.jpg"
    $cached = Save-Original $c
    $img = Read-Image $cached
    $fit = Measure-Image $img
    Write-Report $fit @()
    Write-Host ''
    $agree = if ($fit.Variant -eq $mark) { 'agrees' } else { 'differs, your call stands' }
    Write-Host "Marked $mark; lightness suggests $($fit.Variant) ($agree)."

    # The original goes in byte for byte. Only the thumbnail is re-encoded.
    # Both files or neither.
    try {
        New-Item -ItemType Directory -Path (Split-Path $thumb) -Force | Out-Null
        $small = Copy-Image $img $ThumbWidth
        $enc = [SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder]::new()
        $enc.Quality = 85
        [SixLabors.ImageSharp.ImageExtensions]::Save($small, $thumb, $enc)
        $small.Dispose()
        Copy-Item -LiteralPath $cached -Destination $target
    }
    catch {
        Remove-Item -LiteralPath $thumb, $target -ErrorAction SilentlyContinue
        throw
    }
    finally { $img.Dispose() }
    Write-Host "Wrote wallpapers/$short.jpg and wallpapers/thumbs/$short.jpg."
    $sections.Add((New-WallpaperSection -Candidate $c -Name $short -Variant $mark))
}

if ($sections.Count) {
    Write-Host ''
    Write-Host 'Add each section to wallpapers/README.md, after the last section. For a pair, make'
    Write-Host 'it a ### subsection of the pair section instead. Rewrite the Subject in one plain'
    Write-Host 'line, and check the author and license against the Commons page:'
    foreach ($s in $sections) { Write-Host ''; Write-Host $s }
}
if ($failed) { exit 1 }
