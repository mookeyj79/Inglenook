# zsh-autosuggestions: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` | `fg=` faint | A suggestion is not typed yet, like a placeholder. The plugin's default is `fg=8`, bright black, which is faint in the Inglenook terminal ports too |

PowerShell parity: PSReadLine's inline prediction (#24) is the same thing and should use faint as well.

## Gaps and trade-offs

- Tier 1: the plugin draws one thing, the suggestion, and the port colors it. Background and typed text belong to the terminal and to zsh-syntax-highlighting.
- Only `fg` is set. No background, bold, or underline: a suggestion should stay quieter than typed text.
- Zsh only (`template/zsh-autosuggestions.zsh`). The plugin does not exist for Bash, and PowerShell's equivalent is PSReadLine.
- The value is a hex triplet, which Zsh draws as 24-bit color. A 256-color terminal needs `zmodload zsh/nearcolor` (README Troubleshooting).
- In an Inglenook terminal the plugin's default `fg=8` already looks like faint, so the shots look the same with or without the port. The port matters in a terminal with other colors.
- The file can be sourced before or after the plugin: the plugin only sets its default when the variable is unset, and reads it each time it draws. The README says "below" so a later default never wins.

## Research

- No other theme ports zsh-autosuggestions (Catppuccin, Nord, Dracula, Gruvbox, Rose Pine have none, as of 2026-11-26; Catppuccin has only zsh-syntax-highlighting).
- zsh-autosuggestions at Nowhere's pinned commit `85919cd` (v0.7.1 plus six commits): `src/config.zsh` sets `fg=8` only when unset; `src/highlight.zsh` adds `$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` to `region_highlight` each time a suggestion is drawn.
- Zsh manual, Character Highlighting: `fg=#RRGGBB` is 24-bit color; `zsh/nearcolor` maps it for 88 and 256 color terminals.

## Screenshot recipe

- zsh-autosuggestions and Zsh need no login or license (MIT, [license](https://github.com/zsh-users/zsh-autosuggestions/blob/master/LICENSE); Zsh is MIT-style).
- The plugin comes from the GitHub archive of Nowhere's pinned commit, checked against its SHA-256. Ubuntu packages an older release.
- The install step loads the plugin from `/etc/zsh/zshrc`, standing in for the reader's own plugin line. It runs before `~/.zshrc`, so the theme line comes after it, as the README says. Not tested by hand.
- The scene (`build/photograph/scenes/cli/zsh-autosuggestions/`) starts an interactive zsh that loads `~/.zshrc`, runs two real git commands, puts one older commit command in the history, and types `git c` with a `zle-line-init` hook so the plugin suggests the rest. The GNOME Terminal port hosts it.
