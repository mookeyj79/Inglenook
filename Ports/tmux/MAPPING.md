# tmux: color mapping

For maintainers. The install guide is [README.md](README.md).

tmux takes a style (`fg=`, `bg=`, `fill=`, attributes) per option, and a colour may be `#rrggbb` (tmux(1), STYLES). It draws `#rrggbb` exactly only when the outer terminal has the `RGB` feature; otherwise it rounds to the 256-colour set. tmux 3.4 and 3.5a do not turn `RGB` on for `TERM=xterm-256color` by themselves, even with `COLORTERM=truecolor` (checked with `#{client_termfeatures}` in 3.5a), so the README has the reader add `terminal-features` as a step of its own. It is not in the theme file: claiming RGB for a terminal that lacks it would break that terminal.

The theme file is plain `set -g` lines the reader loads with `source-file`, so it stands alone: no plugin manager, no status line content.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `status-style` | `dim` on `deeper` | A bar, recessed like Neovim's `StatusLine` |
| `status-left-style` | `text` on `deeper` | The session name is content |
| `status-right-style` | `dim` on `deeper` | |
| `window-status-style`, `window-status-last-style` | `dim` on `deeper` | |
| `window-status-current-style` | `accent` on `base` | "You are here", as Neovim's `TabLineSel` |
| `window-status-activity-style` | `info` on `deeper` | Something happened, information. tmux's default is reverse video |
| `window-status-bell-style` | bold `warning` on `deeper` | A bell asks for attention: caution, not failure |
| `pane-border-style` | `line` | |
| `pane-active-border-style` | `accent` | Focus |
| `message-style`, `message-command-style` | `text` on `raised`, `fill` `raised` | A lifted strip. `fill` covers the whole line in tmux 3.7 and later, where the style alone no longer does |
| `mode-style` | `text` on `accent` wash | The copy mode selection, and the selected row in the choose modes. tmux 3.6 and later take `copy-mode-selection-style`, `copy-mode-position-style` and `tree-mode-selection-style` from it by default |
| `copy-mode-match-style` | `text` on `steel` wash | Every match, per Search and matches in PHILOSOPHY.md |
| `copy-mode-current-match-style` | `on_accent` on `accent` | The match at the cursor |
| `copy-mode-mark-style` | `text` on `tag` wash | The marked line is a bookmark, an annotation |
| `menu-style`, `popup-style` | `text` on `raised` | Lifted surfaces |
| `menu-selected-style` | `text` on `accent` wash | The selected row, as `mode-style` |
| `menu-border-style`, `popup-border-style` | `line` on `raised` | |
| `display-panes-colour` | `info` | The other panes' numbers |
| `display-panes-active-colour` | `accent` | The active pane's number |
| `clock-mode-colour` | `info` | tmux's default is blue, steel's slot |
| `pane-scrollbars-style` (3.6+, `-q`) | `faint` slider on `deep` | As nano's scroller. Keeps tmux's `width=1,pad=0` |
| `copy-mode-line-number-style` (3.7+, `-q`) | `faint` | Metadata, as Neovim's `LineNr` |
| `copy-mode-current-line-number-style` (3.7+, `-q`) | `accent` | As Neovim's `CursorLineNr` |
| `window-style`, `window-active-style` | not set | The panes keep the terminal's colors |
| `cursor-colour` | not set | The terminal's cursor, firelight in an Inglenook terminal |

## Gaps and trade-offs

- No pane background: setting `window-style` would paint the panes but not the programs in them, which keep the terminal's 16 colors. An Inglenook terminal gives both.
- Options newer than 3.4 (`pane-scrollbars-style`, the copy mode line number styles) use `set -gq`, so older tmux skips them quietly. tmux 3.8 adds more (`tree-mode-border-style`, `display-panes-border-style`, `tree-mode-preview-style`, the `theme` option and `theme*` colour names); they are left at tmux's defaults until a release ships them.
- In the shots the left pane starts mid-comment ("ery check."): the script is printed before the split, and tmux reflows it into the narrower pane, pushing the first lines into history. Starting the pane commands after the split (a `sleep 1` before each) fixes it; left for a retake when Docker has room.
- The screenshots cannot show: `message-style` and `message-command-style` (a message replaces the window list in tmux 3.4), menus and popups, `copy-mode-mark-style`, the bell style, `display-panes` and the clock, the scrollbars and line numbers (tmux 3.4 has neither).

## Research

- Catppuccin for tmux is a plugin (TPM or `run` of its script) that builds the status line content with modules and sets its colors through `@` variables; it needs tmux 3.2. This port takes only the idea of one sourced file and leaves content to the reader. Its README does not cover RGB.
- The tmux FAQ ("How do I use RGB colour?") gives `set -as terminal-features ",gnome*:RGB"` for 3.2 and later.
- Option names and versions come from tmux(1) at the 3.4 tag and the CHANGES file: `copy-mode-match-style`, `copy-mode-current-match-style` and `copy-mode-mark-style` arrived in 3.2, `popup-style` in 3.3, `menu-style` and `menu-border-style` in 3.4, `pane-scrollbars-style` in 3.6, the copy mode line number styles in 3.7, and `message-style` needs `fill` from 3.7. Defaults from `options-table.c` on master.
- The dist files load without errors in tmux 3.5a (Debian 13) and 3.4 (the screenshots).

## Screenshot recipe

- tmux needs no login or license (ISC: https://github.com/tmux/tmux/blob/master/COPYING).
- tmux 3.4 comes from the pinned Ubuntu snapshot, so the recipe has no `version`. Host: the GNOME Terminal port, whose `TERM` is `xterm-256color`.
- The recipe writes `~/.config/tmux/tmux.conf` with the README's steps 5 and 6.
- The scene (`build/photograph/scenes/cli/tmux/stage.sh`) builds the session with tmux commands in place of the reader's keys: the split, the copy mode selection and search, and a third window with activity monitoring on. Not tested by hand. `status-right` is fixed text instead of tmux's clock.
