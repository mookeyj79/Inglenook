# GitHub CLI: color mapping

For maintainers. The install guide is [README.md](README.md).

gh renders Markdown with [Glamour](https://github.com/charmbracelet/glamour). When `GLAMOUR_STYLE` is set, gh hands it to Glamour's `WithStylePath`: a built-in style name, or else a path to a JSON style file (go-gh `pkg/markdown/markdown.go`). The port ships that file, `gh-markdown.json`, and a shell file per shell that sets `GLAMOUR_STYLE` to its full path. The shell files are written by hand (`gh.sh`, `gh.ps1`), not from a `.env`, because the path needs `$HOME` expanded: Glamour reads the value as a file name and does not expand `~`. Same layout as the Starship port.

The structure follows Glamour's own `dark.json` (margins, prefixes, task marks), so gh looks the way its users know, in Inglenook's colors.

## Color mapping

| Glamour element | Color | Why |
|---|---|---|
| `document` | text | No background: a style background only paints behind characters, so lines would show ragged patches. The terminal's background shows through |
| `heading`, `h1` to `h6` | keyword, bold | As in the bat port: a heading is a structural marker, the closest syntax row. One color for every level; the `#` prefixes tell levels apart |
| `strong`, `emph`, `strikethrough` | font style only | As in bat and VS Code |
| `block_quote` | dim | Quotes are supporting text, as in bat |
| `hr` | dim | A separator, as in bat |
| `link_text` | accent | Links are accent (new-port skill) |
| `link` (the URL after the text) | reference, underlined | A URL is a reference |
| `image` | reference, underlined | Same as a link's URL |
| `image_text` | dim | Supporting text |
| `code` (inline) | literal on deep | Code in prose is literal, as in bat. `deep` is the surface for code in prose; inline code is a short label, so the 3:1 floor on deep applies |
| `code_block` | text | Text of a block with no language |
| `chroma.text`, `name`, `name_other` | text | |
| `chroma.keyword`, `keyword_reserved`, `keyword_namespace`, `name_constant` | keyword | |
| `chroma.keyword_type`, `name_class`, `name_exception` | type | |
| `chroma.name_function`, `name_builtin`, `name_attribute` | info | Keys, properties, functions |
| `chroma.name_tag`, `name_decorator`, `comment_preproc` | tag | Tags, annotations, decorators; a preprocessor line is the closest row |
| `chroma.literal`, `literal_number`, `literal_date`, `literal_string_escape` | literal | |
| `chroma.literal_string` | success | Strings are moss |
| `chroma.operator`, `punctuation` | dim | |
| `chroma.comment` | faint | |
| `chroma.error`, `generic_deleted` | error | |
| `chroma.generic_inserted` | success | |
| `chroma.generic_subheading` | info | Diff ranges, as in VS Code |
| `chroma.generic_emph`, `generic_strong` | font style only | |
| `chroma.background` | not set | Running code goes on base, which is the terminal's background |
| `item`, `enumeration`, `task`, `table` | not set | Their marks are printed in the surrounding text's style |

## Gaps and trade-offs

- Code blocks with a language go through Chroma's `terminal256` formatter, which Glamour hardcodes (`ansi/codeblock.go`) and gh does not change. Every token color is rounded to the nearest xterm 256 color, so they are approximate. Most stay close, but moss strings in Day land on a gray (`238`/`239`). A style file cannot pick the formatter. The alternative is to drop the `chroma` section: blocks would then be plain `text` in exact color, with no highlighting. Highlighting is kept (the owner's decision, 2026-11-26), accepting the rounding as Catppuccin's and Glamour's own Dracula and Tokyo Night styles do.
- gh's own lines are outside the style: the repository name (bold), the description, issue and PR headers, and "View this repository on GitHub", which gh draws in 256-color gray `242`. Lists such as `gh issue list` use the terminal's 16 colors.
- Label chips in `gh issue view` use the label's color from GitHub (with `GH_COLOR_LABELS`).
- Bullets, list numbers, task marks and table borders are prefixes Glamour prints in the parent's style, so they cannot take `dim` without the item text taking it too.
- `GLAMOUR_STYLE` is not gh-only: other Glamour apps that read it get the same style.
- With `GLAMOUR_STYLE` set, gh stops picking its light or dark style from the terminal background, and `accessible_colors` no longer applies to Markdown.
- The screenshots cannot show `hr`, images, `h2` to `h6` (same color as `h1`), errors, types, attributes and diff tokens: the scene is one README that fits a 30-row terminal.

## Research

- Catppuccin for Glamour (https://github.com/catppuccin/glamour): one JSON per flavor, structure copied from Glamour's `dark.json` with colors swapped, rainbow headings (one hue per level), `code` with a background, chroma colors for every token. Installed by pointing `GLAMOUR_STYLE` at the file. Inglenook takes the same method; headings stay one color, per the bat port.
- gh 2.106.0 uses `charm.land/glamour/v2` through go-gh `pkg/markdown`. Older gh (2.45, Ubuntu 24.04) uses Glamour 0.6, which reads the same keys.
- Glamour style keys: `ansi/style.go` and `styles/README.md`. Colors are `#rrggbb` strings or 256-color numbers.

## Screenshot recipe

- gh is MIT licensed and installs without a login, but every command that renders Markdown fetches from GitHub, which needs a token. The scene never logs in: gh's own `http_unix_socket` setting (`gh config`) sends its requests to `build/photograph/scenes/cli/gh/server.py`, which answers `gh repo view` with a fixed repository and README. `GH_TOKEN` is a stand-in string the server never checks. So this is a normal recipe, not a manual one.
- gh 2.106.0 is the official `.deb` from the GitHub release, checked against the release's `gh_2.106.0_checksums.txt`.
- Host: GNOME Terminal, the Inglenook port.
- `exec bash -ic` in the staged command stands in for opening a new terminal, so `~/.bashrc` loads `gh.sh`: not tested by hand.
- The PowerShell file and Windows are not shot.
