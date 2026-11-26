# The port catalog: which folders under Ports/ are ports, what their port.json
# and Ports/ports.json say, their card icons (ADR 0008), a site.json for the
# port the Pages site publishes, a port's screenshot recipe (screenshot.json),
# and the preview's shot list (shots.json).
# Loaded and validated once here; check.ps1 reports the errors, site.ps1 publishes the records, icon.ps1 shares the icon rules.

Set-StrictMode -Version Latest

$Tiers = [ordered]@{ '1' = 'Full'; '2' = 'Partial'; '3' = 'Minimal' }
$Platforms = [ordered]@{ windows = 'Windows'; macos = 'macOS'; linux = 'Linux'; web = 'Web' }

# Icons: single-color shapes that take their color from the page.
$IconShapes = @('path', 'circle', 'ellipse', 'line', 'polyline', 'polygon', 'rect', 'g')
$IconShapeAttrs = @('d', 'cx', 'cy', 'r', 'rx', 'ry', 'x', 'y', 'x1', 'y1', 'x2', 'y2', 'points', 'width', 'height',
    'transform', 'fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin', 'fill-rule', 'clip-rule')
$IconPaintAttrs = @('fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin', 'fill-rule', 'clip-rule')
$IconMaxBytes = 8KB

function Get-IconRules {
    # What an icon.svg may contain. RootAttrs excludes xmlns and viewBox,
    # which every icon has.
    return @{ Shapes = $IconShapes; ShapeAttrs = $IconShapeAttrs; RootAttrs = $IconPaintAttrs }
}

function Read-JsonFile {
    <#
    .SYNOPSIS
        A JSON file as hashtables, the one JSON reader of the build scripts.
        If it is missing or not valid JSON: with -Errors, adds "<Where> is not
        valid JSON: ..." and returns $null; with -Quiet, returns $null; else throws.
    #>
    param([Parameter(Mandatory)][string]$Path, [string]$Where = $Path, $Errors, [switch]$Quiet)
    try { return Get-Content -Raw -LiteralPath $Path -ErrorAction Stop | ConvertFrom-Json -AsHashtable }
    catch {
        if ($null -ne $Errors) { $Errors.Add("$Where is not valid JSON: $($_.Exception.Message)"); return $null }
        if ($Quiet) { return $null }
        throw
    }
}

function Test-PortMeta($Meta, [string]$Where, [bool]$Planned, $Categories, $Errors) {
    if ($Meta -isnot [System.Collections.IDictionary]) { $Errors.Add("$Where must be a JSON object."); return }
    $known = @('name', 'category', 'tier', 'platforms', 'monogram') + $(if ($Planned) { 'folder' } else { 'icon' })
    foreach ($k in $Meta.Keys) { if ($k -notin $known) { $Errors.Add("$Where has an unknown field '$k'.") } }
    if (-not ($Meta['name'] -is [string] -and $Meta['name'].Trim())) { $Errors.Add("$Where needs a 'name'.") }
    if (-not ($Meta['category'] -is [string] -and $Categories.Contains($Meta['category']))) {
        $Errors.Add("$Where has category '$($Meta['category'])'. Use one of: $(@($Categories.Keys) -join ', ') (from Ports/ports.json).")
    }
    $tier = $Meta['tier']
    $tierOk = ($tier -is [long] -or $tier -is [int]) -and $Tiers.Contains([string]$tier)
    if (-not $tierOk -and -not ($Planned -and $null -eq $tier -and $Meta.Contains('tier'))) {
        $allowed = ($Tiers.Keys -join ', ') + $(if ($Planned) { ', or null' } else { '' })
        $Errors.Add("$Where needs 'tier': $allowed.")
    }
    $plat = $Meta['platforms']
    if (-not ($plat -is [System.Collections.IList] -and $plat.Count -gt 0)) {
        $Errors.Add("$Where needs 'platforms', a list of: $($Platforms.Keys -join ', ').")
    }
    else {
        foreach ($p in $plat) { if (-not $Platforms.Contains([string]$p)) { $Errors.Add("$Where has platform '$p'. Use: $($Platforms.Keys -join ', ').") } }
    }
    if ($Meta.Contains('monogram') -and -not ($Meta['monogram'] -is [string] -and $Meta['monogram'] -match '^\S{1,3}$')) {
        $Errors.Add("$Where has a 'monogram' that is not 1 to 3 characters.")
    }
}

