# GNU Screen: color mapping

For maintainers. The install guide is [README.md](README.md).

Screen 4 takes colors in a `%{...}` attribute/color modifier inside `hardstatus`, `caption` and the other strings, and as the color argument of `sorendition`. A color is one of the terminal's 8 slots by letter (`k r g y b m c w`), its bright version as a capital, `d` for the terminal's default, or `.` for unchanged. Two letters are background then foreground (`%{= BW}` is bright white on blue). No 24-bit color and no 256-color index by name in Screen 4 (`screen.1` from 4.9.1, section STRING ESCAPES). This port uses the 16 slots only, like less and nano, so the colors are exact in a terminal set to Inglenook and follow the terminal's palette elsewhere.

Neutral slots flip between the variants (black is `text` in Day and `raised` in Night), so `values.json` names the letter per variant: `port.text`, `port.raised`, `port.faint`.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `hardstatus alwayslastline` bar | `text` on `raised` | A bar, lifted, as nano's title bar |
| current window in the bar | bold `raised` on `text` | "You are here" with no amber slot: a solid reverse block, as nano's selection |
| session name (`%S`) | `faint` on `raised` | Metadata |
| `caption`, focused region (`%F`) | `raised` on `text` | "You are here", the same block |
| `caption`, other regions | `faint` on `raised` | Quiet, so the focused one stands out |
| `sorendition` | `raised` on `text`, no attributes | Messages, input prompts, the window list's cursor line and copy-mode marks. Screen's default is reverse video; this is the same block in the theme's neutrals |
| `rendition bell`, `monitor`, `silence` | not set | Screen's defaults (bold, underline) in the bar's own colors. `rendition` needs Screen 4.2; leaving it out keeps the file working in macOS's Screen 4.0.3 |

## Gaps and trade-offs

- No accent: the terminal has no amber slot, so the current window, the focused caption and the `sorendition` block are neutral reverse blocks. The terminal's own cursor stays firelight.
- No match color: copy-mode search (`/`, `?`) only moves the cursor. Nothing to map to ADR 0009.
- No background: Screen draws on the terminal's background, and the programs inside it keep their own colors.
- Night `line` and `hover` have no slot; `raised` (black) stands in for the bar.
- Screen 5 (released 2024, now in Homebrew, Alpine and FreeBSD) parses colors differently: `fg;bg` numbers 0 to 255 or `#rrggbb` truecolor, attributes `d u b r i l`, no letters and no `=` change type (`ParseAttrColor` in screen-5.0.1 `process.c`; its manual still documents letters as deprecated, but the parser reports them as junk). The two syntaxes cannot share a file. A Screen 5 file could use exact palette colors with `truecolor on`, but the Photographer's Mint 22.3 image has Screen 4.9.1 only, so it is not shipped.
- The screenshots cannot show a message line (it times out) or copy-mode marks. They show the status line, both kinds of caption, and the window list's cursor line, which is the `sorendition` block.

## Research

- No Catppuccin, Nord, Dracula, Gruvbox or Rose Pine port for Screen was found. Personal screenrc files and the ArchWiki page set the same `hardstatus`, `caption` and `sorendition` lines; nothing to learn beyond the manual. One write-up (pingle.org, 2026) confirms the 4 to 5 color syntax break.
- `rendition` arrived in Screen 4.2.0 and `sorendition` is deprecated in its favour, but `sorendition` still works in 4.9.1 and exists in 4.0.3, so the port uses it (Screen 4.9.1 `changelog`).
- The dist files load without errors in Screen 4.9.1 (Debian 13), checked through a pseudo terminal: the bar draws `30;107` and `97;40` in Day.

## Screenshot recipe

- Screen needs no login or license (GPLv3: https://www.gnu.org/software/screen/).
- Host: GNOME Terminal, the Inglenook port, so the 16 slots are Inglenook's.
- The recipe saves the file as `~/.config/inglenook/screenrc` and appends the `source` line to `~/.screenrc`, the README's install steps.
- The scene starts Screen with its own `scene.screenrc`, which sources `~/.screenrc` and then opens three windows and a split. `drive.py` (shared with the nano scene) types `C-a "` to open the window list in the top region and `C-a Tab` to focus the bottom one, standing in for the reader's keys: not tested by hand.
