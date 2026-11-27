# OBS Studio: color mapping

For maintainers. The install guide is [README.md](README.md).

## How the port is built

OBS 30.2 and later compose themes from a base (`.obt`) and variants (`.ovt`). Each Inglenook variant is one `.ovt` that is a style of Yami, OBS's default theme:

- Night extends `com.obsproject.Yami`, so it keeps Yami's dark icons.
- Day extends `com.obsproject.Yami.Light`, so it keeps the dark-on-light icons that Yami Light swaps in. OBS allows a variant to extend a variant as long as the chain ends at a base theme.

The file sets every color variable Yami defines (its `grey`, `white`, `black`, `blue`, `red`, `yellow`, `green`, `purple`, `teal` and `pink` scales, the semantic variables and the `palette_` Qt palette), then repeats the rules in Yami and Yami Light that name a scale step or a raw color, so Day and Night draw the same parts the same way. The `extends` id and the `dark` flag come from `values.json`.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `bg_window` (window, docks' frame, title bars of docks) | deep | the area behind the panels |
| `bg_base` (lists, dock contents, mixer) | base | where content lives |
| `bg_preview` (around the canvas) | deeper | the most recessed surface |
| `input_bg`, `button_bg`, `grey2`, `grey4`, `grey5` (inputs, buttons, property rows) | raised | |
| `button_bg_hover`, `button_bg_down`, `list_item_bg_hover`, `grey3`, hovered list rows | hover | |
| `border_color`, `input_border`, `button_border`, `grey1`, scrollbar handle | line | |
| `input_border_hover`, `button_border_hover`, scrollbar hover | faint | |
| `text`, `text_light`, `text_inactive` | text | |
| `text_muted` (descriptions, inactive mixer names) | dim | |
| `text_disabled` | faint | |
| `primary`, `primary_light`, `primary_dark`, `primary_darker` | accent wash | Yami fills selected and checked things with these and keeps the text color on them: selected scene, source and menu item, checked buttons, the selected tab, the active Start Streaming and Start Recording buttons |
| `primary_lighter`, `highlight_color`, `input_border_focus`, `tab_border_focus`, keyboard focus borders | accent | focus |
| `.button-primary` (dialog default buttons) | accent fill, on_accent text | primary button |
| `palette_link`, `.text-bright` | accent | links |
| Slider filled part, slider pressed | accent | the value you set |
| Slider handle | dim (text on hover, line disabled) | |
| Progress bar | info | in progress |
| `danger`, `.text-danger` | error | |
| `warning`, `.text-warning` | warning | |
| `.text-success` | success | |
| Audio meter: green, yellow and red zones | success, warning, error; each zone's track is its wash | the red zone is clipping, a failure of the signal |
| Audio meter peak line, ticks, labels | text, dim and faint | |
| Mute button, muted | error | audio removed from the output |
| Mute button, unassigned (muted because no track takes it) | warning wash | caution |
| Monitor and hide toggles, checked | accent wash, accent border | checked buttons, like every other checked button |
| Mixer group headers (default, pinned, preview) | info wash, text | a label |
| Mixer group headers (hidden, inactive) | deeper, dim | recessed |
| Mixer group header (unassigned) | warning wash, text | |
| Switches | hover off, accent wash on, text handle | |
| `blue1` to `blue3`, `blue4` to `blue6` | info, info wash | fallbacks for any rule that names a step |
| `red`, `yellow`, `green` steps | error, warning, success and their washes | same |
| `purple`, `teal`, `pink` steps | heather, pine, rosewood and their washes | closest named color; no stock rule uses them after the overrides |

### Recording and streaming are not ember

When OBS is recording or live, Yami marks the Start Recording and Start Streaming buttons with `primary`, the same fill as any checked button, and the label says "Stop Recording". Nothing failed and nothing was removed, so the port keeps OBS's own meaning: a checked button, the accent wash. Ember appears only where OBS uses red for a problem: the clipping zone of the meters, a muted source, and error text.

## Gaps and trade-offs

- The canvas (the preview) shows the scene's own sources. The theme cannot color it.
- Pinned and preview mixer headers look like the default header: Yami tells them apart by hue alone, and none of the palette's roles means "pinned" or "preview". The header text still names the group.
- Hover over a selected row does not change it, since all `primary` steps are one wash.
- Icons are Yami's and Yami Light's own SVGs, in their own grays.
- The UI font is OBS's default. OBS has no font setting for its interface; a theme could set one, but no other Inglenook port sets an app's interface font.
- The screenshots show the selection in the Scenes list (the current scene) but not in Sources: OBS does not restore a selected source from the scene collection. They show the slider fill, the meter zones' washes, raised buttons and inputs, and the deep, base and deeper surfaces.
- The screenshots hide the status bar (`ShowStatusBar=false` in the stage): its CPU and FPS readout changes every second, so the screen never settles. The status bar has no colors of its own beyond text.
- The black bars beside the picture in the preview are OBS's canvas, not the theme.
- The screenshots cannot show: dialogs (Settings, Add Source, Properties), progress bars, the clipping and warning zones of the meters (the scene has no live audio), a muted source, text in the error or warning colors, switches, and keyboard focus.

## Research

- Catppuccin for OBS (https://github.com/catppuccin/obs): one `.ovt` per flavor, generated from a template, copied into the user `themes` folder, picked under Settings > Appearance. It targets OBS 30.2 and later and keeps a `pre-30.2.0` tag for the old `.qss` format. Learned: override the variables, not the rules, wherever Yami already uses a variable.
- Yami's own files at the 32.2.0 tag, `frontend/data/themes/Yami.obt`, `Yami_Light.ovt` and `Yami_Default.ovt`: the variable names, which rules name a scale step directly (meters, mute and monitor buttons, mixer headers, sliders, switches), and the `qproperty-` colors of `VolumeMeter`.
- `frontend/OBSApp_Themes.cpp` at 32.2.0: themes load from the bundled `themes/` and from `<config>/obs-studio/themes`; a variant may extend a variant if the chain ends at a `.obt`; the chosen theme is `Theme` under `[Appearance]` in `user.ini`.
- Composable themes arrived in OBS 30.2. Ubuntu 24.04's own `obs-studio` package is 30.0.2, which has only the old `.qss` themes, so the recipe installs the OBS project's PPA build.

## Screenshot recipe

- OBS Studio is free software (GPL 2.0) and needs no login or license. Its streaming services ask for a login only when you connect an account, which the scene does not.
- The recipe installs the exact PPA build, `32.2.0-0obsproject1~noble`, from Launchpad's file store (`+files/`), which keeps superseded builds, and checks its SHA-256.
- The scene lives in `build/photograph/scenes/app/obs-studio/` under a new scene kind, `app`, for desktop app windows.
- Choosing the style in Settings > Appearance is done by writing `Theme=` under `[Appearance]` in `user.ini`: not tested by hand.
- The first-run wizard is skipped by `FirstRun=true` in `user.ini` and `LastVersion` in `global.ini`, as after a previous run. Linux builds have no updater; `--disable-updater` is passed anyway.
- OBS needs OpenGL 3.3; the shot renders with Mesa's software renderer (`LIBGL_ALWAYS_SOFTWARE=1`).
