# GTK and MATE: color mapping

For maintainers. The install guide is [README.md](README.md).

The port is one theme folder per variant, named after the variant (`{{variant.name}}`), with `gtk-3.0/gtk.css`, `gtk-4.0/gtk.css` and `metacity-1/metacity-theme-3.xml`. The Cinnamon port uses the same folder names for its `cinnamon/` folder, so both can be copied into one theme folder; neither needs the other. There is no `index.theme`, so the two ports never ship the same file.

Each stylesheet names every palette color once, in `@define-color` lines at the top, and the rules use those names. Nothing else in the files is a color.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `theme_bg_color`, window background | deep | GTK draws content views on a lighter or darker surface than the window around them; deep keeps the content on base |
| `theme_base_color`, views (text views, trees, lists, notebook pages) | base | Where content lives |
| `theme_fg_color`, `theme_text_color` | text | |
| Header bars, title bars, menu bars, tab strips | deeper | Title bars, PHILOSOPHY.md |
| Buttons, entries, menus, popovers, tooltips, cards | raised | Lifted surfaces and inputs |
| Hovered buttons, rows, menu items | hover | |
| Borders, separators, scrollbar sliders, unfilled troughs | line | |
| Insensitive text, placeholders, unfocused window title | faint | |
| Backdrop (unfocused window) text, accelerators, column headers, dim labels | dim | |
| `theme_selected_bg_color`, selected rows, text selection, rubberband | accent wash | Selections are a firelight wash with text on it |
| `theme_selected_fg_color` | text | Text on a wash meets the floor |
| Focus ring, focused entry border, caret | accent | "You are here" |
| Checked check boxes, radio buttons, switches, toggle buttons, pressed buttons | accent, mark in on_accent | Checked controls use the accent |
| Scale fill, progress bar, level bar fill, spinner, active tab underline | accent | Where the value is |
| Suggested-action button | accent, label in on_accent | Primary button |
| Destructive-action button | error border and label on raised, error wash on hover | Removal. The label stays on a solid raised surface, so no contrast pair is needed that the palette does not measure |
| Links | accent; visited links dim | |
| Level bar low | warning | |
| Level bar full | success | |
| Error, warning, success labels and entries | error, warning, success | |
| Info bars: info and question, warning, error | steel wash, brass wash, ember wash, with text | Washes of the state colors |
| Window border (Marco, Muffin, Metacity): focused title bar | deeper, title in text | |
| Window border: unfocused title bar | deep, title in faint | |
| Window border outline, title bar bottom line | line | |
| Window border buttons | glyph in dim (faint unfocused); hover surface with text glyph; pressed accent with on_accent glyph | |
| Libadwaita `accent_*` | accent, accent, on_accent | GTK 4 file only |
| Libadwaita `destructive_*`, `success_*`, `warning_*`, `error_*` | the state color, its wash, text | Fills are washes, so their text is text |
| Libadwaita `window_*`, `view_*`, `headerbar_*`, `sidebar_*`, `card_*`, `dialog_*`, `popover_*` | the same neutrals as the GTK names above | |
| Libadwaita `*_shade_color`, `shade_color` | line | Libadwaita's defaults are see-through black; line is solid |

## Gaps and trade-offs

- **Tier 2.** GTK 3 is covered widget by widget (buttons, entries, spin buttons, combo boxes, checks, radios, switches, scales, progress and level bars, header bars, tool bars, menus, popovers, tooltips, notebooks, lists, tree views, sidebars, scrollbars, info bars, calendars, expanders, dialogs). GTK 4 gets the same rules with GTK 4 node names, but is not shot, so it is less proven. The theme is written from scratch, so rare widgets (print dialogs, the color editor, GtkSourceView chrome) fall back to plain rules and may look sparse.
- **No transparency, no shadows.** Every `box-shadow` is `none` except the solid inset rings of a few controls, `text-shadow` and `-gtk-icon-shadow` are off, and the client-side decoration has a solid line border instead of a shadow. The libadwaita shade colors are solid line. The see-through areas of libadwaita's own stylesheet (button fills mixed with `alpha()`) cannot be changed from the user stylesheet.
- **No images.** Check marks and arrows are symbolic icons from the icon theme, colored by the stylesheet. The window border buttons are drawn with lines. GTK 2 is not included: it needs a `gtkrc` and an engine or image set, which is out of proportion.
- **Search matches (ADR 0009)**: plain GTK has no search-match style (that belongs to GtkSourceView and to apps), so the port sets none.
- **Named colors not used**: oxblood, ivy, clay, pine, dusk, heather and rosewood are not used. A widget theme has no syntax.
- **Colors the screenshots cannot show:** the shot is page 2 of the widget factory, so check boxes, radio buttons, entries, toggle buttons, notebooks, progress and level bars (page 1), the destructive button (page 3), menus, popovers, tooltips and info bars (shown only on interaction) are not in it; nor are hovered and pressed states, the selection wash, warning, error and success colors, the libadwaita names, and the unfocused window border. They were checked by eye in local renders of page 1, not in committed shots.

