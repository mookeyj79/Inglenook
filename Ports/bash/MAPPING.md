# Bash line editor and completion list: color mapping

For maintainers. The install guide is [README.md](README.md).

The Bash counterpart of [the Zsh port](../zsh/MAPPING.md). Two files per variant:

- `bash.inputrc` (template `bash.inputrc`), Readline settings, which `~/.inputrc` includes with `$include`.
- `bash.sh` (template `bash.sh`), which `~/.bashrc` sources. It only sets `LS_COLORS`, so it is valid in Bash and Zsh and the checks source it in both.

## Color mapping

### Readline (bash.inputrc)

| Setting | Color | Why |
|---|---|---|
| `active-region-start-color` | background `accent` wash (`\e[48;2;{{accent\|wash\|sgr}}m`) | Readline's one highlight, used for the region after `exchange-point-and-mark`, a bracketed paste, and the match in an incremental or non-incremental history search. The region is a selection, so a firelight wash (PHILOSOPHY.md, Washes). Background only, so the text keeps the terminal's own color |
| `active-region-end-color` | `\e[0m` | The manual's own sample. Nothing else on the command line has an attribute to keep |
| `colored-stats` | on | File kinds in the completion list, from `LS_COLORS` |
| `colored-completion-prefix` | on | The shared prefix, from the `*readline-colored-completion-prefix` key in `LS_COLORS` (below) |

The color lines sit inside `$if version >= 8.2`: Readline 8.1 and older do not know the two variables and print `unknown variable name` at startup.

### LS_COLORS (bash.sh)

| Key | Color | Why |
|---|---|---|
| `*readline-colored-completion-prefix` | `dim` | The part already typed, shared by every entry: supporting text, so the part that tells entries apart stands out. Readline's default for it is the socket color (`so`), which is heather and would mean a keyword |
| every other key, only when `LS_COLORS` is unset | the eza port's `LS_COLORS` values | The same values as eza and as the Zsh port's `list-colors`, so `ls`, eza and Tab agree. Kept as a shell variable that is not exported, so `ls` and other programs never see it |

When `LS_COLORS` is already set (dircolors on Debian, Ubuntu, Mint and Fedora, or the eza port), `bash.sh` only appends the prefix key, so the completion list keeps the reader's file colors, the same as `ls`. The owner decides whether the port should instead always use the theme's file colors for the completion list; see Gaps.

## Gaps and trade-offs

- Readline has one highlight (the active region) for the selection, a paste and the history search match. The Zsh port gives them three colors (`region` accent wash, `isearch` accent fill with `on_accent`, `paste` `hover`). Here all three are the accent wash: it is the only choice that keeps the selection a firelight wash, and the search match is still firelight, the match at the cursor. Paste differs from the Zsh port (hover); the owner kept the accent wash so the selection stays firelight.
- Readline reads `LS_COLORS` once, when it starts (`readline_initialize_everything` in `lib/readline/readline.c`), and only if `colored-stats` or `colored-completion-prefix` is already on then. A `bind 'set colored-stats on'` in `~/.bashrc` runs after Readline starts (the `bind` builtin starts it), so the list falls back to Readline's built-in ANSI defaults. That is why the settings live in `~/.inputrc`, and why the port needs two files and two install lines.
- Readline reads `LS_COLORS` through Bash's own variable lookup (`sh_get_env_value` in `variables.c` calls `get_string_value`), so an unexported shell variable works. Checked in Bash 5.2.21.
- With `LS_COLORS` already set, the list's file colors are the reader's, not the theme's. On Mint (the screenshot) they are dircolors' ANSI colors, which an Inglenook terminal draws as steel, pine, moss and so on.
- The custom key is written `*readline-colored-completion-prefix`, as the manual names it. The CHANGES file writes `*.readline-colored-completion-prefix`; with the dot Readline does not match it (checked in Bash 5.2.21).
- Zsh's `suffix` and `special` highlights have no Readline counterpart. Readline has no color for the `/` it adds after a folder, for `^[`-style characters, or for the entry picked by `menu-complete`.
- The washes are mixed into `base`, so they are exact only on an Inglenook terminal.
- The screenshots cannot show: devices, pipes, sockets, setuid, world-writable folders, broken links, audio, video, documents; nor the theme's own file colors (the Mint `~/.bashrc` sets `LS_COLORS`).

## Research

- No Catppuccin, Dracula, Nord, Gruvbox or Rosé Pine organization has code that sets Readline's `active-region-start-color` (GitHub code search of each organization, 2026-11-27). Method taken from the Readline manual instead: Readline settings belong in `~/.inputrc`.
- Readline's defaults: `active-region-start-color` is the terminal's standout mode; `colored-stats` and `colored-completion-prefix` are off; `enable-active-region` is on (Bash manual, Readline Init File Syntax).
- `set-mark` does not activate the region; `exchange-point-and-mark` does (`rl_exchange_point_and_mark` calls `rl_activate_mark` in `lib/readline/text.c`), as do bracketed paste (`kill.c`) and the history searches (`isearch.c`, `search.c`).
- `$include` paths get tilde expansion, and Readline 8.x supports `$if version >= 8.2` (Conditional Init Constructs).
- The file's own checks: in Bash 5.2.21 under a pseudo terminal, the completion list prints the prefix in `38;2` dim and the region, paste and search match in `48;2` with the accent wash; with `LS_COLORS` unset, `env` in a child shows no `LS_COLORS`.

## Screenshot recipe

- Bash needs no login or license key (GPL-3.0).
- The recipe pins Bash 5.2.21 from the base image (Mint 22.3) and runs inside the Inglenook GNOME Terminal. The apply steps are the README's install steps, including creating `~/.inputrc` with `$include /etc/inputrc`.
- The scene (`build/photograph/scenes/cli/bash/`) runs an interactive Bash under `drive.py`, a pseudo terminal that types the keys a reader presses: Ctrl+Space, Alt+B, Ctrl+B and Ctrl+X Ctrl+X for a selection, a bracketed paste, Ctrl+R, and Tab Tab twice. Each line but the last is left with Ctrl+C, with `stty -echoctl` so `^C` does not cover it. Not tested by hand.
