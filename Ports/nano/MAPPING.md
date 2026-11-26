# nano: color mapping

For maintainers. The install guide is [README.md](README.md).

nano takes one of the terminal's 16 slots by name (`red`, `lightred`, `black`, ...), `normal` for the terminal's default, or a three-digit `#rgb` that nano 6.0 and later snap to the 6x6x6 cube of the 256-color palette (`closest_index_color` in nano's `src/rcfile.c`: each digit maps to a cube level, never to the gray ramp). No 24-bit color. This port uses the 16 slots only, like less, so the colors are exact in a terminal set to Inglenook and follow the terminal's palette elsewhere.

The cube was tried and dropped: every Night surface lands on pure black or a dark red or blue, Day `base` and `raised` on pure white, Day `text` on a teal, and Day moss and brass, and Day firelight and clay, share one cube color each.

Neutral slots flip between the variants (black is `text` in Day and `raised` in Night), so `values.json` names the slot per variant: `port.text`, `port.raised`, `port.faint`, in nano's spelling (`lightwhite`, `lightblack`). The named color slots are the same name in both.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `titlecolor` | `text` on `raised` | A bar, lifted. Default is reverse video |
| `promptcolor` | `text` on `raised` | Same as the title bar, as nano does when unset |
| `minicolor` | `text` on `raised` | Same as the title bar, as nano does when unset |
| `statuscolor` | `text` on `raised` | |
| `errorcolor` | bold `raised` on `error` (red) | Failure. nano's default is bold white on red |
| `keycolor` | bold `info` (blue) | Keys are steel, as in less |
| `functioncolor` | `text` | The descriptions next to the keys |
| `numbercolor` | `faint` (bright black) | Metadata |
| `selectedcolor` | `raised` on `text` | A solid reverse block; see Gaps |
| `spotlightcolor` | `raised` on steel (blue) | The found match, per Search and matches in PHILOSOPHY.md: the blue slot reversed, as in less. nano has no reverse attribute, so the text is the `raised` slot |
| `stripecolor` | background `raised` | A quiet guide column |
| `scrollercolor` | `faint` | nano draws the thumb in reverse video, so the foreground is the thumb |
| syntax `color` lines | not set | nano's own syntax files, in the terminal's slots |

## Gaps and trade-offs

- No accent: the terminal has no amber slot. The selection is a neutral reverse block instead of a firelight wash, and the search match uses the blue (steel) slot, as in less: yellow is brass, the warning color. The terminal's own cursor stays firelight.
- No background: nano draws on the terminal's background.
- Syntax: interface colors and syntax are separate in nano. Recoloring syntax means shipping a syntax file per language (nano's own are GPL and pick their colors per file), so syntax keeps nano's colors. They are terminal slot names, so they are palette colors in an Inglenook terminal, but not by role: the sh syntax, for example, colors comments cyan rather than faint.
- Night `on_accent` is `deeper`, and Night `line` and `hover` have no slot: the closest slot, `raised` (black), stands in where a bar or block needs one.
- The screenshots cannot show `errorcolor`, `promptcolor`, `minicolor` or `spotlightcolor`: one still screen shows the title bar, line numbers, the guide stripe, the scroll indicator, a selection, the status bar and the help lines. nano drops a search spotlight after 1.5 seconds (nano 5.8 NEWS), so it cannot be held for a still.

## Research

- Hyaline research #48 found no nano port among Catppuccin, Nord, Dracula, Gruvbox and Rose Pine. A search of GitHub found only small personal nanorc themes, which set the same `set ...color` lines; nothing to learn beyond the manual.
- nano 5.8 is the oldest release with every option used here: `light` prefix (5.0), `promptcolor` (5.5), `spotlightcolor` (5.6.1, renamed from `highlightcolor`), `minicolor` (5.8), per nano's NEWS.
- `include` files may hold only syntax commands, so the theme cannot be a drop-in file; it is lines for the reader's own nanorc.
- The dist files load without errors in nano 8.4 (Debian 13) and 7.2 (the screenshots).

## Screenshot recipe

- nano needs no login or license (GPLv3: https://www.nano-editor.org/).
- Host: GNOME Terminal, the Inglenook port, so the 16 slots are Inglenook's.
- The recipe saves the file as `~/.config/nano/nanorc`, the README's step 2 for a reader with no nanorc.
- `drive.py` types `^6` and three `^N` into nano through a pseudo terminal to make the selection, standing in for the reader's keys: not tested by hand.
