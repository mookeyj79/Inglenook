# SumatraPDF: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

One file per variant, `sumatrapdf-<variant>.txt`, holding the three parts of `SumatraPDF-settings.txt` the reader copies over: `Theme`, one `Themes` entry, and three `FixedPageUI` lines.

Theme entry (window chrome):

| App setting | Color | Why |
|---|---|---|
| `Name`, `Theme` | the variant name | `Theme` picks the entry by name, case-insensitive |
| `TextColor` | text | Menus, tabs, toolbar labels, bookmarks |
| `BackgroundColor` | deeper | The main window: the area around the pages and the home page. Recessed, behind the content |
| `ControlBackgroundColor` | deep | Toolbar, tab bar, menus, the bookmarks tree, dialogs. One slot for all of them, so the recessed panel neutral |
| `LinkColor` | accent | Links in the UI (home page, About). Also the progress bar in notices |
| `ColorizeControls` | `true` | Without it most Windows controls ignore the theme (docs, Tips) |

Document pages (`FixedPageUI`):

| App setting | Color | Why |
|---|---|---|
| `TextColor` | text | Replaces black on the page |
| `BackgroundColor` | base | Replaces white on the page. The page is where content lives |
| `SelectionColor` | accent | Selection and the current find match. SumatraPDF paints it at alpha 0x5f (about 37%) over the page ([`PaintTransparentRectangles`](https://github.com/sumatrapdfreader/sumatrapdf/blob/3.6.1rel/src/Selection.h#L26)), so a full firelight comes out as a firelight wash. A `{{accent\|wash}}` would be blended again and nearly vanish |

Not set: `ForwardSearch.HighlightColor` (LaTeX forward search), `Annotations.*` colors (written into the PDF, so document content, not theme), `GradientColors`, `MainWindowBackground` (only read by the built-in Light theme).

## Gaps and trade-offs

- **Tier 3.** The 3.6.1 theme entry has four colors. There is no status color at all (errors show as notices with derived colors), and nothing to map syntax or the detail colors to.
- **Derived colors.** Disabled text (`AdjustLightOrDark(text, 0x7f)`), notification background and highlight, hover, and inactive tab shades are computed by SumatraPDF from the four theme colors ([`Theme.cpp`](https://github.com/sumatrapdfreader/sumatrapdf/blob/3.6.1rel/src/Theme.cpp)). They are not palette values. The current docs list optional keys for them (`DisabledTextColor`, `HotBackgroundColor`, `EdgeColor`, notification colors, tab colors), but they are not in the 3.6 settings reference or the 3.6.1 `Theme` struct ([`Settings.h`](https://github.com/sumatrapdfreader/sumatrapdf/blob/3.6.1rel/src/Settings.h)). Revisit when a release has them, along with `DocumentColorsFollowTheme`.
- **Page recoloring is a linear map** from black/white to text/base over the whole rendered page, images included. 3.6.1 has no mode that keeps images; the current docs' `DocumentColorsFollowTheme = smart` is newer than the pin.
- **Invert Colors.** `ThemeDocumentColors` in 3.6.1: when `FixedPageUI.InvertColors` is on (Shift+I) and the page colors differ from black and white, it swaps them. With this theme that gives text-colored pages and base-colored text, light pages in Night and dark pages in Day.
- **Selection and found text share `SelectionColor`.** SumatraPDF marks only the current match, so firelight for it follows ADR 0009 (the match at the cursor). There is no "every match" mark to color steel.
- **Comic books and images** are always drawn on black (`DrawDocument`, `isImage`). Not themable.
- **Title bar.** Colored by Windows' dark or light mode, which SumatraPDF picks from whether `ControlBackgroundColor` is dark.
- **Find match outline.** SumatraPDF outlines the found text with a thin black pen at the same alpha (the `margin` path in `PaintTransparentRectangles`). Not a setting; it shows as a darker edge on the firelight wash, most visibly in Day.
- **Checked in the first run's shots (3.6.1, windows-2025):** text on the page, the bookmarks and toolbar; base as the page; deeper around the page (the find notice's own background is derived from it); deep as the toolbar, tab bar and bookmarks; the accent as the find match wash and as the find notice's progress bar (`LinkColor`). Not shown: hover, disabled text, menus.

## Research

- Ports studied: [Rosé Pine for SumatraPDF](https://github.com/rose-pine/sumatrapdf) (MIT). Method only: it ships a whole settings file per variant for 3.5 with `Theme = Light`, `UseSysColors`, `MainWindowBackground` and `FixedPageUI` colors. 3.6 custom themes replace that approach, and a whole file would overwrite the reader's own settings, so this port ships only the parts to copy. No files or colors reused. No Catppuccin port for SumatraPDF was found.
- 3.6.1 source at tag `3.6.1rel`: built-in themes are listed first, then `Themes` from the settings, and `Theme` is matched by name; an unknown name falls back to Light (`SetTheme`). `FixedPageUI` colors are used for every fixed-page document whatever the theme (`ThemeDocumentColors`). The settings file is watched and reloaded on save (`gWatchedSettingsFile` in `AppSettings.cpp`). `#` and `;` start comment lines (`SquareTreeParser.cpp`).
- Settings file location: next to the exe for the portable version (not in Program Files), else `%LOCALAPPDATA%\SumatraPDF` (`GetAppDataDirTemp` in `AppTools.cpp`). The README opens it from the menu, so the reader never needs the path.

## Screenshot recipe

- SumatraPDF is free and open source (GPLv3, [license](https://github.com/sumatrapdfreader/sumatrapdf/blob/master/COPYING)). No login or license is needed.
- `screenshot.json` shoots the document scene (`build/photograph/scenes/document/fire.pdf`, a two-page PDF written for this repo, black text on white, one bookmark per page) in the portable SumatraPDF 3.6.1 64-bit ZIP, checked against its sha256, on a hosted `windows-2025` runner. Extracted under `%LOCALAPPDATA%\Programs`, so it runs portable and reads `SumatraPDF-settings.txt` next to the exe.
- The launch opens the PDF with `-search kindling`, so the first match shows in `SelectionColor` and the find notice ("Found text at page 1") stays up (timeout 0). The bookmarks sidebar shows `ControlBackgroundColor` and `TextColor`; the area around the page shows `BackgroundColor`.
- **apply** writes the variant's file as a fresh `SumatraPDF-settings.txt`; **stage** appends update check off, no session restore, single page at fit page, the bookmarks sidebar, and a 1200x760 window. **Scripted stand-in, not tested by hand:** the README's copy and replace steps, done on a settings file SumatraPDF wrote itself.
- The font step (`TreeFontName`) is not in the recipe: the runner has BlexMono Nerd Font, not IBM Plex Mono, so the bookmarks list uses the Windows font in the shots.
