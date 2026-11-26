# Zsh line editor and completion list: color mapping

For maintainers. The install guide is [README.md](README.md).

One file per variant, `zsh.zsh`, sets the `zle_highlight` array and the `list-colors` style for the `default` tag. Zsh only (template `zsh.zsh`).

## Color mapping

### zle_highlight

| Context | Color | Why |
|---|---|---|
| `region` | background `accent` wash | A selection (PHILOSOPHY.md, Washes). Background only, so syntax colors from zsh-syntax-highlighting show through |
| `isearch` | background `accent` wash, bold | A find match, as Git's grep match. Bold tells it apart from a selection |
| `paste` | background `hover` | Text just inserted, marked without meaning. Not the accent: a paste is not "you are here". Owner to confirm |
| `suffix` | `dim` | The removable `/` after a folder is punctuation; matches `tc` in the list |
| `special` | `literal` | An escaped character, as eza's `control_char` |
| `default` | not set | The terminal's own text |

### list-colors

| Key | Color | Why |
|---|---|---|
| `ma` (the pick in a selection menu) | `text` on the `accent` wash | The same as a selection in the line editor. The wash is written as `#rrggbb` and turned into `r;g;b` by the file itself, because a placeholder cannot chain `wash` and `sgr` |
| `no`, `fi` | not set | The terminal's own text |
| `di` | `ansi.blue` (steel), bold | The same as eza's `LS_COLORS`, so `ls` and Tab agree |
| `ln` | `reference` | |
| `ex` | `ansi.green` (moss), bold | |
| `pi`, `so` (bold) | `heather` | |
| `bd`, `cd` | `clay`, bold | |
| `or`, `mi` | `error` | A broken link |
| `su`, `sg` | `heather`, bold | |
| `tw`, `ow`, `st` | `ansi.blue`, bold and underlined | |
| `tc` (the `/`, `@`, `*` after a name) | `dim` | Punctuation |
| `hi`, `du` (hidden and duplicate matches) | `faint` | Shown only in a selection menu, quieter than real matches |
| archives, images, video, audio, documents, `*.tmp` `*.swp` `*.bak` | `oxblood`, `heather`, `dusk`, `ivy`, `faint` | The same extensions and colors as eza's `LS_COLORS` |
| `lc`, `rc`, `ec`, `sp`, `sa` | not set | Escape code framing and padding, no color |

Parity with PSReadLine (#24): a selection and the pick in a menu use the `accent` wash; PSReadLine's `Selection` should match.

## Gaps and trade-offs

- `zle_highlight` takes `#rrggbb`. Zsh 5.9 writes it as 24-bit color whatever the terminal, unless `zsh/nearcolor` is loaded (README, Troubleshooting).
- `list-colors` values are raw SGR codes (`38;2;r;g;b`), always 24-bit; `zsh/nearcolor` does not touch them.
- The washes are mixed into `base`, so they are exact only on an Inglenook terminal.
- With `compinit`, `ZLS_COLORS` is unset by `_setup` when no `list-colors` style is set for `default`, so the port sets only the style. It is set for `:completion:*:default`, the manual's own example, which beats `:completion:*` from frameworks.
- `ma` replaces the file kind's color on the pick, so the pick shows in `text`.
- Group headings and descriptions come from the `format` styles (`%F{...}` in a format string), not `list-colors`. They are layout as much as color, so the port leaves them alone.
- The screenshots cannot show: `isearch` (it ends when the line is left), devices, pipes, sockets, setuid, world-writable folders, broken links, hidden and duplicate matches, audio, video, documents.

## Research

- No Catppuccin, Dracula, Nord or Rosé Pine port sets `zle_highlight` or `list-colors` (GitHub code search of each organization, 2026-11-26). Dracula's zsh repository is a prompt theme. Catppuccin's zsh ports cover zsh-syntax-highlighting only.
- Zsh's defaults are `region:standout special:standout suffix:bold isearch:underline paste:standout` (Character Highlighting). The port replaces each with a solid color.
- `_setup` (`Completion/Base/Core/_setup`) loads `zsh/complist` itself when the style is set, so the file does not.
- The file's own checks: sourced in `zsh -f`, `print -l $zle_highlight` and `zstyle -L` show the values; in an interactive Zsh under tmux, `capture-pane -e` shows `48;2` region, paste and `ma` backgrounds and the `38;2` list colors.

## Screenshot recipe

- Zsh needs no login or license key ([Zsh licence](https://github.com/zsh-users/zsh/blob/master/LICENCE), permissive).
- The recipe installs Zsh 5.9 from the Ubuntu package date and runs inside the Inglenook GNOME Terminal.
- The scene (`build/photograph/scenes/cli/zsh/`) turns on `compinit` and `menu select` before `~/.zshrc` loads, as a reader's setup would. The apply steps add the README's source line to `~/.zshrc`.
- The keys a reader presses (Ctrl+Space and Alt+B, a paste, Ctrl+V Esc, Ctrl+C, Tab) are played with the line editor's own widgets from `zle-line-init`. The paste is `bracketed-paste` flagged as a yank, then `send-break`, so its highlight stays as it does when a reader presses Ctrl+C. Not tested by hand.
