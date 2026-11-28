# Mod Organizer 2: color mapping

For maintainers. The install guide is [README.md](README.md).

## Layout

- **Frame** (`deeper`): menu bar, tool bar, status bar, inactive tabs, the log's title bar.
- **Recessed** (`deep`): the window behind the panes, tab panes, headers, scroll bar tracks.
- **Content** (`base`): the mod list, plugin list, archive, data, saves and downloads lists, text browsers.
- **Raised** (`raised`): menus, tooltips and save game tooltips, inputs, buttons, alternate list rows, check box fills.
- **Hover** (`hover`): hovered rows, menu items, buttons, tool buttons, tabs, header sections.

Each variant is one `.qss` file with a folder beside it for its check mark. The first line, `/* mo2-base-style: Fusion */`, tells Mod Organizer 2 to draw everything the sheet leaves alone (tree arrows, combo box arrows, sort arrows) with Qt's Fusion style.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `QWidget` background, `QMainWindow`, `QDialog`, tab pane, headers, scroll bar track | `deep` |  |
| `QMenuBar`, `QToolBar`, `QStatusBar`, inactive `QTabBar::tab`, `QDockWidget::title` | `deeper` |  |
| `QAbstractItemView` background, `QTextBrowser` | `base` |  |
| `alternate-background-color` | `raised` | A lifted stripe on alternate rows of the long mod list |
| `QMenu`, `QToolTip`, `SaveGameInfoWidget`, inputs, `QPushButton`, check box fills | `raised` |  |
| `::item:hover`, `QMenu::item:selected`, button and tab hover, header hover | `hover` | Menu highlight is a hover, as in the VS Code port |
| Borders, `QMenu::separator`, `QToolBar::separator`, scroll bar handle | `line` |  |
| Header text, inactive tab text, group box titles, status bar text, check box border | `dim` |  |
| Disabled text, scroll bar handle hover | `faint` |  |
| Text everywhere | `text` |  |
| Selection (`::item:selected`, `selection-background-color`) | `accent` wash, `text` on it | Selection is a firelight wash |
| Focus borders, open tab underline, splitter hover, scroll bar handle pressed, link color (`LinkLabel`) | `accent` |  |
| Default dialog button, the **Run** button (`#startButton`) | `accent` fill, `on_accent` text | Primary buttons |
| Checked check box and radio fill | `accent`, check mark `on_accent` | A checked box is chosen, "you are here" |
| Partly checked box | `accent` wash, `accent` border |  |
| Progress bar chunk | `accent` wash with an `accent` edge | A firelight fill would put `text` on firelight; the wash keeps the percentage readable |
| List with an active filter (`[filtered=true]`) | `warning` border | Caution: the list is not showing everything |
| Filter box that cannot be read (`[valid-filter=false]`) | `error` wash, `error` border | Failure |
| Is overwritten (loose files) | `success` wash | The selected mod wins over this one (MO2's green) |
| Is overwriting (loose files) | `error` wash | This mod takes files away from the selected one (MO2's red) |
| Is overwritten (archives) | `ivy` wash | Same meaning as loose files; a second green so loose and archive conflicts stay apart, as MO2 keeps them |
| Is overwriting (archives) | `oxblood` wash | Same, a second red |
| Mod contains selected file, Plugin is contained in selected mod | `steel` wash | A match for what is selected elsewhere, per the search rule |
| Plugin is master of selected plugin | `reference` wash | A master is a reference the selected plugin points at |

The mod list colors are not stylesheet values: MO2 keeps them in `ModOrganizer.ini` under `[Settings]` (`overwrittenLooseFilesColor`, `overwritingLooseFilesColor`, `overwrittenArchiveFilesColor`, `overwritingArchiveFilesColor`, `containsFileColor`, `containedColor`, `masterColor`), stored as Qt variants. The port ships them as `mod-list-colors.txt` for the color dialog instead of an ini patch, which would mean writing Qt's binary variant format by hand.

## Gaps and trade-offs

- Tier 2: the stylesheet reaches every Qt widget, but the mod list colors live in the app's settings, so the reader sets seven colors by hand. MO2's defaults for them are see-through (alpha 64); the README asks for alpha 255 so they stay solid washes.
- Only hover and selection set an item background. A plain `::item { background }` rule would hide the model's background role, which carries the conflict colors and the user's separator colors.
- Tree branch arrows are left to Fusion: styling `::branch` at all drops the native arrows unless images are shipped. So the selection wash does not reach into the indent of a tree row in every case; Fusion fills it from `selection-background-color`.
- The drop indicator is drawn by MO2's `ProxyStyle` in the window text color at alpha 50. The theme cannot change it.
- Separator and notes text: MO2 picks pure black or white from the user's separator color (`ColorSettings::idealTextColor`).
- Placeholder text and `QLabel` links come from the widget palette, which a stylesheet cannot set. Only MO2's own `LinkLabel` takes `qproperty-linkColor`.
- Icons (flags, tool bar, game icon, download states) are bitmaps from MO2.
- The `desktop` scene kind is the closest fit; no kind covers a desktop app window. The hand-taken shots should show the main window with a conflict highlight, the plugin list, a menu, and a dialog's default button.

## Research

- [catppuccin/mod-organizer-2](https://github.com/catppuccin/mod-organizer-2) (GPL-3.0): studied for scope only; no file or structure was reused, because this repo is MIT. Learned: one `.qss` per variant in `stylesheets/` with an asset folder beside it, URLs relative to the sheet (`./<folder>/...`), `LinkLabel { qproperty-linkColor }`, and MO2 object names (`#startButton`, `#linkButton`). It ships arrow and check SVGs per flavor and does not touch the mod list colors.
- MO2's bundled stylesheets in [`src/stylesheets`](https://github.com/ModOrganizer2/modorganizer/tree/master/src/stylesheets) and [ModOrganizer2/modorganizer-themes](https://github.com/ModOrganizer2/modorganizer-themes) (both GPL-3.0, read only): they showed MO2's dynamic properties `QAbstractItemView[filtered=true]` and `QLineEdit[valid-filter=false]`, and `SaveGameInfoWidget`, `DownloadListView`.
- MO2 source, read for behavior: [`moapplication.cpp`](https://github.com/ModOrganizer2/modorganizer/blob/master/src/moapplication.cpp) loads `<app dir>/stylesheets/<name>.qss` as `file:///`, lists every `*.qss` in the folder by base name, reads `mo2-base-style` from the leading one-line comments, and watches the file for changes. [`colortable.cpp`](https://github.com/ModOrganizer2/modorganizer/blob/master/src/colortable.cpp) and [`settings.cpp`](https://github.com/ModOrganizer2/modorganizer/blob/master/src/settings.cpp) hold the seven mod list colors and their ini keys; the color dialog shows an alpha channel. [`filterwidget.cpp`](https://github.com/ModOrganizer2/modorganizer-uibase/blob/master/src/filterwidget.cpp) sets the two filter properties.
- The [Settings window wiki page](https://github.com/ModOrganizer2/modorganizer/wiki/Settings-window) gives the meaning of the colors: if mod A is overwritten by mod B, selecting A turns B red and selecting B turns A green.

## Screenshot recipe

- Manual. MO2 itself is free (GPL-3.0) and needs no login, but on first start it asks for a game and reaches its main window only with a supported game installed ([Game Support](https://github.com/ModOrganizer2/modorganizer/wiki/Game-Support)). The runner has no game, and faking one is out.
- Not tested by hand yet: the README's steps, including the color dialog's **HTML** box and **Alpha channel** field.