function Test-PortIcon([string]$Dir, $Meta, [string]$Name, $Errors) {
    # Returns $true when the port has a valid icon.svg and credit.
    $svgPath = Join-Path $Dir 'icon.svg'
    $hasSvg = Test-Path $svgPath
    $hasCredit = $Meta -is [System.Collections.IDictionary] -and $Meta.Contains('icon')
    if (-not $hasSvg -and -not $hasCredit) { return $false }
    if (-not $hasCredit) { $Errors.Add("Icon: Ports/$Name/icon.svg has no 'icon' credit in port.json. build/icon.ps1 prints it."); return $false }
    if (-not $hasSvg) { $Errors.Add("Icon: Ports/$Name/port.json has an 'icon' credit but there is no icon.svg."); return $false }
    $before = $Errors.Count

    $c = $Meta['icon']
    $where = "Ports/$Name/port.json icon"
    if ($c -isnot [System.Collections.IDictionary]) { $Errors.Add("Icon: $where must be an object."); return $false }
    foreach ($k in $c.Keys) { if ($k -notin 'kind', 'set', 'name', 'author', 'source', 'license', 'mark') { $Errors.Add("Icon: $where has an unknown field '$k'.") } }
    foreach ($k in 'set', 'name', 'author', 'license') {
        if (-not ($c[$k] -is [string] -and $c[$k].Trim())) { $Errors.Add("Icon: $where needs '$k'.") }
    }
    if (-not ($c['source'] -is [string] -and $c['source'] -match '^https://\S+$')) { $Errors.Add("Icon: $where needs 'source', an https URL.") }
    if ($c['kind'] -eq 'brand') {
        if (-not ($c['mark'] -is [string] -and $c['mark'] -match '^https://\S+$')) {
            $Errors.Add("Icon: $where is a brand mark, so it needs 'mark': an https URL showing the app allows its mark to be used.")
        }
    }
    elseif ($c['kind'] -eq 'glyph') { if ($c.Contains('mark')) { $Errors.Add("Icon: $where is a glyph, so it takes no 'mark'.") } }
    else { $Errors.Add("Icon: $where needs 'kind': brand or glyph.") }

    $rel = "Ports/$Name/icon.svg"
    if ((Get-Item $svgPath).Length -gt $IconMaxBytes) { $Errors.Add("Icon: $rel is over $($IconMaxBytes / 1KB) KB. Icons are simple shapes."); return $false }
    $xml = [System.Xml.XmlDocument]::new()
    $xml.XmlResolver = $null
    try { $xml.LoadXml([System.IO.File]::ReadAllText($svgPath)) }
    catch { $Errors.Add("Icon: $rel is not valid XML: $($_.Exception.Message)"); return $false }
    if ($xml.DocumentType) { $Errors.Add("Icon: $rel has a DOCTYPE. Remove it.") }
    $root = $xml.DocumentElement
    if ($root.LocalName -ne 'svg' -or $root.NamespaceURI -ne 'http://www.w3.org/2000/svg') { $Errors.Add("Icon: $rel is not an SVG."); return $false }
    if ($root.GetAttribute('viewBox') -ne '0 0 24 24') { $Errors.Add("Icon: $rel needs viewBox=`"0 0 24 24`", so every card icon is the same size.") }
    $check = {
        param([System.Xml.XmlElement]$El, [string[]]$Allowed)
        foreach ($a in $El.Attributes) {
            if ($a.Prefix -eq 'xmlns' -or ($a.LocalName -notin $Allowed)) {
                $Errors.Add("Icon: $rel has the attribute '$($a.Name)' on <$($El.LocalName)>, which icons may not use.")
                continue
            }
            if ($a.LocalName -in 'fill', 'stroke' -and $a.Value -notin 'currentColor', 'none') {
                $Errors.Add("Icon: $rel has $($a.LocalName)=`"$($a.Value)`". Icons use currentColor or none only, so the page colors them.")
            }
        }
    }
    & $check $root (@('xmlns', 'viewBox') + $IconPaintAttrs)
    foreach ($node in $root.SelectNodes('.//node()')) {
        if ($node.NodeType -in 'Comment', 'Whitespace', 'SignificantWhitespace') { continue }
        if ($node.NodeType -ne 'Element') { $Errors.Add("Icon: $rel has $($node.NodeType) content. Icons are shapes only."); continue }
        if ($node.LocalName -notin $IconShapes -or $node.NamespaceURI -ne 'http://www.w3.org/2000/svg') {
            $Errors.Add("Icon: $rel has <$($node.LocalName)>. Icons may use only: $($IconShapes -join ', ').")
            continue
        }
        & $check $node $IconShapeAttrs
    }
    return $Errors.Count -eq $before
}

