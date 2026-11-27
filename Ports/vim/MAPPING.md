# Vim: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

The file in `template/colors/` (built as `colors/inglenook.vim`) is the same in both variants: it picks `autoload/inglenook/day.vim` or `night.vim` from `'background'`, falls back to the one that is installed, then clears the highlights and calls the variant's `load()`. The file in `template/autoload/` holds the groups. It follows the Neovim port group by group, for every group Vim has. Every group Vim's default colors give a color is set (the list came from `:highlight` in a clean Vim 9.1 with `-u NONE`), so none of Vim's colors show through.

Each group gets `guifg`, `guibg` and `guisp` (gVim, and a terminal with `'termguicolors'`) and `ctermfg`, `ctermbg` and `ctermul` (a terminal without it). In a terminal Vim takes the attributes (bold, reverse) from `cterm=` even with `'termguicolors'` on, and the 16-color fallback needs reverse video where the 24-bit colors must not have it, so `load()` checks `'termguicolors'` and `has('gui_running')` and writes the 24-bit attributes or the 16-color ones. Changing `'termguicolors'` afterwards needs `:colorscheme inglenook` again (README, Troubleshooting).

| App setting | Color | Why |
|---|---|---|
| `Normal` | `text` on `base` | Set first, as `:h :hi-normal-cterm` asks |
| `Pmenu`, `MessageWindow`, `PopupNotification` | `text` on `raised` | Popups are lifted surfaces |
| `StatusLine`, `TabLine`, `TabLineFill`, `TabPanel*`, `ToolbarLine` | `deeper` | Bars, like title and activity bars |
| `StatusLineNC` | `faint` on `deeper` | |
| `TabLineSel`, `TabPanelSel` | `accent` on `base` | The current tab is "you are here" |
| `Folded`, `ColorColumn` | `deep` | Recessed |
| `CursorLine`, `CursorColumn` | `raised` | As in the Neovim port: a wash would clash with `Visual` |
| `PmenuSel`, `QuickFixLine`, `ToolbarButton` | `hover` | Active rows |
| `VertSplit`, `NonText`, `EndOfBuffer`, `PmenuThumb` | `line` | |
| `LineNr`, `SignColumn`, `FoldColumn`, `Conceal`, `SpecialKey` | `faint` | Metadata |
| `CursorLineNr` | `accent`, bold | "You are here" |
| `Cursor`, `lCursor` | `accent` fill, `on_accent` text | gVim; a terminal draws its own cursor |
| `CurSearch`, `IncSearch`, `PmenuMatchSel` | `accent` fill, `on_accent` text | The match at the cursor, per Search and matches in PHILOSOPHY.md |
| `Visual` | `accent` wash | Selection |
| `Search` | `steel` wash, `text` on it | Every other match |
| `PmenuMatch` | `steel`, bold, on `raised` | A text-only match |
| `MatchParen` | `accent`, bold | |
| `Directory`, `Special`, `Underlined` | `reference` | Paths and references |
| `Title` | `info`, bold | As in the Neovim port |
| `ModeMsg` | `text`, bold | |
| `ErrorMsg`, `WarningMsg`, `MoreMsg`, `Question` | `error`, `warning`, `info`, `info` | |
| Syntax groups (`Comment` to `Todo`) | as in the Neovim port | PHILOSOPHY.md syntax mapping; `Identifier` is `text` |
| `Added`, `Changed`, `Removed` | `success`, `warning`, `error` | |
| `DiffAdd`, `DiffChange`, `DiffDelete` | `moss`, `brass`, `ember` washes | `DiffDelete` filler in `error` |
| `DiffText`, `DiffTextAdd` | the line's wash, bold, underline in its color | |
| `Spell*` | undercurl in `error`, `warning`, `info`, `info` | |
| `Terminal` | `text` on `base` | `:terminal` windows |
| `g:terminal_ansi_colors` | `ansi.*` | `:terminal`, set only with 24-bit color, as `:h g:terminal_ansi_colors` describes |
| `CursorIM`, `VisualNOS`, `CursorLineSign`, `CursorLineFold`, `StatusLineTerm*`, `WildMenu`, `PopupSelected` | links | Cleared first, so no default attribute stays |

### Without `'termguicolors'`

