# {{meta.name}} for Starship: {{variant.name}}. Points Starship at
# ~/.config/inglenook/starship.toml. Source this from your PowerShell profile.
# Palette {{meta.version}}, {{meta.repository}}
$env:STARSHIP_CONFIG = Join-Path $HOME '.config/inglenook/starship.toml'