function Read-SiteSpec([string]$Dir, [string]$Name, $Errors) {
    # site.json: what the Pages site publishes from this port.
    #   copy:    folders of the port to publish, at their repo paths
    #   entries: site paths that open a page of dist/<variant>/ in the
    #            visitor's variant: [{ "path": "ports/index.html", "page": "ports.html", "title": "Ports" }]
    #   guide:   optional page of template/, in a folder of its own, that site.ps1 fills
    #            with each listed port's README.md: "guides/guide.html"
    $path = Join-Path $Dir 'site.json'
    if (-not (Test-Path $path)) { return $null }
    $where = "Ports/$Name/site.json"
    $spec = Read-JsonFile $path -Where $where -Errors $Errors
    if ($spec -isnot [System.Collections.IDictionary]) { if ($spec) { $Errors.Add("$where must be an object.") }; return $null }
    $before = $Errors.Count
    if (-not ($spec['copy'] -is [System.Collections.IList] -and $spec['copy'].Count -gt 0)) { $Errors.Add("$where needs 'copy', a list of the port's folders to publish.") }
    else {
        foreach ($c in $spec['copy']) { if (-not ($c -is [string] -and $c -notmatch '[\\/]|^\.' -and (Test-Path (Join-Path $Dir $c) -PathType Container))) { $Errors.Add("$where copies '$c', which is not a folder in Ports/$Name.") } }
    }
    if (-not ($spec['entries'] -is [System.Collections.IList] -and $spec['entries'].Count -gt 0)) { $Errors.Add("$where needs 'entries', a list of { path, page, title }.") }
    else {
        foreach ($e in $spec['entries']) {
            if (-not ($e -is [System.Collections.IDictionary] -and $e['path'] -is [string] -and $e['path'] -match '^([a-z0-9-]+/)*index\.html$' -and $e['page'] -is [string] -and $e['title'] -is [string])) {
                $Errors.Add("$where has an entry that is not { path: '<folder>/index.html', page, title }.")
                continue
            }
            if (-not (Test-Path (Join-Path $Dir 'template' $e['page']))) { $Errors.Add("$where entry '$($e['path'])' opens '$($e['page'])', which is not in template/.") }
        }
    }
    if ($spec.Contains('guide')) {
        $g = $spec['guide']
        if (-not ($g -is [string] -and $g -match '^[a-z0-9-]+/[a-z0-9-]+\.html$')) { $Errors.Add("$where has a 'guide' that is not '<folder>/<page>.html'.") }
        elseif (-not (Test-Path (Join-Path $Dir 'template' $g))) { $Errors.Add("$where has guide '$g', which is not in template/.") }
    }
    if ($Errors.Count -ne $before) { return $null }
    return $spec
}

# Recipes (screenshot.json): what the Photographer needs per port, and nothing it fixes itself.
$SceneKinds = @('terminal', 'prompt', 'cli', 'editor', 'icon-theme', 'document', 'desktop', 'web')
$RecipePlatforms = @('linux', 'windows', 'macos')
$RecipeSteps = @('install', 'apply', 'stage', 'launch')

