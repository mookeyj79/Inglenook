# KiCad: color mapping

For maintainers. The install guide is [README.md](README.md).

One template, `template/{{variant.slug}}.json`, builds one theme file per variant. KiCad keys a theme by its file name (`inglenook-day`, `inglenook-night`) and shows `meta.name`. Colors are written as `#rrggbb`, which KiCad reads through `wxColour::Set` (`COLOR4D::SetFromWxString`); KiCad itself writes `rgb(r, g, b)` when it saves a theme, and both load the same. `meta.version` is 5, the color schema version of KiCad 7.0 and 9.0, so no migration runs on load.

The file carries every key of KiCad 7.0 and of 9.0 (the union). Each version ignores the keys it does not know, and a key a theme leaves out falls back to KiCad Default, so leaving one out would show a KiCad color.

## Color mapping

### Schematic Editor (`schematic`)

| App setting | Color | Why |
|---|---|---|
| `background` | base | |
| `grid`, `page_limits` | line | Carry no meaning |
| `grid_axes`, `aux_items`, `worksheet` (drawing sheet and title block) | dim | Supporting lines and text |
| `cursor`, `hovered`, `brightened` (highlighted net) | accent | "You are here" |
| `shadow` (selection) | accent wash | Selections are a firelight wash |
| `anchor` | reference | Anchors |
| `wire`, `junction` | pine | Connections between parts read as references |
| `bus`, `bus_junction` | steel | Kept apart from wires |
| `component_outline`, `pin`, `sheet` | oxblood | Detail color with no meaning; the outlines of parts and sheets |
| `component_body` | raised | A lifted surface, like a card |
| `sheet_background` | raised | Same as a symbol body |
| `reference` (R1, U3) | tag | Reference designators are annotations |
| `value` (10k, 100nF) | literal | Values |
| `pin_name` | steel | Names, like keys |
| `pin_number`, `netclass_flag`, `no_connect` | dim | Supporting marks |
| `fields`, `sheet_fields`, `hidden`, `excluded_from_sim` | faint | Metadata |
| `note`, `private_note` | faint | Comments |
| `note_background` | base, clear | KiCad draws no fill behind text boxes by default; the clear value keeps that switched off |
| `label_local`, `sheet_name` | text | Content |
| `label_global` | heather | Global labels are constants across the design |
| `label_hier`, `sheet_label` (sheet pins) | dusk | The two ends of a hierarchical connection match |
| `sheet_filename` | reference | A path |
| `rule_area` (9.0) | dusk | |
| `erc_error` | error | |
| `erc_warning`, `dnp_marker` (9.0) | warning | Do not populate is a caution |
| `erc_exclusion` | faint | A silenced marker |
| `op_voltages`, `op_currents` (9.0) | info | Simulation results are information |
| `override_item_colors` | false | KiCad's default: colors set on single items in a design still show |

### PCB Editor and Footprint Editor (`board`)

| App setting | Color | Why |
|---|---|---|
| `background` | base | |
| `grid`, `page_limits` | line | |
| `grid_axes`, `aux_items`, `worksheet`, `ratsnest` | dim | Supporting lines |
| `cursor` | accent | "You are here" |
| `anchor` | reference | Anchors |
| `copper.f` | clay | Copper is a terracotta color; the color itself |
| `copper.b` | steel | Kept apart from front copper |
| `copper.in1` to `copper.in30` | pine, heather, dusk, rosewood, ivy, oxblood, repeating | Layer colors only tell layers apart. Ember, brass, moss, and firelight are left out so no layer reads as an error, a warning, a success, or a selection |
| `pad_through_hole` (7.0) | clay | Through-hole pads are copper on every layer; front copper's color |
| `pad_plated_hole`, `via_hole`, `via_hole_walls` (9.0) | faint | Holes are empty space |
| `plated_hole` (non-plated holes) | dim | Mounting holes, a step stronger than plated ones |
| `via_through` | text | |
| `via_blind_buried` | dusk | |
| `via_micro` | pine | |
| `track_net_names`, `pad_net_names`, `via_net_names` (9.0) | base | Drawn on top of copper, so they read as a cut-out |
| `edge_cuts` | text | The board outline is the frame of everything else |
| `f_silks` | dim | |
| `b_silks` | faint | Back layers sit a step quieter than front ones |
| `f_mask` | heather wash | Solid, so it stays quiet where it covers |
| `b_mask` | pine wash | |
| `f_paste`, `b_paste` | faint | |
| `f_adhes` | rosewood | |
| `b_adhes` | dusk | |
| `f_crtyd` | heather | |
| `b_crtyd` | dusk | |
| `f_fab`, `b_fab` | faint | Fabrication notes are metadata |
| `dwgs_user` | dim | |
| `cmts_user` | faint | Comments |
| `eco1_user` | ivy | Detail color |
| `eco2_user` | oxblood | Detail color |
| `margin` | faint | |
| `user_1` to `user_45` | dim, ivy, oxblood, dusk, heather, rosewood, pine, steel, faint, repeating | Free layers with no meaning of their own |
| `drc_error` | error | |
| `drc_warning` | warning | |
| `drc_exclusion` | faint | |
| `footprint_text_invisible` | faint | Hidden text |
| `locked_shadow` | dusk wash | A mark around locked items; no role means locked |
| `conflicts_shadow` | error wash | Items that collide |

### Gerber Viewer (`gerbview`)

| App setting | Color | Why |
|---|---|---|
| `background` | base | |
| `grid`, `page_limits` | line | |
| `axes`, `worksheet` | dim | |
| `dcodes` | text | |
| `negative_objects` | faint | |
| `layers` 0 to 59 | clay, steel, pine, heather, dusk, rosewood, ivy, oxblood, repeating | A Gerber set has no fixed layer order, so the first two match front and back copper in the PCB Editor |