## Research

- [GTK 3 CSS overview](https://docs.gtk.org/gtk3/css-overview.html) and [properties](https://docs.gtk.org/gtk3/css-properties.html), [GTK 4 CSS overview](https://docs.gtk.org/gtk4/css-overview.html) and [properties](https://docs.gtk.org/gtk4/css-properties.html): node names, `@define-color`, `-gtk-icontheme()`, and which properties exist in which version. GTK 4 dropped style properties (`-GtkWidget-*`), `-gtk-outline-radius` and `-gtk-icon-effect`, so the GTK 4 file leaves them out; GTK 3 has no `:focus-within`, so its spin button uses `:focus`.
- Each widget's CSS nodes come from its page in the GTK 3 and GTK 4 API docs (the "CSS nodes" section).
- [Metacity theme format](https://gitlab.gnome.org/GNOME/metacity/-/blob/master/doc/theme-format.txt): format 3 still requires every button function (shade, above, stick and the six button backgrounds) in a frame style, which Marco 1.26 enforces. The unused ones draw nothing.
- [Libadwaita named colors](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.5/named-colors.html): the names a libadwaita app reads, which the GTK 4 file defines. GTK 4 loads `~/.config/gtk-4.0/gtk.css` at user priority ([GTK docs](https://docs.gtk.org/gtk4/const.STYLE_PROVIDER_PRIORITY_USER.html)).
- Mint-Y and Adwaita were considered as a base to recolor. Their sources compute many colors from a few (`mix()`, `darken()`, `alpha()`), which would put colors in the theme that the palette never defined. So no files were reused: the stylesheets are new, with selectors taken from the GTK docs.
- Checked by loading both variants in `gtk3-widget-factory` and `gtk4-widget-factory` on GTK 3.24.41 and 4.14.5: no CSS parser warnings.

## Screenshot recipe

- The scene kind is `app`: the toolkit's own widget gallery (`gtk3-widget-factory`) brings its content, so the port has no scene folder.
- No login or license: the widget factory ships with GTK (`gtk-3-examples`, LGPL).
- The recipe stands in for the README's MATE steps: it writes `gtk-theme-name` to `~/.config/gtk-3.0/settings.ini` (the README's "any other desktop" step) and sets Marco's theme with `gsettings set org.mate.Marco.general theme`, which is what the **Window Border** tab writes. Not tested by hand.
- `marco --replace` takes over from the Photographer's Metacity, so the border is drawn by MATE's own window manager. Marco's compositor is off, because the Photographer runs picom.
- The widget factory draws its own header bar, so on its own it would ask for no window border. The launch step starts it with `GTK_CSD=0` and sets `_MOTIF_WM_HINTS` to ask Marco for a border, so the shot shows both the header bar and the window border. A user's widget factory shows only the header bar.
- The Photographer exports `GTK_THEME` (the stock frame); the launch step unsets it for the widget factory, or it would override the theme.
- The widget factory's first page pulses a progress bar on a timer, which stops at a different place in every take, so the launch step clicks **Page 2** in the header bar (a fixed spot in the centered window). Page 2 shows a calendar on today's date, so the widget factory runs with its wall clock at a fixed date through libfaketime (the clock only; its timers run normally). The stage step also turns GTK animations off (`gtk-enable-animations=false`) so the spinner on page 1 never draws a frame. Freezing the whole clock, to keep page 1, left the window unpainted.
- Page 2 shows the menu bar, tool bar, spin buttons, text view, status bar, calendar with the selected day, expander, icon view, list rows with a switch and a scale, linked toggle buttons and plain buttons. Check boxes, radio buttons, entries, toggle buttons, notebooks and progress bars are on page 1 and are not in the shot.
