# Heroic Games Launcher: color mapping

For maintainers. The install guide is [README.md](README.md).

## Layout

- **Recessed** (`deep`): the sidebar, the context menu and dropdown lists (both use `--navbar-background`), tooltips, and the title band on game cards.
- **Content** (`base`): the page behind the library, settings and game pages.
- **Raised** (`raised`): inputs, the search bar, dialogs, menus (Material UI paper reads `--background`), and the tour popup.
- **Hover** (`hover`): hovered and current sidebar rows, quiet and disabled buttons.

One CSS file per variant. Heroic puts the file name, minus `.css`, on `<body>` as a class, so every rule is scoped to `body.inglenook-day` or `body.inglenook-night` and the file names must not change.

## Color mapping

Every variable was checked against Heroic's own themes in [`themes.scss`](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/v2.22.4/src/frontend/themes.scss) and [`styles/_colors.scss`](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/v2.22.4/src/frontend/styles/_colors.scss), and by grepping `src/frontend` at v2.22.4 for where each one is used.

**Surfaces**

| App setting | Color | Why |
|---|---|---|
| `--body-background`, `--current-background`, `--osk-background` | `base` |  |
| `--gradient-body-background` | `base` | a solid color in place of Heroic's fade from the sidebar edge |
| `--navbar-background`, `--background-darker`, `--icons-background` | `deep` | the sidebar, and the lists and tooltips that share its variable |
| `--background`, `--background-lighter`, `--input-background`, `--search-bar-background`, `--modal-background`, `--osk-button-background`, `--tour-popup-background` | `raised` |  |
| `--navbar-active-background`, `--background-secondary` | `hover` | the sidebar uses the same variable for the hovered and the current row |
| `--divider`, `--modal-border`, `--search-bar-border`, `--osk-button-border` | `line` |  |
| `--gamecard-title-color`, `--gradient-gamecard` | `deep` | a solid band under the title on a card, in place of Heroic's dark fade over the cover art |
| `--neutral-01` to `--neutral-06` | `deeper`, `deep`, `raised`, `line`, `dim`, `text` | Heroic's neutral scale, which a few screens read directly (the tour, the game page, borders) |

**Text**

| App setting | Color | Why |
|---|---|---|
| `--text-default`, `--text-title`, `--text-gametitle`, `--brand-text-01`, `--navbar-inactive`, `--tour-popup-title` | `text` |  |
| `--text-hover`, `--action-icon-hover`, `--tour-popup-skip-color-hover` | `text` | hover is not "you are here", so it lifts to `text` rather than firelight |
| `--text-secondary`, `--brand-text-02`, `--action-icon`, `--tour-popup-skip-color` | `dim` |  |
| `--text-quartenary`, `--icon-disabled` | `faint` |  |
| `--text-tertiary` | `on_accent` | the text on filled buttons |
| `.button.is-tertiary` color | `text` | quiet buttons sit on `hover`, where `on_accent` would not read |

**Accent**

| App setting | Color | Why |
|---|---|---|
| `--accent`, `--accent-overlay`, `--navbar-active`, `--navbar-accent`, `--link-highlight`, `--button-stroke`, `--action-icon-active` | `accent` | focus rings, links, the current page in the sidebar |
| `--primary`, `--primary-hover`, `--primary-active`, `--secondary`, `--brand-primary`, `--brand-primary-hover`, `--brand-secondary`, `--primary-button`, `--secondary-button`, `--secondary-button-overlay`, `--play-button`, `--install-button`, `--download-button`, `--download-button-overlay`, `--tour-bullet-active` | `accent` | primary buttons. The palette has no hover shade of firelight, so hover keeps the fill and Heroic adds its own ring |
| `--tertiary-button`, `--disabled-button` | `hover` |  |
| `--tertiary-button-overlay`, `--disabled-button-overlay`, `--tour-bullet-inactive` | `line` |  |

**State**

