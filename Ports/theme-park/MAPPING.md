# theme.park: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

The port is one theme option per variant: the variables theme.park's per-app base CSS reads (`css/theme-options/*.css` in theme.park's repo). The file name is `{{variant.slug}}.css`, so a self-hosted theme.park lists it as `inglenook-day` and `inglenook-night`.

| Variable | Color | Why |
|---|---|---|
| `--main-bg-color` | base | The app's page |
| `--modal-bg-color` | deep | Catppuccin's structure: modals sit a step below the page, so the raised buttons and menus inside them still read as lifted |
| `--modal-header-color`, `--modal-footer-color` | deeper | A step below the modal body |
| `--drop-down-menu-bg` | raised | Menus are lifted |
| `--button-color` | raised | Ordinary buttons are neutral, as in Catppuccin's port; theme.park colors primary buttons, toggles and progress from `--accent-color` |
| `--button-color-hover` | hover | |
| `--button-text`, `--button-text-hover` | `var(--text)`, `var(--text-hover)` | |
| `--accent-color` | accent, as `r, g, b` (`{{accent\|rgb}}`) | theme.park reads it as channels inside `rgb()`. Focus, toggles, active tabs, progress, icons: "you are here" and primary actions |
| `--accent-color-hover` | `rgb(var(--accent-color))` | theme.park's own options set this to the accent at 0.8 alpha. Solid here: the same accent |
| `--link-color`, `--link-color-hover` | accent | Links are firelight. Catppuccin uses its text color for links and its accent on hover; Inglenook links are always the accent |
| `--label-text-color` | on_accent | Text on accent labels and badges. theme.park's own options use near-white here, which glares on the Day accent |
| `--text`, `--text-hover` | text | |
| `--text-muted` | dim | Supporting text and placeholders. Dim rather than faint because the same variable colors secondary labels, not just placeholders |
| `--arr-queue-color` | info | The Servarr apps' queue (downloads in progress). In progress is info. Catppuccin uses its green |
| `--plex-poster-unwatched` | ivy | A badge on posters that carries no state, so a detail color |
| `--gitea-color-primary-dark-4` | `var(--accent-color)` | Same as Catppuccin and theme.park's own options |
| `--overseerr-gradient` | `linear-gradient(var(--main-bg-color), var(--main-bg-color))` | Overseerr needs a gradient here. A gradient of one solid color is a solid page |
| `--petio-spinner` | not set | It is a CSS `filter` chain that tints Petio's spinner from black. Those numbers encode a color outside the palette, so the port leaves it out and the spinner keeps its own color |

## Gaps and trade-offs

- Tier 2. theme.park's theme options are about fifteen variables: surfaces, buttons, text, links and one accent. Status colors (errors, warnings, health), charts, syntax and posters stay as each app or base file draws them.
- theme.park's base CSS sets `--transparency-dark-*` and `--transparency-light-*` (black and white at 5 to 95% alpha) and lays them over sidebars, headers, rows and menus. They are not part of a theme option and the port does not override them: making them solid would hide what sits under them. The README names this under Known limits. It shows most in Day, where dark tints turn the File Browser header and sidebar gray.
- theme.park is built for dark themes (Catppuccin says so for its light flavor). Some base files use white text or light tints that assume a dark page. Day ships anyway, with the limit in the README.
- File Browser's breadcrumb bar comes from File Browser's own light or dark mode, not from theme.park: near-white in Day, a dark blue-gray in Night. The scene sets the mode to match the variant (dark for Night), as a reader would; with the light mode, Night showed a white bar.
- Not in the scene: modals, menus, buttons and their hover (`--button-*`, `--modal-*`, `--drop-down-menu-bg`), links (File Browser shows none in the listing), `--label-text-color`, and the app-specific specials (Servarr queue, Plex, Gitea, Overseerr). They follow the same roles as what the scene shows.

## Research

- Catppuccin for theme.park (https://github.com/catppuccin/theme.park, MIT): a whiskers template that writes one theme option per flavor, now shipped inside theme.park as community themes. This port takes its variable list and its structure (modal below the page, neutral buttons, specials block), with every color replaced. Its FAQ notes that theme.park has no real support for light themes.
- theme.park itself (https://github.com/themepark-dev/theme.park, MIT): `css/theme-options/` and `css/community-theme-options/` hold the variable files, `themes.py` generates one `css/base/<app>/<theme>.css` wrapper per app and theme, and the Docker mods inject `css/base/<app>/<app>-base.css` followed by `css/theme-options/<TP_THEME>.css` from `TP_DOMAIN`. Checked against `docker-mods/sonarr`.
- Nord (theme.park's own `nord.css`) colors buttons with its accent; Catppuccin keeps them neutral. This port follows Catppuccin.
- Official docs: setup (https://docs.theme-park.dev/setup/) for the Docker mod, Nginx and SWAG `sub_filter`, Stylus and self-hosting, and custom themes (https://docs.theme-park.dev/custom/), which says a custom theme only changes the color variables, keeps the `r, g, b` format of `--accent-color`, and can be tried in Stylus by pasting the theme option.

## Screenshot recipe

- theme.park needs no login or license. The scene app is File Browser (https://github.com/filebrowser/filebrowser, Apache 2.0), one of the apps theme.park supports, a single binary that serves a folder with no account (`--auth.method=noauth`, https://github.com/filebrowser/filebrowser/blob/master/docs/authentication.md).
- **version** pins File Browser (2.63.23, checked by sha256). The base CSS is pinned to theme.park's `live` branch at commit `edfecada` (checked by sha256), the minified copy theme-park.dev served on 2026-11-27 with its imports inlined.
- **Scripted stand-ins** (not tested by hand):
  - Install, Stylus steps 4 and 5 (import the base CSS, paste the theme) are `apply`: the base CSS followed by the variant's file, concatenated into one stylesheet.
  - That stylesheet reaches the page through File Browser's own branding folder (`custom.css`, https://github.com/filebrowser/filebrowser/blob/master/docs/customization.md) in place of Stylus, the Docker mod or `sub_filter`, which all add the same two stylesheets.
  - File Browser's own mode (Settings, Global Settings) is set to dark for Night and light for Day in the scene's database.
- `build/photograph/scenes/web/theme-park/`: `stage.sh` writes a small folder with fixed dates and File Browser's database (absolute dates, no disk-usage meter, no external links); `serve.sh` starts File Browser on 127.0.0.1:8080 and opens it in the web scene's browser.
- **Shown:** base (the listing), the accent (folder and file icons, header buttons, the sort arrow, sidebar icons), text (file names), dim (sizes and dates), and theme.park's dark tints over the header and sidebar.
