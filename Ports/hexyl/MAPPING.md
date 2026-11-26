# hexyl: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `HEXYL_COLOR_OFFSET` | faint | The offset column is metadata, like line numbers. hexyl's own default is bright black |
| `HEXYL_COLOR_NULL` | faint | Null bytes are empty space, like a placeholder |
| `HEXYL_COLOR_ASCII_PRINTABLE` | success (moss) | Printable text reads as a string |
| `HEXYL_COLOR_ASCII_WHITESPACE` | dim | Whitespace is closest to punctuation |
| `HEXYL_COLOR_ASCII_OTHER` | literal (clay) | Control bytes are like escapes and literals |
| `HEXYL_COLOR_NONASCII` | keyword (heather) | A hue apart from the others, so binary data stands out. Brass, hexyl's default yellow, would read as a warning |

## Gaps and trade-offs

- Tier 2: hexyl colors only these six slots. Background, border lines and the `--help` colors come from the terminal (the help uses fixed ANSI green and cyan, so a themed terminal decides them).
- `--color-scheme gradient` is hardcoded RGB in hexyl's `src/colors.rs` and cannot be themed.
- No light or dark detection: the user picks a variant file.
- The shots are taken in GNOME Terminal with its stock Adwaita colors, because the GNOME Terminal port (#6) does not exist yet. Background and border lines are therefore not Inglenook. When that port lands, make it this recipe's `host` and drop `launch` and `window`.
- The text column draws whitespace as a dot or a blank, so dim shows only in the hex columns.

## Research

- No other theme ports hexyl (Catppuccin, Nord, Dracula, Gruvbox, Rose Pine have none, as of 2026-11-26).
- hexyl 0.17.0 `src/colors.rs`: each `HEXYL_COLOR_*` is parsed by owo-colors `DynColors::from_str`, which takes the eight ANSI names, `bright <name>`, and `#rrggbb`. An unparsable value falls back to the default. `src/lib.rs`: the border is written with no color.

## Screenshot recipe

- hexyl needs no login or license (MIT or Apache 2.0, [license](https://github.com/sharkdp/hexyl#license)).
- hexyl 0.17.0 comes from the official release `.deb`, checked against its SHA-256, because Ubuntu ships 0.8.0.
- The scene's file is a small staged PNG (`build/photograph/scenes/cli/hexyl/stage.sh`) with every byte kind hexyl colors.
- The launch sources `hexyl.sh` directly, because the CLI scene runs a non-interactive shell that does not read `~/.bashrc`. Not tested by hand.