| App setting | Color | Why |
|---|---|---|
| `--success`, `--success-hover`, `--success-button`, `--status-success`, `--status-success-hover`, `--anticheat-supported` | `success` |  |
| `--danger`, `--danger-hover`, `--text-danger`, `--status-danger`, `--status-danger-hover`, `--cancel-button`, `--cancel-button-overlay`, `--stop-button`, `--anticheat-denied` | `error` | `--cancel-button` fills `.button.is-danger` (stop, uninstall), which is removal |
| `--warning`, `--warning-hover`, `--text-warning`, `--text-log`, `--status-warning`, `--status-warning-hover`, `--anticheat-broken` | `warning` |  |
| `--status-info`, `--status-info-hover`, `--anticheat-planned` | `info` |  |
| `--status-default`, `--anticheat-running` | `dim` | neutral status |

`color-scheme` is set to the variant's mode so native scrollbars and form controls match.

## Gaps and trade-offs

- Game cover art and store web pages (Epic, GOG, Amazon) are images and websites; the theme cannot reach them.
- `--modal-backdrop` and `--background-darker-80` are left as Heroic's: they are see-through dimming behind dialogs, and the theme never sets transparency.
- A few rules in Heroic's own CSS set a raw color with no variable, such as the default `button` text color. Where they show on a themed screen, they keep Heroic's value.
- Heroic colors every `<a>` with `--text-default`, so inline links (the "here" in the empty library) are `text`, underlined, not `accent`. The theme keeps Heroic's choice rather than restyle every link.
- The Categories and Filters dropdowns keep Heroic's own drop shadow.
- The screenshots show the library with no store logged in (empty state). Game cards, the game page, downloads and dialogs are not in the scene.

## Research

- [catppuccin/heroic](https://github.com/catppuccin/heroic) (MIT): one CSS file per flavor and accent, setting only custom properties on `body.<file-name>`, plus `box-shadow: none` on inputs. The variable list here started from theirs, then grew from a grep of `src/frontend` for `var(--`.
- [Heroic-Games-Launcher/heroic-themes](https://github.com/Heroic-Games-Launcher/heroic-themes) (Rosé Pine, Tokyo Night, Gruvbox Dark): the same method, fewer variables.
- The class name comes from `window.setTheme` in [`src/frontend/index.tsx`](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/v2.22.4/src/frontend/index.tsx): it strips `.css` and replaces the first space or dot with `_`.
- The Themes path and theme picker (`ThemeSelector`) appear in both Settings > General and Accessibility. The chosen theme is stored as the file name, `theme` in `~/.config/heroic/store/config.json`; the path is `defaultSettings.customThemesPath` in `~/.config/heroic/config.json`.

## Screenshot recipe

- Heroic does not require a login. With no store connected, the library opens to an empty state that offers a login or adding a game by hand ([`EmptyLibrary`](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/v2.22.4/src/frontend/screens/Library/components/EmptyLibrary/index.tsx)), and Settings and Accessibility work without one. The [wiki home](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/wiki) lists sideloaded titles alongside the stores. Heroic is GPLv3, with no license key.
- The recipe writes `customThemesPath` and `theme` into Heroic's config files in place of steps 4 to 6 of the README (the folder picker and the dropdown), and sets the two Accessibility fonts the same way: not tested by hand.
- First-run dialogs, all turned off in stage without touching a color:
  - The analytics dialog is remembered only in the window's `localStorage` (`analytics-modal-shown`). Stage runs Heroic once for 20 seconds with `CI=e2e`, Heroic's own end-to-end test switch ([`src/preload/index.ts`](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/v2.22.4/src/preload/index.ts)), which marks it as shown. The shot itself runs without `CI=e2e`: that switch also moves `config.json` to a temporary folder ([`constants/paths.ts`](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/v2.22.4/src/backend/constants/paths.ts)), so the themes path is lost and the theme never loads.
  - The changelog dialog: `settings.hideChangelogsOnStartup` in `store/config.json` (Settings > General, "Hide changelogs on startup").
  - Update checks: `checkForUpdatesOnStartup` and `enableUpdates` off in `config.json`.
- The scene kind is `app`, the kind for desktop apps with a window of their own. Heroic stages nothing from the scene folder: its window is its own Electron UI.
