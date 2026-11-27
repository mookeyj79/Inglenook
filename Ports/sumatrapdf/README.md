# Inglenook for SumatraPDF

**Tier:** 3 Minimal\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

The theme colors SumatraPDF's window (toolbar, tabs, menus, bookmarks) and the pages of PDF, XPS, DjVu and PostScript documents. It is a few lines you copy into SumatraPDF's settings file.

## Before you start

- SumatraPDF 3.6 or later. Check it in **Help** > **About**. Custom themes arrived in 3.6.
- Nothing else to install.

## Install

1. Open SumatraPDF.
2. Click **Settings** > **Advanced Options...**. `SumatraPDF-settings.txt` opens in your text editor.
3. Open the Inglenook file for your variant from this repo (see Files to use below) in a second editor window.
4. In `SumatraPDF-settings.txt`, find the line that starts with `Theme =`. Replace it with the `Theme = ...` line from the Inglenook file.
5. Find the block that starts with `Themes [`, usually near the end of the file and empty. Replace the whole block, down to its closing `]`, with the `Themes [ ... ]` block from the Inglenook file. If you already have themes of your own there, paste only the inner `[ ... ]` entry next to them.
6. Find the block that starts with `FixedPageUI [`. Inside it, replace the `TextColor`, `BackgroundColor` and `SelectionColor` lines with the three lines from the Inglenook file. Leave the other lines in the block as they are.
7. Save `SumatraPDF-settings.txt`. SumatraPDF applies the change right away.

Files to use:

- Inglenook Day: `dist/day/sumatrapdf-day.txt`
- Inglenook Night: `dist/night/sumatrapdf-night.txt`

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). If it is not installed yet, follow [Font](../../README.md#font) in the main README. SumatraPDF can set the font of the bookmarks and favorites list only. Menus use the Windows font, and documents use their own fonts.

1. Open `SumatraPDF-settings.txt` (Install step 2).
2. Find the line `TreeFontName = automatic` and change it to `TreeFontName = IBM Plex Mono`.
3. Save the file.

## Check that it worked

Click **Settings** > **Theme**: Inglenook Day or Inglenook Night has a check mark. Open a PDF: the page is a soft off-white (Day) or a warm dark brown (Night) instead of white, and the text matches it.

## Switch between Day and Night

1. Open `SumatraPDF-settings.txt` (Install step 2).
2. Repeat Install steps 4 to 6 with the other variant's file.
3. Save.

SumatraPDF does not follow the Windows light or dark setting.

## Uninstall

1. Open `SumatraPDF-settings.txt` (Install step 2).
2. Change the `Theme =` line to `Theme = Light`.
3. In the `Themes [` block, delete the Inglenook entry, from its `[` to its `]`.
4. In the `FixedPageUI [` block, delete the `TextColor`, `BackgroundColor` and `SelectionColor` lines. SumatraPDF puts its own defaults back.
5. Save.

## Troubleshooting

- **Nothing changed after saving**: check that the name after `Theme =` matches the `Name =` line in the `Themes` block exactly. If SumatraPDF does not know the name, it goes back to the Light theme.
- **Everything after the theme vanished from the settings file**: a `[` or `]` is missing. Square brackets always come in pairs. Copy the block from the Inglenook file again.
- **Pages are still white**: the three lines from step 6 must be inside the `FixedPageUI [` block, not at the top level of the file.

## Known limits

- **Pictures in documents are recolored too.** SumatraPDF swaps black for the text color and white for the page color across the whole page, so photos and colored text take on the theme's tint.
- **Invert Colors** (**Shift+I**) swaps the two page colors: Night shows light pages with dark text, Day shows dark pages with light text. Press **Shift+I** again to go back.
- **Selected text and found text** use one color, which SumatraPDF draws see-through over the page.
- **Disabled text, hover shades, inactive tabs and pop-up notices** are worked out by SumatraPDF from the theme's main colors, so they are close to the theme but not exact.
- **Comic books and image files** show on black, as SumatraPDF always does.
- **Annotation colors** are not changed. They are saved into the document, so they stay part of the file.

## Sources

- [Customize theme (colors)](https://www.sumatrapdfreader.org/docs/Customize-theme-colors)
- [Advanced settings reference for 3.6](https://www.sumatrapdfreader.org/settings/settings3-6): `Theme`, `Themes`, `FixedPageUI` and `TreeFontName`
- [Version history](https://www.sumatrapdfreader.org/docs/Version-history): custom themes added in 3.6