### 3D Viewer (`3d_viewer`)

| App setting | Color | Why |
|---|---|---|
| `background_top`, `background_bottom` | base | The two ends of KiCad's gradient are the same color, so the background is solid |
| `board` | deep | |
| `copper` | brass | Exposed pads are bare metal; the color itself, and nothing else in the 3D view carries a warning |
| `silkscreen_top`, `silkscreen_bottom` | `ansi.bright_white` | Silkscreen is light ink on both variants: raised in Day, text in Night |
| `soldermask_top`, `soldermask_bottom` | pine | |
| `solderpaste` | faint | |
| `use_board_stackup_colors` | true | KiCad's default: a board's own stackup colors win |

## Gaps and trade-offs

- Tier 1: every color key a theme file has is set, in both KiCad 7.0 and 9.0. The rest of KiCad (menus, toolbars, panels, dialogs) is drawn by wxWidgets with the system's GTK, Windows, or macOS theme, which a color theme cannot reach.
- No transparency. KiCad Default uses alpha on the solder mask, paste, DRC and ERC markers, ratsnest, and the locked and conflict shadows; this port sets them solid. The mask layers are a wash, so the copper they cover stays readable. The Appearance panel's opacity sliders still apply on top, and the README says so.
- KiCad 7's 3D Viewer reads `GetColorSettings()` with no theme name when it builds the scene (`BOARD_ADAPTER::InitSettings`) and has its own **3D Viewer** > **Colors** page, so its background and board colors stayed KiCad Default in a test run with the theme selected in the PCB Editor. The `3d_viewer` keys are still set, since a theme without them falls back to KiCad Default. Not shot.
- Thirty inner copper layers, forty-five user layers, and sixty Gerber layers outnumber the named colors, so they cycle. Front and back copper and the first six inner layers are all distinct.
- `note_background` uses the clear placeholder: switching a fill off is the one thing the theme does with alpha.
- **Colors the screenshots cannot show:** the shot is the PCB Editor on the pic_programmer demo, so every `schematic`, `gerbview`, and `3d_viewer` color, inner copper, blind and micro vias, adhesive, user layers past the defaults, DRC markers, the locked and conflict shadows, the selection, and the cursor (the pointer is off the canvas) are not in it. The schematic colors were checked by eye in a test run of the Schematic Editor on the same demo.

## Research

- [KiCad source, `common/settings/color_settings.cpp` at 7.0.11](https://gitlab.com/kicad/code/kicad/-/blob/7.0.11/common/settings/color_settings.cpp) and [at 9.0.0](https://gitlab.com/kicad/code/kicad/-/blob/9.0.0/common/settings/color_settings.cpp): every key, the schema version (5 in both), and the migrations. 9.0 drops `board.via_through`, `via_blind_buried`, `via_micro`, `pad_through_hole`, and `footprint_text_invisible`, and adds the net name, via hole wall, `user_10` to `user_45`, and schematic simulation and DNP keys.
- [`builtin_color_themes.h` at 7.0.11](https://gitlab.com/kicad/code/kicad/-/blob/7.0.11/common/settings/builtin_color_themes.h): KiCad Default, to see which keys it draws with alpha and which it leaves clear (`note_background`, `sheet_background`).
- [`common/gal/color4d.cpp` at 9.0.0](https://gitlab.com/kicad/code/kicad/-/blob/9.0.0/common/gal/color4d.cpp): theme colors are parsed by `wxColour::Set`. Checked in wxWidgets 3.2.4 (Mint 22.3): `#rrggbb`, `#rrggbb00`, and `rgb()` all parse.
- [KiCad PCB Editor manual: Colors](https://docs.kicad.org/7.0/en/pcbnew/pcbnew.html#colors): themes live in the `colors` folder of the settings folder, are read at start-up, and are picked per editor in Preferences.
- [Catppuccin for KiCad](https://github.com/catppuccin/kicad) (MIT): studied for the method: one theme file per flavor, picked separately for the Schematic, Symbol, PCB, and Footprint Editors. It ships as a Plugin and Content Manager zip; this port keeps to the documented `colors` folder instead, so there is no package to build. No files, colors, or names were reused.
- KiCad 7 source, `pcbnew/pcbnew.cpp` and `eeschema/eeschema.cpp`: the Preferences pages for colors are PCB Editor, Footprint Editor, Schematic Editor, Symbol Editor (`use_eeschema_color_settings`, on by default), and a separate 3D Viewer page with its own colors.

## Screenshot recipe

- KiCad is free software (GPL-3.0) and needs no login or license ([license](https://www.kicad.org/about/licenses/)).
- `screenshot.json` shoots the PCB Editor in Ubuntu noble's `kicad` package, `7.0.11+dfsg-1build4`, on the `pic_programmer` demo board from the `kicad-demos` package of the same version (GPL-2+, KiCad developers, per the package's copyright file). The board is copied at stage time; no demo file is kept in this repo.
- **apply** runs Install step 4 for both files, then writes `appearance.color_theme` into `pcbnew.json`, `footprint_editor.json`, `eeschema.json`, and `gerbview.json`. That stands in for Install steps 6 to 11 in the Preferences dialog: not tested by hand.
- **stage** runs `build/photograph/scenes/document/kicad/stage.sh`: it copies the demo, writes an empty `kicad_common.json` and empty global library tables so KiCad 7 skips its first-run dialogs, and sets a fixed PCB Editor window size. No color changes.
