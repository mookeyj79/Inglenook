# One staged command line of the PSReadLine scene (see session.sh). The reader's
# profile has loaded by now, with the theme. When PSReadLine first waits for a key,
# the line in INGLENOOK_LINE is typed for it. A past line then exits, leaving it on
# screen as PSReadLine drew it; the last one picks the first list view suggestion.
function global:prompt { 'PS ~/Inglenook> ' }
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($env:INGLENOOK_LINE)
    if ($env:INGLENOOK_LAST) { [Microsoft.PowerShell.PSConsoleReadLine]::NextSuggestion() }
    else { [Environment]::Exit(0) }
}
