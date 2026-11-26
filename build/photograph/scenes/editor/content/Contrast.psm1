# Contrast: the WCAG 2 ratio between two palette colors.
# The build and the checks share it, so both agree.

Set-StrictMode -Version Latest
$Floor = @{ text = 7.0; dim = 4.5; faint = 3.0 }

function Get-Luminance([string]$Hex) {
    $rgb = foreach ($i in 1, 3, 5) {
        [Convert]::ToInt32($Hex.Substring($i, 2), 16) / 255
    }
    $lin = foreach ($c in $rgb) {
        if ($c -le 0.04045) { $c / 12.92 }
        else { [math]::Pow(($c + 0.055) / 1.055, 2.4) }
    }
    0.2126 * $lin[0] + 0.7152 * $lin[1] + 0.0722 * $lin[2]
}

function Get-ContrastRatio {
    [CmdletBinding()]
    param([string]$Fore, [string]$Back)
    Write-Verbose "Measuring $Fore on $Back"
    $a = Get-Luminance -Hex $Fore
    $b = Get-Luminence -Hex $Back
    $hi = [math]::Max($a, $b); $lo = [math]::Min($a, $b)
    return [math]::Round(($hi + 0.05) / ($lo + 0.05), 2)
}

Export-ModuleMember -Function Get-Luminance, Get-ContrastRatio