function Test-RecipeShape($Recipe, [string]$Where, $Errors) {
    # The checks that need only this file. Returns $true when they all pass.
    if ($Recipe -isnot [System.Collections.IDictionary]) { $Errors.Add("$Where must be a JSON object."); return $false }
    $before = $Errors.Count
    $manual = $Recipe.Contains('manual')
    $guest = $Recipe.Contains('host')
    $known = if ($manual) { @('kind', 'platform', 'manual') } else { @('kind', 'platform', 'host', 'version', 'window') + $RecipeSteps }
    foreach ($k in $Recipe.Keys) {
        if ($k -in $known) { continue }
        if ($manual) { $Errors.Add("$Where is a manual recipe, so it takes no '$k'.") }
        else { $Errors.Add("$Where has an unknown field '$k'. A recipe holds only: $($known -join ', '). Timeouts, sizes, margins and the backdrop belong to the Photographer.") }
    }
    if ($Recipe['kind'] -notin $SceneKinds) { $Errors.Add("$Where has kind '$($Recipe['kind'])'. Use one of: $($SceneKinds -join ', ').") }
    if ($Recipe['platform'] -notin $RecipePlatforms) { $Errors.Add("$Where has platform '$($Recipe['platform'])'. Use one of: $($RecipePlatforms -join ', ').") }
    if ($manual) {
        if (-not ($Recipe['manual'] -is [string] -and $Recipe['manual'].Trim())) { $Errors.Add("$Where needs 'manual': why the app cannot be shot automatically.") }
        return $Errors.Count -eq $before
    }
    if ($Recipe.Contains('version') -and -not ($Recipe['version'] -is [string] -and $Recipe['version'].Trim())) { $Errors.Add("$Where has a 'version' that is not text.") }
    if ($guest) {
        if (-not ($Recipe['host'] -is [string] -and $Recipe['host'].Trim())) { $Errors.Add("$Where needs 'host', another port's folder name.") }
        foreach ($k in 'launch', 'window') { if ($Recipe.Contains($k)) { $Errors.Add("$Where has a host, so it takes no '$k'. The host launches and finds the window.") } }
    }
    $required = if ($guest) { @('install', 'apply') } else { $RecipeSteps }
    foreach ($k in $RecipeSteps) {
        if (-not $Recipe.Contains($k)) {
            if ($k -in $required) { $Errors.Add("$Where needs '$k', a list of shell lines (it can be empty).") }
            continue
        }
        $lines = $Recipe[$k]
        $ok = $lines -is [System.Collections.IList] -and @($lines | Where-Object { -not ($_ -is [string] -and $_.Trim()) }).Count -eq 0
        if (-not $ok) { $Errors.Add("$Where needs '$k' as a list of shell lines, none of them empty.") }
    }
    if ($guest) { return $Errors.Count -eq $before }
    if ($Recipe['kind'] -eq 'desktop') {
        if ($Recipe.Contains('window')) { $Errors.Add("$Where is a desktop recipe, so it takes no 'window'. The Photographer crops a fixed area of the screen.") }
    }
    elseif (-not $Recipe.Contains('window')) { $Errors.Add("$Where needs 'window': { `"class`": ... } or { `"title`": `"<regex>`" }.") }
    else {
        $w = $Recipe['window']
        $ok = $w -is [System.Collections.IDictionary] -and $w.Count -eq 1 -and @($w.Keys)[0] -in 'class', 'title' -and $w[@($w.Keys)[0]] -is [string] -and $w[@($w.Keys)[0]].Trim()
        if (-not $ok) { $Errors.Add("$Where needs 'window' with one of 'class' or 'title', as text.") }
        elseif ($w.Contains('title')) {
            try { $null = [regex]::new($w['title']) } catch { $Errors.Add("$Where has a window 'title' that is not a valid regex.") }
        }
    }
    return $Errors.Count -eq $before
}

function Read-Recipe([string]$Dir, [string]$Name, $Errors) {
    # screenshot.json: how the Photographer shoots this port. Every port has one, or a
    # shot list (shots.json) instead, as the preview does.
    # Returns the recipe if its own shape is valid; hosts are checked across the catalog.
    $path = Join-Path $Dir 'screenshot.json'
    if (-not (Test-Path $path)) {
        if (-not (Test-Path (Join-Path $Dir 'shots.json'))) {
            $Errors.Add("Ports/$Name has no screenshot.json. Write the port's recipe (CONTRIBUTING.md, Add a port, step 7).")
        }
        return $null
    }
    $where = "Ports/$Name/screenshot.json"
    $recipe = Read-JsonFile $path -Where $where -Errors $Errors
    if ($null -eq $recipe) { return $null }
    if (Test-RecipeShape $recipe $where $Errors) { return $recipe }
    return $null
}

