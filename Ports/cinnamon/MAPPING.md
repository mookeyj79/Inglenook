# Cinnamon: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

The template is Mint-Y's Cinnamon stylesheet with every color replaced. Mint-Y builds it from Sass variables; the table maps those variables (and the colors Mint-Y derives from them) to the palette.

| App setting | Color | Why |
|---|---|---|
| Panel (`.panel-top`, `-bottom`, `-left`, `-right`), Alt-Tab list, on-screen keyboard | deeper | The most recessed surface, like a title bar |
| Panel text, applet labels and icons | text | |
| Menus, popups, calendar, notifications, dialogs, OSDs, tooltips, desklets | raised | Lifted surfaces |
| Menu border (`.menu`), popup and preview borders, separators, entry borders | line | Mint-Y draws a drop shadow instead; the theme has none, so menus get a 1 px line |
| Menu favorites column, sidebar, calendar events box, disabled buttons | deep | Recessed area inside a raised popup |
| Search and run entries | base, line border; accent border when focused | |
| Hovered or keyboard-selected menu item, application, category, favorite; selected Alt-Tab item; selected input-method candidate | accent wash, text on it | "You are here" |
| Focused window in the panel window list | accent wash and an accent bottom border | "You are here" |
| Running windows in the window list | faint bottom border | Mint-Y marks them with its accent; here they are not "you are here" |
| Hovered panel buttons, applets, launchers, workspace buttons, notification buttons, dialog buttons | hover | |
| Dialog buttons at rest; pressed and hovered | hover; line | |
| Default dialog button, switches and check boxes when on, sliders, progress, pressed buttons, focused entries in notifications | accent fill, on_accent text | Primary buttons and focus |
| Today in the calendar | accent wash | Where you are in time |
| Hovered day in the calendar, hovered event, "today" button | accent fill, on_accent text | |
| Selected day in the calendar | hover | |
| Secondary text: week numbers, day headings, descriptions | dim | |
| Placeholders, hints, past events, other-month days, disabled items | faint | |
| Links | accent | |
| Errors, the panel "dummy" area, highlighted (drop target) applets and desklets, urgent windows in the window list | error wash | Ember is failure and urgency, as a wash so the label still reads |
| Destructive dialog buttons, the shutdown button on hover, close buttons on hover | error fill, on_accent text | Removal |
| The shutdown button at rest | error wash, text | |
| Warnings (volume above 100 %, the end-session list title) | warning, warning wash | |
| Panel drop zones while editing the panel (left, center, right) | oxblood, ivy, steel washes | Mint-Y uses red, green, and blue to tell them apart; oxblood and ivy carry no meaning |
| Magnifier frame | oxblood | A detail color, no meaning |
| Workspace graph applet windows | hover (active), deep (inactive), faint and line borders | |
| Invisible borders, the label shadow, separator ends | `base|clear` | Mint-Y draws these fully transparent to keep their space; nothing is see-through |

Assets (`assets/`) are redrawn as plain shapes with the same placeholders: check boxes and radio buttons (base and faint off, accent and on_accent on, accent ring when focused), switches (line track off, accent track on), calendar arrows (dim, accent on hover), close buttons (hover circle, error on hover), and the add-workspace bar (deep, accent on hover).

## Gaps and trade-offs

- Tier 1: every color the desktop theme draws comes from the palette. Apps and window borders belong to the GTK and window border themes, which this port does not ship.
- Solid surfaces: Mint-Y's panel is 1 % see-through, its menus and OSDs have drop shadows, and several overlays (workspace overview shade, window tiling preview, panel drop zones) are translucent. All are solid here, or the shadow is dropped. The tiling preview and the drag placeholder are a solid accent wash, so they hide what is under them.
- Gradients: Mint-Y's panel drop zones and urgent-window highlights are vertical gradients; here they are solid fills.
- Left out: the hot-corner ripple image, the overview corner image, the trash icon in the expo view, and the notification card image in the tray popup (a border and fill instead).
- **What the screenshots show:** the panel (deeper), the open menu (raised, with its deep sidebar and line border), the selected category (accent wash), the focused search entry (accent border), the shutdown button (error wash), and the focused window in the window list (accent wash and underline).
- **Colors the screenshots cannot show:** the calendar, notifications, OSDs, Alt-Tab, tooltips, dialogs, check boxes, switches, the warning color, running but unfocused windows, and the drop zones.

## Research

- Mint-Y (linuxmint/mint-themes 2.3.8, the version in Linux Mint 22.3), `src/Mint-Y/cinnamon/sass/`, GPL-3.0-or-later ([debian/copyright](https://github.com/linuxmint/mint-themes/blob/2.3.8/debian/copyright)). Reused as the structure of the stylesheet: it was compiled with every Sass color function replaced by a text form of its call, so each value in the output names the Mint-Y variable it came from, and each of those was mapped to the palette. The template is under GPL-3.0-or-later and its header says so. Its image assets were not reused.
- [Cinnamon wiki: Theming](https://github.com/linuxmint/cinnamon/wiki/Theming) and [Theming, CSS reference](https://github.com/linuxmint/cinnamon/wiki/Theming,-CSS-reference): the St CSS properties and selectors.
- [themeManager.js](https://github.com/linuxmint/cinnamon/blob/6.6.9/js/ui/themeManager.js): Cinnamon looks for `<name>/cinnamon/cinnamon.css` in `~/.local/share/themes`, `~/.themes`, then the system theme folders, and the setting is `org.cinnamon.theme name`.
- [grouped-window-list appGroup.js](https://github.com/linuxmint/cinnamon/blob/6.6.9/files/usr/share/cinnamon/applets/grouped-window-list%40cinnamon.org/appGroup.js): `:focus` is the app with the focused window, `:active` an app with open windows. That is why focus gets the accent and running gets faint.
- [Nordic](https://github.com/EliverLara/Nordic) and [Dracula for GTK](https://github.com/dracula/gtk): both ship `cinnamon/cinnamon.css` inside the same theme folder as their GTK and window border themes, one folder per variant. Method only; no files reused.

## Screenshot recipe

- Cinnamon needs no login or license (GPL-2.0-or-later).
- `screenshot.json` installs Cinnamon 6.6.9 and Nemo 6.6.3, the Linux Mint 22.3 packages, and shoots the desktop scene: the panel and the open menu, over the file manager.
- **apply** is the README's terminal install for the shot's variant.
- **stage** sets one keyboard layout. With none set, Cinnamon asks the system bus (`org.freedesktop.locale1`) for one, and the Photographer's container has no system bus, so Cinnamon stopped before drawing its panel. A real session sets this on first login. No color changes; not something a reader does.
- The file manager and its window frame are the Photographer's stock GTK theme, not this port.
