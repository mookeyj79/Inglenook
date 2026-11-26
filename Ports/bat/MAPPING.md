# bat: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

bat reads three global settings of a `.tmTheme`: `foreground`, `gutterForeground` and `lineHighlight`. The others are set so the file also works in other tmTheme readers (Sublime Text, delta).

| App setting | Color | Why |
|---|---|---|
| `background` | base | bat never paints it; the terminal's background shows |
| `foreground` | text | |
| `caret` | accent | not used by bat |
| `selection` | accent wash | not used by bat |
| `lineHighlight` | accent wash | `--highlight-line`: "you are here" |
| `gutterForeground` | faint | line numbers, the grid and the header rule |
| Comments | faint | |
| Strings | success | |
| Escapes, format placeholders | literal | closest row: a literal inside a string |
| Numbers, units | literal | |
| Keywords, storage types and modifiers, word operators | keyword | |
| Booleans, language constants, constants, `this` and `self` | keyword | |
| Symbol operators | dim | punctuation |
| Punctuation | dim | |
| Functions | info | |
| Keys, properties, attributes (JSON, YAML, TOML, INI, HTML) | info | |
| Types, classes, inherited classes | type | |
| Tags | tag | |
| Annotations, decorators, attributes, preprocessor directives | tag | |
| Namespaces, modules, links, YAML anchors and aliases, paths | reference | |
| Markdown headings, sections | keyword, bold | closest row: a structural marker |
| Markdown bold, italic | font style only | |
| Code in prose | literal | |
| Quotes, list bullets, separators | dim | |
| Diff added, removed, changed | success, error, warning | |
| Diff file names | dim | |
| Diff ranges | reference | anchors in the file |
| Invalid | error | |
| Deprecated | warning | |

## Gaps and trade-offs

- bat draws the change marks (`--style=changes`) in the terminal's ANSI green, yellow and red, and the header file name bold in the terminal's foreground (`src/printer.rs`, `Colors::colored`). They are right when the terminal uses an Inglenook port, since its ANSI slots are moss, brass and ember.
- bat never paints the background: `background` only matters to other tmTheme readers.
- No italics on comments or functions, unlike most bat themes: nothing in PHILOSOPHY.md asks for them, and a font style is not a signal.
- The shots are taken in GNOME Terminal with its stock Adwaita colors, because the GNOME Terminal port (#6) does not exist yet. The background and the change marks are therefore not Inglenook. When that port lands, make it this recipe's `host` and drop `launch`, `window`, the `gnome-terminal` install and the profile line in `stage`.
- PowerShell's syntax scopes type literals such as `[string]` as `storage.type`, so in PowerShell they show as keywords, not types. Other languages scope types as `entity.name.type` or `support.type`.
- The screenshot cannot show `caret` or `selection` (bat has neither), nor the Markdown, diff, tag and decorator rules (the scene is a PowerShell file).

## Research

- Catppuccin for bat (https://github.com/catppuccin/bat): one `.tmTheme` per flavor, named after the theme, installed into `$(bat --config-dir)/themes` then `bat cache --build`. Its scope list is long and per language; this port keeps the general scopes, which bat's Sublime syntaxes share.
- Rosé Pine (https://github.com/rose-pine/tm-theme) and Tokyo Night (https://github.com/folke/tokyonight.nvim/tree/main/extras/sublime): same layout and install; both set `gutterForeground` for bat's line numbers and grid.
- bat 0.26.1 source, `src/printer.rs`: the gutter, grid and rule use `gutterForeground` (or a fixed 256-color gray without it); `--highlight-line` uses `lineHighlight`. The theme name is the file name, so the template's file name is `{{variant.name}}.tmTheme`.
- bat 0.25 added `--theme-light`, `--theme-dark` and the default `--theme=auto`, which asks the terminal for its background color.
- Checked by hand: both dist files load with `bat cache --build` (bat 0.25.0) and render with `--theme`.

## Screenshot recipe

- bat needs no login and no license (MIT or Apache 2.0).
- Shot in GNOME Terminal (stock colors until #6), in the CLI scene: `build/photograph/scenes/cli/bat/stage.sh` prints the editor scene's `Contrast.psm1` with one changed, added and removed line, and highlights line 23.
- The apply steps are the README's install steps for Linux, with the config lines appended by `printf` instead of an editor: not tested by hand.