function Test-RecipeHosts($Ports, $Errors) {
    # A guest's host must be a port with a recipe, on the same platform, and not a guest itself.
    # Drops the recipe of a guest that fails.
    $byName = @{}
    foreach ($p in $Ports) { $byName[$p.Name] = $p }
    foreach ($p in $Ports) {
        $r = $p.Recipe
        if ($null -eq $r -or -not $r.Contains('host')) { continue }
        $where = "Ports/$($p.Name)/screenshot.json"
        $h = $r['host']
        $hp = $byName[$h]
        $hr = if ($hp) { $hp.Recipe } else { $null }
        $msg = if ($null -eq $hr) { "$where has host '$h', which has no screenshot.json (or an invalid one)." }
        elseif ($hr.Contains('manual')) { "$where has host '$h', which has a manual recipe." }
        elseif ($hr.Contains('host')) { "$where has host '$h', which is itself a guest." }
        elseif ($hr['platform'] -ne $r['platform']) { "$where has host '$h', which is shot on $($hr['platform']), not $($r['platform'])." }
        elseif ($hr['kind'] -eq 'desktop') { "$where has host '$h', a desktop, which has no window to show a guest in." }
        else { $null }
        if ($msg) { $Errors.Add($msg); $p.Recipe = $null }
    }
}

# Shot lists (shots.json): the preview's shots of its own bare page, taken by the
# Photographer with no scene. Not a recipe: a list of { name, variant, show }.
function Read-ShotList([string]$Dir, [string]$Name, $Errors) {
    # Returns the list of shots if it is valid, or $null.
    #   name:    the image, screenshots/<name>.png (lowercase, hyphenated, unique)
    #   variant: day or night
    #   show:    "top" (the top of the page), or the accessible name of a page section
    # Both variants are shot, or neither: the list needs at least one of each.
    $path = Join-Path $Dir 'shots.json'
    if (-not (Test-Path $path)) { return $null }
    $where = "Ports/$Name/shots.json"
    $list = Read-JsonFile $path -Where $where -Errors $Errors
    if ($null -eq $list) { return $null }
    $before = $Errors.Count
    if (Test-Path (Join-Path $Dir 'screenshot.json')) { $Errors.Add("$where and screenshot.json are both here. A port has a recipe or a shot list, not both.") }
    $shots = $null
    if ($list -is [System.Collections.IDictionary]) {
        $shots = $list['shots']
        foreach ($k in $list.Keys) { if ($k -ne 'shots') { $Errors.Add("$where has an unknown field '$k'. It holds only 'shots'.") } }
    }
    if (-not ($shots -is [System.Collections.IList] -and $shots.Count -gt 0)) {
        $Errors.Add("$where needs 'shots', a list of { name, variant, show }.")
        return $null
    }
    $seen = @{}
    $i = 0
    foreach ($s in $shots) {
        $at = "$where shots[$i]"
        $i++
        if ($s -isnot [System.Collections.IDictionary]) { $Errors.Add("$at must be an object { name, variant, show }."); continue }
        foreach ($k in $s.Keys) { if ($k -notin 'name', 'variant', 'show') { $Errors.Add("$at has an unknown field '$k'. A shot holds only name, variant and show.") } }
        if (-not ($s['name'] -is [string] -and $s['name'] -cmatch '^[a-z0-9]+(-[a-z0-9]+)*$')) { $Errors.Add("$at needs 'name', the image's file name without .png (lowercase, hyphenated).") }
        elseif ($seen.ContainsKey($s['name'])) { $Errors.Add("$where names '$($s['name'])' twice.") }
        else { $seen[$s['name']] = $true }
        if ($s['variant'] -notin 'day', 'night') { $Errors.Add("$at needs 'variant': day or night.") }
        if (-not ($s['show'] -is [string] -and $s['show'].Trim())) { $Errors.Add("$at needs 'show': top, or the name of a page section.") }
    }
    foreach ($v in 'day', 'night') {
        if (-not @($shots | Where-Object { $_ -is [System.Collections.IDictionary] -and $_['variant'] -eq $v }).Count) { $Errors.Add("$where has no $v shot. Both variants are shot, or neither.") }
    }
    if ($Errors.Count -ne $before) { return $null }
    return , ([object[]]@($shots))
}

