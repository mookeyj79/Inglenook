# less: color mapping

For maintainers. The install guide is [README.md](README.md).

less takes a 4-bit color (one of the terminal's 16 slots, by letter) or an 8-bit color (`CSI 38;5`) for each part it draws. No 24-bit color. This port uses the 16 slots only, so the colors are exact in a terminal set to Inglenook and follow the terminal's palette elsewhere. The 256-color cube would need colors the palette does not have.

A slot letter stands for one ANSI slot (ADR 0005). Neutral slots flip between the variants (black is `text` in Day and `raised` in Night), so `values.json` names the letter per variant: `port.text`, `port.raised`, `port.faint`. The named color slots are the same letter in both.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `--use-color` | | Turns on the uppercase selectors |
| `-DP` prompt | `text` on `raised` | A status bar, lifted. Default is reverse video |
| `-DS` search results | `raised` on steel (blue) | Every match, per Search and matches in PHILOSOPHY.md: the blue slot reversed. less 590 color strings have no reverse attribute, so the text is the `raised` slot, the nearest neutral to the terminal's `base` |
| `-DE` errors and messages | `error` (red) | |
| `-DN` line numbers | `faint` (bright black) | Metadata |
| `-DM` marks in the status column | `reference` (cyan) | A mark is an anchor |
| `-DB` binary characters | `faint` | Shown as `<XX>`, not content |
| `-DC` control characters | `faint` | Shown as `^X`, not content |
| `-DR` rscroll character | `faint` | |
| `-DW` unread line (`-w`) | `text` on `raised` | Same as the prompt |
| `-Dd+` bold (man headings, options) | `info` (blue), kept bold | Keys and options are steel |
| `-Du+` underline (man arguments) | `reference` (cyan), kept underlined | Arguments name things, like paths |
| `-Ds` standout, `-Dk` blink | not set | less's defaults |
| `-DH` header, `-D1` to `-D5` subpatterns | not set | Not in less 590, the version the screenshots use, so setting them fails there |

`LESS` empty: the file starts it with `-R`. Git sets its own `LESS=FRX` only when `LESS` is unset, so without `-R` git colors would show as raw codes.

## Gaps and trade-offs

- No accent: a terminal has no amber slot, and yellow is brass, the warning color, so the search highlight is the blue (steel) slot.
- No wash: less draws a search match with a solid background slot. less has no current match, so every match looks the same.
- No background: less draws on the terminal's background.
- The `~` filler lines after the end of a file are bold, so they take the bold color.
- Windows: lowercase selectors (`d`, `u`) also recolor bold and underlined text that came in as ANSI codes with `-R` (README, Known limits).
- The prompt bar is `raised`, which sits close to `base` in Day, so the bar reads as a faint strip there and clearer in Night.
- The screenshots cannot show errors (`E`), marks (`M`), binary and control characters (`B`, `C`), rscroll (`R`) or the unread line (`W`): one still screen shows the page, a search and the prompt.

## Research

- less 590 (Ubuntu 24.04, Linux Mint 22.3) and 668 (Debian 13) both read `-D` in `LESS` only when each one ends with `$`. Without it, the first `-D` takes the rest of the variable as its color and less stops with "Invalid color string".
- [Dracula for man pages](https://github.com/dracula/man-pages): colors man pages through `LESS_TERMCAP_*` termcap overrides, the method before `--use-color`. Not used: `-Dd` and `-Du` do the same with less's own option, and the termcap way needs raw escape codes.
- Catppuccin, Nord and Gruvbox ship no less port; their terminal ports cover it through the 16 slots, the same method as here.

## Screenshot recipe

- less needs no login or license (GPLv3 or the Less License: https://www.greenwoodsoftware.com/less/).
- Host: GNOME Terminal, the Inglenook port, so the 16 slots are Inglenook's.
- The scene page is staged as a man page would hand it to less, bold and underline made by overstriking, so the shot needs no man pages in the image.
- `exec bash -ic` in the staged command stands in for opening a new terminal, so `~/.bashrc` loads the file: not tested by hand.
