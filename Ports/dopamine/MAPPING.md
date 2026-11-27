# Dopamine: color mapping

For maintainers. The install guide is [README.md](README.md).

## Layout

- **Frame** (`deeper`): the header (window buttons, collection tabs) and the footer (playback controls).
- **Recessed** (`deep`): the side panes of the collection pages.
- **Content** (`base`): the main background, where the track lists sit.
- **Raised** (`raised`): dialogs, menus, the search box, cover placeholders, secondary buttons.

A theme file has one `coreColors` set and two neutral sets, `darkColors` and `lightColors`, picked by **Use light theme** (or **Follow the system theme**). The accent lives in `coreColors`, so one file cannot hold both variants: Day's firelight on Night's neutrals fails the floor. Each variant is its own file, with the same values in `darkColors` and `lightColors`, so the light switch only decides whether Angular Material draws its light or dark component styles. The README says to set it to match.

## Color mapping

The same mapping fills `darkColors` and `lightColors`.

| App setting | Color | Why |
|---|---|---|
| `coreColors.accentColor` | `accent` | Progress, the playing track, toggles, the tooltip fill, the window buttons' hover |
| `coreColors.primaryColor`, `coreColors.secondaryColor` | `accent` | The two ends of Dopamine's accent gradient (logo, cover placeholders, back button, notification bar). Both ends the same, so it draws solid |
| `mainBackground` | `base` |  |
| `headerBackground`, `footerBackground` | `deeper` |  |
| `sidePaneBackground` | `deep` |  |
| `albumCoverBackground`, `dialogBackground`, `searchBox`, `secondaryButtonBackground` | `raised` |  |
| `hoveredItemBackground` | `hover` |  |
| `selectedItemBackground` | `accent` wash | Selected rows are "you are here" |
| `primaryText`, `selectedTabText`, `searchBoxText`, `secondaryButtonText` | `text` |  |
| `secondaryText`, `tabText`, `windowButtonIcon` | `dim` |  |
| `searchBoxIcon` | `faint` |  |
| `sliderBackground`, `buttonBorder`, `headerSeparator`, `paneSeparators`, `settingsSeparators`, `contextMenuSeparators`, `scrollBars` | `line` | The scroll bar thumb is `line`, as in VS Code |
| `sliderThumbBackground` | `text` | The knob of sliders and toggle switches; the filled part is the accent |
| `highlightForeground`, `tooltipText`, `primaryButtonText` | `on_accent` | Text and icons on accent fills (tooltips are drawn on the accent) |
| `options.centerAlbumInfoText` | not a color | `false`, Dopamine's default |

## Gaps and trade-offs

- **No state colors.** Dopamine has no slot for errors, warnings, or success, so `error`, `warning`, `success` and `info`, the syntax colors, and the detail colors are not used. That makes this Tier 2.
- **Shades Dopamine works out itself.** It derives a Material palette (50 to 900, A100 to A700) from `accentColor` for Angular Material controls such as checkboxes, and uses `primaryText` at 6 to 30 percent opacity for some row and menu backgrounds. These are not palette colors and the theme cannot set them.
- **Hover glow.** Buttons draw a `box-shadow` of the accent at 40 percent opacity on hover. Fixed in Dopamine's CSS.
- **Rich lyrics** (off by default) paint the unplayed words with `highlightForeground`, which is `on_accent` and close to the background. Any other value would break the text on every accent fill, so this stays.
- **Follow the system color** and **Follow the album cover color** replace all three core colors and the scroll bar with a color the theme does not control. The README says to leave them off.
- **Unused keys.** `primaryButtonText` and `secondaryButtonText` are in the model but no stylesheet reads them in 3.0.12. They are set so the file is complete.
- **Colors the screenshots cannot show.** The scene has no dialog, menu, tooltip, or hovered row, so `raised` as a dialog, `hover`, and the tooltip are themed but not shown. The search box and cover placeholders show `raised`.

## Research

- Studied the built-in [Catppuccin theme for Dopamine](https://github.com/digimezzo/dopamine/blob/v3.0.12/src/app/services/appearance/themes/catppuccin-theme.ts) (GPL-3.0, by BlackSpirits) and the default Dopamine and Dracula themes in the same folder. Method only: the mantle-style deeper shade for header, footer and side pane, the same color at both ends of the accent gradient, and separators. No files or colors reused.
- The format comes from the source, not a wiki page: `Theme`, `ThemeCoreColors`, `ThemeNeutralColors` and `ThemeOptions` in [`src/app/services/appearance/theme/`](https://github.com/digimezzo/dopamine/tree/v3.0.12/src/app/services/appearance/theme). `AppearanceService` writes the built-in themes as `<name>.theme` JSON into `<userData>/Themes`, reads every file in that folder with `JSON.parse`, and sets one CSS variable per key (`--theme-main-background` and so on). The theme's `name` is what the settings store and the swatch tooltip show.
- `userData` is Electron's `app.getPath('userData')` for the app named `Dopamine`: `%APPDATA%\Dopamine`, `~/Library/Application Support/Dopamine`, `~/.config/Dopamine`.

## Screenshot recipe

- Dopamine is GPL-3.0 and needs no account or license; Last.fm, ListenBrainz and Discord are optional and off by default. A normal recipe.
- The scene kind is `app`. The port's own scene folder is `build/photograph/scenes/app/dopamine/`: `library.sh` makes eleven tracks of generated silence (FLAC, made-up tags, no cover art) with ffmpeg, and `collection.sh` turns them into Dopamine's collection.
- **install** fetches the 3.0.12 `.deb` from the GitHub release, checks it against the release's `SHA256SUMS.txt` value, and installs it with ffmpeg, sqlite3 and jq.
- **apply** is Install step 6 (copy the variant's `.theme` into `~/.config/Dopamine/Themes`). **Scripted stand-ins, not tested by hand:** steps 7 and 8 (refresh, click the swatch, set **Use light theme**) are a `config.json` with `theme`, `useLightBackgroundTheme` and `followSystemTheme`.
- **stage** turns off the welcome wizard, update checks, online downloads, the tray icon and the audio visualizer, fixes the window at 1200x760, and selects the Artists tab with Wren Calloway. `collection.sh` starts Dopamine twice before the shot: once to create its database, then, after inserting the music folder into `Folder` (what **Manage collection** > **Add folder** stores), once to index it. Then it writes the queue (`QueuedTrack`) with Morning Kettle paused at 1:10, which Dopamine restores on start. The last stage step turns automatic refresh off, so the shot does not reindex. None of these sets a color.
- **launch** passes `--no-sandbox` (Chromium's sandbox cannot start in the container), `--disable-gpu` and `--password-store=basic`.
