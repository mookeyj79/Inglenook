# The terminal scene for Windows terminals: the same staged slice as run.sh, read from
# the same transcript.txt. Fixed text, never live output. Colors are ANSI slots only.
# Launch it with: pwsh -NoLogo -NoProfile -File "$env:INGLENOOK_SCENE/run.ps1"
$e = [char]27
$slot = @{ r = "$e[0m"; b = "$e[1m"; red = "$e[31m"; green = "$e[32m"; yellow = "$e[33m"; blue = "$e[34m"; magenta = "$e[35m"; cyan = "$e[36m"; muted = "$e[90m" }
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
function Get-Prompt([string]$Command) { "$($slot.blue)~/Inglenook$($slot.r) on $($slot.magenta)main$($slot.r) `$ $Command" }

$lines = [System.Collections.Generic.List[string]]::new()
foreach ($line in [System.IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'transcript.txt'))) {
    if ($line.StartsWith('#')) { continue }
    if ($line.StartsWith('$ ')) { $lines.Add((Get-Prompt $line.Substring(2))); continue }
    $lines.Add([regex]::Replace($line, '\{(r|b|red|green|yellow|blue|magenta|cyan|muted)\}', { param($m) $slot[$m.Groups[1].Value] }))
}

# One write, CR LF line ends, and the cursor left on the last prompt.
[Console]::Write("$e[H$e[2J" + ($lines -join "`r`n") + "`r`n" + (Get-Prompt ''))
while ($true) { Start-Sleep -Seconds 3600 }
