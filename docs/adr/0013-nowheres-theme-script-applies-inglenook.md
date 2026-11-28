# Nowhere's theme script applies Inglenook

Supersedes [ADR 0012](0012-the-user-applies-the-theme.md).

Nowhere now has a theme script (its ADR 0005) that applies a theme, Inglenook among several others, to the tools Nowhere installs. It fetches Inglenook's built ports (`Ports/<app>/dist/day` and `dist/night`) at a pinned commit, the same way it fetches Catppuccin's or Nord's. Inglenook itself still installs nothing: no installer, variant setting, switch command or light and dark detection lives here, and every port still stands alone with its step-by-step guide for anyone not using Nowhere.

## Consequences

- A port's "With Nowhere" section says to run `theme inglenook-day` or `theme inglenook-night` instead of which file to put in Nowhere's theme file.
- Nowhere reads `dist/` at a commit, so a port's file names and layout under `dist/` are something Nowhere depends on. Changing them means a pin bump in Nowhere.
- Terminals are outside Nowhere's script, so the terminal ports' guides are still how a user matches the terminal to the shell.
- An automatic sunrise and sunset switch still belongs to neither repo.
