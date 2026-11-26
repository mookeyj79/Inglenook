# {{meta.name}} for GitHub CLI: {{variant.name}}. Points gh's Markdown at
# ~/.config/inglenook/gh-markdown.json. Source this from your PowerShell profile.
# Palette {{meta.version}}, {{meta.repository}}
$env:GLAMOUR_STYLE = Join-Path $HOME '.config/inglenook/gh-markdown.json'