function Get-ShotProblems($Catalog) {
    # Every port the Photographer shoots ships with its images: day.png and night.png
    # for a recipe, every image of a shot list. Lists one problem per missing image.
    $problems = [System.Collections.Generic.List[string]]::new()
    foreach ($p in $Catalog.Ports) {
        $names = if ($p.Shots) { @($p.Shots | ForEach-Object { $_['name'] }) } elseif ($p.Recipe) { @('day', 'night') } else { continue }
        foreach ($n in $names) {
            if (-not (Test-Path -LiteralPath (Join-Path $p.Dir 'screenshots' "$n.png") -PathType Leaf)) {
                $how = if ($p.Recipe -and $p.Recipe.Contains('manual')) { 'take it by hand, then run' } else { 'run' }
                $problems.Add("Ports/$($p.Name)/screenshots/$n.png is missing. A port ships with real screenshots: $how pwsh build/photograph.ps1 -Port $($p.Name).")
            }
        }
    }
    return $problems.ToArray()
}

function Get-PortCatalog {
    <#
    .SYNOPSIS
        Every folder under Ports/, validated. Returns
        @{ Ports; Categories; Planned; StructureErrors; Errors; RecipeErrors }.
    .DESCRIPTION
        Each port is @{ Name; Dir; Listed; HasTemplate; HasReadme; Meta;
        Variants; Icon; Site }. Listed is $false for folders in 'unlisted'
        (not app ports, like the preview page). Meta is port.json, Variants
        the dist/ variant folders present, Icon the validated credit or $null,
        Site the validated site.json or $null, Recipe the validated
        screenshot.json or $null, Shots the validated shots.json list (the
        preview's) or $null. RecipeErrors covers screenshot.json and shots.json.
        StructureErrors covers README.md, template/, and site.json; Errors
        covers port.json, ports.json, and icons.
    #>
    param([Parameter(Mandatory)][string]$PortsRoot, [string[]]$VariantKeys = @('day', 'night'))
    $errors = [System.Collections.Generic.List[string]]::new()
    $structure = [System.Collections.Generic.List[string]]::new()
    $recipeErrors = [System.Collections.Generic.List[string]]::new()
    $catalog = @{ RecipeErrors = $recipeErrors; Ports = [System.Collections.Generic.List[object]]::new(); Categories = [ordered]@{}; Planned = @(); StructureErrors = $structure; Errors = $errors }
    $dirs = if (Test-Path $PortsRoot) { @(Get-ChildItem -Path $PortsRoot -Directory | Sort-Object Name) } else { @() }

    $index = $null
    $indexPath = Join-Path $PortsRoot 'ports.json'
    if (-not (Test-Path $indexPath)) { $errors.Add('Ports/ports.json does not exist.') }
    else { $index = Read-JsonFile $indexPath -Where 'Ports/ports.json' -Errors $errors }
    if ($index -is [System.Collections.IDictionary]) {
        if ($index['categories'] -is [System.Collections.IDictionary] -and $index['categories'].Count -gt 0) { $catalog.Categories = $index['categories'] }
        else { $errors.Add("Ports/ports.json needs 'categories', an object of id to display name.") }
        if ($index['planned'] -isnot [System.Collections.IList]) { $errors.Add("Ports/ports.json needs 'planned', a list (it can be empty).") }
    }
    $unlisted = @()
    if ($index -is [System.Collections.IDictionary] -and $index.Contains('unlisted')) {
        if ($index['unlisted'] -is [System.Collections.IList]) { $unlisted = @($index['unlisted']) }
        else { $errors.Add("'unlisted' in Ports/ports.json must be a list of folder names.") }
    }
    foreach ($u in $unlisted) { if (-not ($dirs | Where-Object Name -eq $u)) { $errors.Add("unlisted folder Ports/$u does not exist.") } }

    foreach ($dir in $dirs) {
        $name = $dir.Name
        $port = @{
            Name = $name; Dir = $dir.FullName; Listed = ($name -notin $unlisted)
            HasTemplate = Test-Path (Join-Path $dir.FullName 'template')
            HasReadme = Test-Path (Join-Path $dir.FullName 'README.md')
            Meta = $null; Icon = $null; Site = $null; Recipe = $null; Shots = $null
            Variants = @(foreach ($v in $VariantKeys) { if (Test-Path (Join-Path $dir.FullName 'dist' $v)) { $v } })
        }
        if (-not $port.HasReadme) { $structure.Add("Ports/$name has no README.md.") }
        if (-not $port.HasTemplate) { $structure.Add("Ports/$name has no template/ folder.") }
        $port.Site = Read-SiteSpec $dir.FullName $name $structure
        $port.Recipe = Read-Recipe $dir.FullName $name $recipeErrors
        $port.Shots = Read-ShotList $dir.FullName $name $recipeErrors
        if ($port.Listed) {
            $where = "Ports/$name/port.json"
            $metaPath = Join-Path $dir.FullName 'port.json'
            if (-not (Test-Path $metaPath)) { $errors.Add("$where does not exist.") }
            else {
                $meta = Read-JsonFile $metaPath -Where $where -Errors $errors
                if ($null -ne $meta) {
                    $port.Meta = $meta
                    Test-PortMeta $meta $where $false $catalog.Categories $errors
                    if (Test-PortIcon $dir.FullName $meta $name $errors) { $port.Icon = $meta['icon'] }
                }
            }
        }
        $catalog.Ports.Add($port)
    }

    if ($index -is [System.Collections.IDictionary] -and $index['planned'] -is [System.Collections.IList]) {
        $catalog.Planned = @($index['planned'])
        $seen = @{}
        $i = 0
        foreach ($p in $index['planned']) {
            $where = "Ports/ports.json planned[$i]"
            $i++
            Test-PortMeta $p $where $true $catalog.Categories $errors
            if ($p -isnot [System.Collections.IDictionary]) { continue }
            $folder = $p['folder']
            if (-not ($folder -is [string] -and $folder -cmatch '^[a-z0-9]+(-[a-z0-9]+)*$')) {
                $errors.Add("$where needs 'folder', the future Ports/ folder name (lowercase, hyphenated).")
                continue
            }
            if ($seen.ContainsKey($folder)) { $errors.Add("'$folder' is planned twice.") }
            $seen[$folder] = $true
            if ($dirs | Where-Object Name -eq $folder) { $errors.Add("Ports/$folder exists, so remove it from 'planned' in Ports/ports.json.") }
        }
    }

    Test-RecipeHosts $catalog.Ports $recipeErrors
    return $catalog
}

function ConvertTo-PortsData {
    # The data the ports page reads (window.THEME_PORTS), from a valid catalog.
    param($Catalog)
    $card = {
        param($m, [string]$Folder)
        [ordered]@{
            folder    = $Folder
            name      = $m['name']
            category  = $m['category']
            tier      = $m['tier']
            platforms = @($m['platforms'])
            monogram  = if ($m.Contains('monogram')) { $m['monogram'] } else { $null }
        }
    }
    $ports = @(foreach ($p in $Catalog.Ports) {
        if (-not $p.Listed) { continue }
        $c = & $card $p.Meta $p.Name
        $c['icon'] = if ($p.Icon) {
            [ordered]@{ path = "Ports/$($p.Name)/icon.svg"; kind = $p.Icon['kind']; set = $p.Icon['set']
                        author = $p.Icon['author']; license = $p.Icon['license']; source = $p.Icon['source'] }
        } else { $null }
        $c['variants'] = @($p.Variants)
        $c
    })
    return [ordered]@{
        categories = $Catalog.Categories
        tiers      = $Tiers
        platforms  = $Platforms
        ports      = $ports
        planned    = @(foreach ($p in $Catalog.Planned) { & $card $p $p['folder'] })
    }
}

Export-ModuleMember -Function Get-PortCatalog, ConvertTo-PortsData, Get-IconRules, Read-JsonFile, Get-ShotProblems
