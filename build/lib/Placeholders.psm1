# Template placeholders: the one definition of the {{...}} grammar, how each
# placeholder resolves for a variant, and how template files are read.
# The build expands templates with it; the checks ask it what is wrong.
# The table in CONTRIBUTING.md ("Add a port", step 4) documents it.

Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'Palette.psm1')

$Pattern = '\{\{\s*([A-Za-z_][A-Za-z0-9_.]*)\s*((?:\|\s*[A-Za-z0-9]+\s*)*)\}\}'

# The filters of a match, as one string: '' or 'wash' or 'wash|comma'.
function Get-MatchFilter($Match) { return ($Match.Groups[2].Value -replace '\s', '').TrimStart('|') }

function Resolve-Placeholder {
    <#
    .SYNOPSIS
        Resolves one placeholder for a variant. Returns @{ Value } or @{ Error }.
    .DESCRIPTION
        Colors: {{<neutral>}}, {{<named color>}}, {{<role>}}, {{ansi.<slot>}},
        each with an optional color filter, or |wash and then one format
        filter (nohash, rgb, sgr, comma), as in {{steel|wash|comma}}. Text: {{meta.<key>}},
        {{variant.name|key|mode}}, {{port.<key>}}, with an optional |slug.
    .PARAMETER PortValues
        The port's values.json: @{ day = @{ key = value }; night = @{ ... } }, or $null.
    #>
    param([string]$Name, [string]$Filter, $Palette, $Variant, $PortValues)
    $token = '{{' + $Name + $(if ($Filter) { "|$Filter" }) + '}}'
    $value = $null
    switch -Regex ($Name) {
        '^meta\.(.+)$' {
            if ($Palette.Meta.Contains($Matches[1])) { $value = [string]$Palette.Meta[$Matches[1]] }
            break
        }
        '^variant\.(.+)$' {
            switch ($Matches[1]) { 'key' { $value = $Variant.Key } 'name' { $value = $Variant.Name } 'mode' { $value = $Variant.Mode } }
            break
        }
        '^port\.(.+)$' {
            $set = if ($PortValues -is [System.Collections.IDictionary]) { $PortValues[$Variant.Key] } else { $null }
            if ($set -is [System.Collections.IDictionary] -and $set.Contains($Matches[1])) { $value = [string]$set[$Matches[1]] }
            break
        }
        default {
            if (-not (Get-PaletteEntry -Variant $Variant -Name $Name)) {
                if ($Name -like 'ansi.*') { return @{ Error = "Unknown ANSI slot in $token." } }
                break
            }
            try { return @{ Value = (Format-PaletteColor -Variant $Variant -Name $Name -Filter $Filter) } }
            catch { return @{ Error = "$token`: $($_.Exception.Message)." } }
        }
    }
    if ($null -eq $value) { return @{ Error = "Unknown placeholder $token." } }
    if ($Filter -eq 'slug') { return @{ Value = ($value.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-') } }
    if ($Filter) { return @{ Error = "Only slug applies to text placeholders: $token." } }
    return @{ Value = $value }
}

function Expand-Template {
    # Replaces every placeholder in $Text for one variant. Throws on the first
    # one that does not resolve, naming $Source.
    param([string]$Text, $Palette, $Variant, $PortValues, [string]$Source)
    return $Text -creplace $Pattern, {
        $r = Resolve-Placeholder -Name $_.Groups[1].Value -Filter (Get-MatchFilter $_) `
            -Palette $Palette -Variant $Variant -PortValues $PortValues
        if ($r.Contains('Error')) { throw "$($r.Error) In $Source." }
        $r.Value
    }
}

function Find-PlaceholderError {
    # Every placeholder in $Text that does not resolve in some variant, as
    # messages. Empty when the text is fine.
    param([string]$Text, $Palette, $PortValues)
    $seen = [ordered]@{}
    foreach ($m in [regex]::Matches($Text, $Pattern)) {
        foreach ($variant in $Palette.Variants.Values) {
            $r = Resolve-Placeholder -Name $m.Groups[1].Value -Filter (Get-MatchFilter $m) `
                -Palette $Palette -Variant $variant -PortValues $PortValues
            if ($r.Contains('Error')) {
                $msg = $r.Error
                if ($m.Groups[1].Value -match '^port\.') { $msg = "$msg (missing from values.json for $($variant.Key))" }
                $seen[$msg] = $true
            }
        }
    }
    return @($seen.Keys)
}

function Get-PlaceholderColor {
    # The palette names $Text draws, in either variant: neutrals, named colors
    # and roles as written, and {{ansi.<slot>}} as the neutral or named color
    # the slot comes from.
    param([string]$Text, $Palette)
    $names = [System.Collections.Generic.SortedSet[string]]::new()
    foreach ($m in [regex]::Matches($Text, $Pattern)) {
        $name = $m.Groups[1].Value
        foreach ($variant in $Palette.Variants.Values) {
            $e = Get-PaletteEntry -Variant $variant -Name $name
            if (-not $e) { continue }
            [void]$names.Add($(if ($e.Kind -eq 'ansi') { $e.Source } else { $name }))
        }
    }
    return @($names)
}

function Find-Placeholder {
    # The first {{placeholder}} in $Text, or $null. For checking generated output.
    param([string]$Text)
    $m = [regex]::Match($Text, $Pattern)
    if ($m.Success) { return $m.Value }
    return $null
}

function Read-TemplateFile {
    <#
    .SYNOPSIS
        Reads a template. Returns @{ Binary = $true; Bytes } for a binary file,
        otherwise @{ Binary = $false; Encoding; Text }, keeping a BOM or UTF-16.
    #>
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $enc = $null
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $enc = [System.Text.UTF8Encoding]::new($true)
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        $enc = [System.Text.UnicodeEncoding]::new($false, $true)
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        $enc = [System.Text.UnicodeEncoding]::new($true, $true)
    }
    elseif ([Array]::IndexOf($bytes, [byte]0) -ge 0) {
        return @{ Binary = $true; Bytes = $bytes }
    }
    else {
        $enc = [System.Text.UTF8Encoding]::new($false)
    }
    $skip = $enc.GetPreamble().Length
    return @{ Binary = $false; Encoding = $enc; Text = $enc.GetString($bytes, $skip, $bytes.Length - $skip) }
}

Export-ModuleMember -Function Resolve-Placeholder, Expand-Template, Find-PlaceholderError, Get-PlaceholderColor, Find-Placeholder, Read-TemplateFile
