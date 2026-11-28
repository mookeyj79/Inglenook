# Inglenook for PSReadLine: Inglenook Night. PowerShell only.
# Source this from your PowerShell profile ($PROFILE). It colors the command line as you type.
# Palette 1.0.0, https://github.com/mookeyj79/Inglenook
& {
    if (-not (Get-Command Set-PSReadLineOption -ErrorAction Ignore)) { return }

    # Each color is a foreground, or a foreground and a background.
    $colors = [ordered]@{
        Default                = '#d1c9bc'
        Command                = '#89b3d8'
        Parameter              = '#da9f7c'
        String                 = '#91bc88'
        Variable               = '#72bdbd'
        Number                 = '#da9f7c'
        Keyword                = '#cb9cc6'
        Type                   = '#a5a5d9'
        Member                 = '#89b3d8'
        Operator               = '#b1aa9e'
        Comment                = '#8f887f'
        ContinuationPrompt     = '#b1aa9e'
        Error                  = '#d9897e'
        Emphasis               = '#d1c9bc', '#31383e'
        Selection              = '#d1c9bc', '#463624'
        InlinePrediction       = '#8f887f'
        ListPrediction         = '#8f887f'
        ListPredictionSelected = '', '#463624'
        ListPredictionTooltip  = '#8f887f'
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
