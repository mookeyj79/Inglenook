# {{meta.name}} for PSReadLine: {{variant.name}}. PowerShell only.
# Source this from your PowerShell profile ($PROFILE). It colors the command line as you type.
& {
    if (-not (Get-Command Set-PSReadLineOption -ErrorAction Ignore)) { return }

    # Each color is a foreground, or a foreground and a background.
    $colors = [ordered]@{
        Default                = '{{text}}'
        Command                = '{{info}}'
        Parameter              = '{{literal}}'
        String                 = '{{success}}'
        Variable               = '{{reference}}'
        Number                 = '{{literal}}'
        Keyword                = '{{keyword}}'
        Type                   = '{{type}}'
        Member                 = '{{info}}'
        Operator               = '{{dim}}'
        Comment                = '{{faint}}'
        ContinuationPrompt     = '{{dim}}'
        Error                  = '{{error}}'
        Emphasis               = '{{on_accent}}', '{{accent}}'
        Selection              = '{{text}}', '{{accent|wash}}'
        InlinePrediction       = '{{faint}}'
        ListPrediction         = '{{faint}}'
        ListPredictionSelected = '', '{{accent|wash}}'
        ListPredictionTooltip  = '{{faint}}'
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
