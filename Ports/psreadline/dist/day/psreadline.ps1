# Inglenook for PSReadLine: Inglenook Day. PowerShell only.
# Source this from your PowerShell profile ($PROFILE). It colors the command line as you type.
# Palette 1.0.0, https://github.com/mookeyj79/Inglenook
& {
    if (-not (Get-Command Set-PSReadLineOption -ErrorAction Ignore)) { return }

    # Each color is a foreground, or a foreground and a background.
    $colors = [ordered]@{
        Default                = '#2d373f'
        Command                = '#326893'
        Parameter              = '#915023'
        String                 = '#407135'
        Variable               = '#017272'
        Number                 = '#915023'
        Keyword                = '#844b80'
        Type                   = '#5e5a9a'
        Member                 = '#326893'
        Operator               = '#49545d'
        Comment                = '#657178'
        ContinuationPrompt     = '#49545d'
        Error                  = '#a04037'
        Emphasis               = '#2d373f', '#d2dddf'
        Selection              = '#2d373f', '#e3dbc8'
        InlinePrediction       = '#657178'
        ListPrediction         = '#657178'
        ListPredictionSelected = '', '#e3dbc8'
        ListPredictionTooltip  = '#657178'
    }

    # PSReadLine takes 24-bit escape sequences in every version. Older versions
    # lack the prediction colors, so only the names this one knows are set.
    # Each name's option is <name>Color, except Default's (DefaultTokenColor).
    $known = (Get-PSReadLineOption).PSObject.Properties.Name
    $set = @{}
    foreach ($name in $colors.Keys) {
        $option = if ($name -eq 'Default') { 'DefaultTokenColor' } else { "${name}Color" }
        if ($option -notin $known) { continue }
        $codes = for ($i = 0; $i -lt @($colors[$name]).Count; $i++) {
            $hex = @($colors[$name])[$i]
            if (-not $hex) { continue }
            $rgb = foreach ($at in 1, 3, 5) { [Convert]::ToInt32($hex.Substring($at, 2), 16) }
            @('38', '48')[$i] + ';2;' + ($rgb -join ';')
        }
        $set[$name] = [char]27 + '[' + ($codes -join ';') + 'm'
    }
    Set-PSReadLineOption -Colors $set
}