The cterm values are terminal slot numbers, so they are exact in a terminal set to Inglenook (the GNOME Terminal and Windows Terminal ports) and follow the terminal's palette elsewhere, like the nano and less ports. `values.json` holds the neutral slots, which flip between the variants (`port.raised`, `port.line`, `port.dim`).

| Name | Slot |
|---|---|
| `text`, `base` | `NONE`: the terminal's own text and background |
| `raised`, `deep`, `deeper`, `hover` | bright white (15) in Day, black (0) in Night: `raised` |
| `line` | white (7) in Day, bright black (8) in Night (Night `line` has no slot) |
| `faint` | bright black (8) |
| `dim` | white (7) in Night, bright black (8) in Day (Day `dim` has no slot) |
| `error`, `success`, `warning`, `info`, `keyword`, `reference` | 1, 2, 3, 4, 5, 6 |
| `literal` (clay), `type` (dusk), `tag` (rosewood) | 9, 12, 13: the bright slot of the nearest hue, so they stay apart from the role colors |
| `accent`, washes | no slot |

With no amber slot and no washes: `Visual` and `Cursor` are reverse video, `Search` is the blue slot reversed and `CurSearch` the same in bold (Search and matches: 16-color tools), `MatchParen` is bold underline, the `Pmenu*Sel` rows are reversed, and the diff lines color their text (green, yellow, red) instead of a wash.

## Gaps and trade-offs

- Neovim-only groups (floats, diagnostics, LSP, Tree-sitter captures) do not exist in Vim. Plugins that bring their own (ALE, vim-lsp, coc.nvim) usually link to `ErrorMsg`, `WarningMsg` or `Spell*`, which are set.
- `TabPanel*`, `PmenuMatch*` and `DiffTextAdd` came during Vim 9.1 (listed under 9.2 in `:h version9.txt`), and `Added`, `Changed`, `Removed` are recent too. An older Vim just creates the group, unused.
- The 16-color fallback is approximate (above): clay, dusk and rosewood borrow a bright slot, and Day `dim` and Night `line` share bright black.
- The screenshots show `Normal`, the syntax colors, `Comment`, `Todo`, `Folded` (diff mode folds the unchanged lines), every `Diff*` group, `Search`, `Visual`, `CursorLineNr`, `LineNr`, `VertSplit`, `StatusLine`, `StatusLineNC` and `ModeMsg`. They cannot show: `Pmenu`, `CurSearch` (the cursor is in the selection), `TabLine`, the `:terminal` colors, spelling, `reference` and `tag` (the PowerShell file has no path or attribute), and the 16-color fallback. `Error` shows nowhere: Vim has no diagnostics, so the scene's misspelled call is plain text.

## Research

- Vim's own help: `:h :colorscheme`, `:h highlight-groups`, `:h highlight-args`, `:h 'background'` (a loaded colorscheme is reloaded when `'background'` changes; `t_RB` asks the terminal for its background), `:h 'termguicolors'`, `:h g:terminal_ansi_colors`.
- Vim's bundled schemes (`retrobox`, `habamax`, from vim/colorschemes, made with Colortemplate): `hi clear`, set `g:colors_name`, branch on `&background`, then write `gui*` and `cterm*` for each group, with `g:terminal_ansi_colors` set only under `'termguicolors'` or the GUI. That is the method here.
- Dracula (dracula/vim): `colors/dracula.vim` with the palette in `autoload/dracula.vim`, which is where the autoload split comes from. Gruvbox (morhetz/gruvbox): one file for light and dark, chosen by `&background`, as here. Catppuccin (catppuccin/vim): one Colortemplate-built file per flavor, so no shared light and dark logic.
- The dist files load without errors in Vim 9.1.1230 with `-u NONE`, in both variants, with and without `'termguicolors'`, and with only one variant installed.

## Screenshot recipe

- Vim is charityware under the Vim license and needs no login or license (https://www.vim.org/about.php).
- Vim runs inside the GNOME Terminal port (`host`), so the shots show an Inglenook terminal around it.
- The recipe writes `~/.vimrc` with the README's lines and `set background` per variant, as the README's "always start in one variant" step does. Not tested by hand.
- The scene (`build/photograph/scenes/editor/vim/`) opens the working file against its committed copy in diff mode, highlights every match of `Get-Luminance` as after a search, and selects two lines, like the Neovim scene.
