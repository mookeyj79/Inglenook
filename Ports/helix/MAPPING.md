# Helix: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

One template, `template/{{variant.slug}}.toml`, builds `inglenook-day.toml` and `inglenook-night.toml`. The scopes refer to names in the file's `[palette]` table, which the build fills from the palette, so every scope names a role or neutral, never a value. Every scope in the Helix 25.07.1 theme docs is set, directly or through a parent scope (Helix uses the longest matching key).

| App setting | Color | Why |
|---|---|---|
| `ui.background` | `text` on `base` | |
| `ui.popup`, `ui.popup.info`, `ui.menu`, `ui.help` | `text` on `raised` | Popups are lifted surfaces |
| `ui.statusline`, `ui.bufferline`, `ui.bufferline.background` | `deeper` | Bars, like Neovim's status and tab lines |
| `ui.statusline.inactive` | `faint` on `deeper` | |
| `ui.statusline.separator`, `ui.window`, `ui.background.separator`, `ui.menu.scroll` | `line` | |
| `ui.statusline.normal`, `.insert` | `dim` and `text` on `hover`, bold | Modes are labels, not states: no role means "insert" |
| `ui.statusline.select` | `text` on `accent` wash, bold | Select mode is about the selection |
| `ui.bufferline.active` | `accent` on `base`, bold | The current buffer is "you are here" |
| `ui.text.focus`, `ui.menu.selected` | `text` on `hover`, bold | Active rows |
| `ui.text.inactive`, `ui.linenr`, `ui.virtual`, `ui.virtual.inlay-hint`, `diagnostic.unnecessary` | `faint` | Metadata |
| `ui.text.directory`, `label`, `namespace`, `string.special.path`, `string.special.url`, `markup.link*` | `reference` | Paths and references |
| `ui.linenr.selected` | `accent`, bold | "You are here" |
| `ui.cursor.primary` | `accent` fill, `on_accent` text | |
| `ui.cursor` | `base` on `dim` | Other cursors: present, but not "you are here" |
| `ui.cursor.match` | `accent`, bold | Matching bracket, like Neovim's `MatchParen` |
| `ui.selection`, `ui.selection.primary`, `tabstop` | `accent` wash | Selection |
| `ui.highlight`, `ui.highlight.frameline` | `accent` wash | The line a picker preview or the debugger points at |
| `ui.cursorline.*`, `ui.cursorcolumn.*` | `raised` | Like Neovim's `CursorLine`; a wash would clash with the selection |
| `ui.virtual.ruler` | `deep` | Like Neovim's `ColorColumn` |
| `ui.virtual.whitespace`, `.indent-guide`, `.wrap` | `line` | |
| `ui.virtual.jump-label` | `reference`, bold | Labels for places to jump to; firelight would mark many places as "here" |
| `ui.picker.header` | `dim` on `raised`, bold | |
| `ui.picker.header.column.active` | `accent`, bold | The column being typed into |
| `special` | `steel`, bold | Helix draws the matched characters in pickers and completion with it: a text-only match |
| `ui.debug.breakpoint`, `ui.debug.active` | `error`, `accent` | |
| `error`, `warning`, `info`, `hint` | `error`, `warning`, `info`, `dim` | Gutter signs and messages. A hint is supporting text |
| `diagnostic.*` | undercurl in the same colors | |
| `diagnostic.deprecated` | crossed out | |
| `diff.plus`, `diff.minus`, `diff.delta` | `success`, `error`, `warning` | Gutter marks |
| `diff.delta.conflict` | `error` | |
| `comment` | `faint`, italic | |
| `string`, `constant.character` | `success` (moss) | |
| `constant.numeric`, `constant.character.escape`, `string.regexp`, `string.special`, `markup.raw` | `literal` | |
| `keyword`, `constant`, `constant.builtin`, `variable.builtin`, `type.enum.variant` | `keyword` | |
| `function`, `variable.other.member`, `markup.heading` | `info` (steel) | Keys, properties, functions; headings as in Neovim's `Title` |
| `variable`, `variable.parameter` | `text` | Variables are content |
| `type`, `constructor` | `type` | |
| `attribute`, `tag`, `function.macro`, `function.special` | `tag` | |
| `punctuation`, `operator`, `markup.list`, `markup.heading.marker` | `dim` | |
| `markup.list.checked`, `.unchecked` | `success`, `faint` | |
| `markup.quote` | `dim`, italic | |

## Gaps and trade-offs

- Search matches have no scope: Helix moves the selection to the match (`n`) or makes every match a selection (`s`), so a match shows as a selection, in the firelight wash. The steel wash for every match cannot be drawn. The steel rule does apply to picker matches (`special`).
- Every selection is the same firelight wash; the primary one is told apart by its cursor, which is the only firelight fill. There is no second wash strength to tell them apart.
- No 256-color fallback. Helix maps 24-bit colors itself when the terminal lacks them.
- `rainbow` (bracket colors, in the docs on `master` only, not in 25.07.1) is left unset: the palette has no ordered set of colors for it.
- The screenshots cannot show: popups, menus and pickers (in the host's 110 columns they would cover the code), the bufferline with a second buffer, `reference` and `tag` (the PowerShell file has no path or attribute), escapes, the debugger, inlay hints, jump labels, and markup.

## Research

- Catppuccin (catppuccin/helix): one `.toml` per flavor with a `[palette]` table at the end and scopes that refer to palette names, installed into `~/.config/helix/themes/` and picked with `theme = "..."`. That is the method used here. Catppuccin also colors the mode indicator and secondary cursors per mode; this port keeps modes neutral so roles keep their meaning.
- Helix's built-in `theme.toml` (25.07.1) and its theme docs list every scope. The docs on `master` add a `[theme]` table with `light` and `dark` (terminal mode 2031 detection); it is not in 25.07.1, so the README offers it for newer builds only.
- Helix 25.07.1 ships compiled Tree-sitter grammars and queries in its release archive, including PowerShell (airbus-cert/tree-sitter-powershell). Its PowerShell highlights use `keyword.*`, `function`, `type`, `variable.*`, `string`, `constant.numeric`, `comment`, `operator` and `punctuation.*`.
- A theme loaded with `theme = "<file name>"` logs nothing when every key is valid; an unknown name logs `failed to load theme` and keeps the default. A `theme` key under `[editor]` stops Helix with `Bad config: unknown field theme`. Both checked with 25.07.1.

## Screenshot recipe

- Helix is free software (MPL 2.0) and needs no login or license.
- Helix runs inside the GNOME Terminal port (`host`), so the shots show an Inglenook terminal around it. The release archive is pinned by version and SHA-256.
- The scene (`build/photograph/scenes/editor/helix-scene/`) adds display options to `config.toml` (bufferline, mode colors, end-of-line diagnostics), opens `Contrast.psm1` on the selection line, and presses `x` twice through a small pseudo-terminal wrapper to select two lines. The diff gutter shows the working file against the scene repo's commit.
- `diagnostic-server.py` stands in for the PowerShell language server: it answers the LSP handshake and reports one error under the misspelled call. Not tested by hand.
