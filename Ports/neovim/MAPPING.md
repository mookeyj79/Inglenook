# Neovim: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

The file in `template/colors/` (built as `colors/inglenook.lua`) is the same in both variants: it picks `lua/inglenook/day.lua` or `night.lua` from `'background'`, falls back to the one that is installed, then clears the highlights and loads the variant. The file in `template/lua/` (built as `lua/inglenook/day.lua` or `night.lua`) holds the groups. Every group Neovim's own default colorscheme gives a color is set, so none of Neovim's colors show through.

| App setting | Color | Why |
|---|---|---|
| `Normal` | `text` on `base` | |
| `NormalFloat`, `Pmenu`, `FloatBorder` | `raised`, border `line` | Popups are lifted surfaces |
| `StatusLine`, `TabLine`, `TabLineFill`, `MsgSeparator` | `deeper` | Bars, like title and activity bars |
| `StatusLineNC` | `faint` on `deeper` | |
| `TabLineSel` | `accent` on `base` | The current tab is "you are here" |
| `Folded`, `ColorColumn` | `deep` | Recessed |
| `CursorLine`, `CursorColumn` | `raised` | A cursor line is lifted; a wash would clash with `Visual` |
| `PmenuSel`, `QuickFixLine`, `LspReference*` | `hover` | Active rows |
| `WinSeparator`, `NonText`, `Whitespace`, `EndOfBuffer`, `PmenuThumb` | `line` | |
| `LineNr`, `SignColumn`, `FoldColumn`, `Conceal`, `LspInlayHint`, `ComplHint` | `faint` | Metadata |
| `CursorLineNr` | `accent` | "You are here" |
| `Cursor`, `lCursor`, `TermCursor`, `CurSearch` | `accent` fill, `on_accent` text | |
| `Visual`, `SnippetTabstop` | `accent` wash | Selection |
| `Search` | `steel` wash | Find matches use a wash; `info` is the closest meaning, and firelight is taken by the selection |
| `MatchParen`, `LspSignatureActiveParameter` | `accent`, bold | |
| `Directory`, `Special`, `Underlined`, `@module`, `@label`, `@string.special.path`, `@markup.link*` | `reference` | Paths and references |
| `Title` | `info`, bold | Headings sit with keys, the closest row |
| `ModeMsg` | `text`, bold | |
| `ErrorMsg`, `WarningMsg`, `MoreMsg`, `Question`, `OkMsg` | `error`, `warning`, `info`, `info`, `success` | |
| `Comment` | `faint`, italic | |
| `String`, `Character` | `success` (moss) | |
| `Number`, `Float`, `SpecialChar`, `@string.escape`, `@string.regexp`, `@string.special`, `@markup.raw` | `literal` | |
| `Constant`, `Boolean`, `Statement`, `Keyword`, `Conditional`, `Repeat`, `Label`, `Exception`, `PreProc`, `Include`, `Define`, `PreCondit`, `StorageClass`, `@variable.builtin` | `keyword` | |
| `Function`, `@property`, `@variable.member`, `@tag.attribute`, `@function.builtin` | `info` (steel) | Keys, properties, functions |
| `Identifier`, `@variable`, `@variable.parameter` | `text` | Variables are content; the syntax table has no row for them |
| `Type`, `Structure`, `Typedef`, `@type.*`, `@constructor` | `type` | |
| `Tag`, `Macro`, `Debug`, `@attribute`, `@function.macro`, `@constant.macro` | `tag` | Tags, annotations, decorators |
| `Delimiter`, `Operator`, `@punctuation*`, `@operator`, `@markup.list` | `dim` | Punctuation |
| `Error` | `error` | Text only, no fill |
| `Todo` | `warning`, bold | |
| `Added`, `Changed`, `Removed` | `success`, `warning`, `error` | Git marks |
| `DiffAdd`, `DiffChange`, `DiffDelete` | `moss`, `brass`, `ember` washes | `DiffDelete` filler in `error` |
| `DiffText`, `DiffTextAdd` | the line's wash, bold, underline in its color | No second wash strength exists |
| `DiagnosticError`, `Warn`, `Info`, `Ok` | `error`, `warning`, `info`, `success` | Signs, virtual text and floats link to these |
| `DiagnosticHint` | `dim` | A hint is supporting text; no role means "hint" |
| `DiagnosticUnderline*`, `Spell*` | undercurl in the same colors | `SpellLocal` and `SpellRare` use `info` |
| `DiagnosticUnnecessary`, `DiagnosticDeprecated` | `faint` | |
| `FloatShadow`, `FloatShadowThrough` | `deeper`, no blend | Solid surfaces only |
| `vim.g.terminal_color_0` to `15` | `ansi.*` | `:terminal` |
| `@markup.heading.1/2.delimiter.vimdoc` | `base` text on `base`, line in `line` | Help-file rules, drawn as an underline |
| `NvimInternalError`, `RedrawDebug*` | `error`; washes | Neovim's own debugging groups |

## Gaps and trade-offs

- No `cterm` colors: the port needs `'termguicolors'`, which Neovim 0.10 and later turns on by itself in a 24-bit terminal. A 256-color fallback would be approximate and is left to Neovim's defaults.
- Plugin groups are not themed one by one. Most plugins link to the standard groups set here.
- The screenshots cannot show: `NormalFloat` and `Pmenu` (in the host's 110 columns a float would cover the diff), `Search` and `CurSearch`, `TabLine`, the `:terminal` colors, spelling, `reference` and `tag` (the PowerShell file has no path or attribute), and Tree-sitter captures (PowerShell has no bundled parser, so the scene uses Neovim's regex syntax). The spec in the PR covers them.

## Research

- Catppuccin (catppuccin/nvim), Tokyo Night (folke/tokyonight.nvim) and Rosé Pine (rose-pine/neovim): one `colors/<name>.lua` that sets `g:colors_name`, clears highlights, and sets groups with `nvim_set_hl`; Tree-sitter and LSP groups mostly link back to the legacy groups. Tokyo Night and Rosé Pine pick light or dark from `'background'` in the same colorscheme, which is the method used here.
- Dracula and Nord (vim): one `.vim` file per scheme; Nord sets `g:terminal_color_*` for `:terminal`.
- Neovim reloads the current colorscheme when `'background'` changes (`:h g:colors_name`), so `:set background=dark` switches variants live.
- The group list came from `nvim_get_hl()` in a clean Neovim 0.12.6: every group with its own color was set.

## Screenshot recipe

- Neovim is free software (Apache 2.0 and Vim license) and needs no login or license.
- Neovim runs inside the GNOME Terminal port (`host`), so the shots show an Inglenook terminal around it.
- The recipe sets `background` in `init.lua` per variant, as the README's "always start in one variant" step does, because the scene's terminal is not queried in a fixed way. Not tested by hand.
- The scene (`build/photograph/scenes/editor/neovim-scene/`) opens the working file against its committed copy in diff mode, sets one error diagnostic (sign, undercurl and virtual text), and selects two lines. The diagnostic stands in for a language server.
