# Jellyfin: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Since 12.0, Jellyfin's themes (Dark, Light and the rest) read MUI CSS variables named `--jf-palette-*`, set per theme on `[data-theme="<id>"]` on `<html>`. The template sets them on `:root[data-theme]`, which outranks the theme's own selector, so the port looks the same whichever Jellyfin theme is picked. Then it overrides, by selector, the rules that use a hard-coded color or an alpha channel.

| App setting | Color | Why |
|---|---|---|
| `background-default` (page, drawer, dialogs' page) | base | |
| `background-paper`, `.dialog`, `.paperList`, `.visualCardBox`, `.collapseContent`, selects, `.toast` | raised | Popups, cards, inputs |
| `AppBar-defaultBg`, `AppBar-transparentBg` (header) | deeper | Title bar. The transparent header is made solid |
| Dialog header and footer, `.detailRibbon`, `.appfooter`, `.nowPlayingBar`, card padders and the five `defaultCardBackground` classes | deep | Recessed bars and the slot behind a poster |
| `action-hover`, `action-focus`, hovered rows, menu items and icon buttons, `Button-inheritContainedHoverBg`, `FilledInput-hoverBg` | hover | |
| `divider`, `FilledInput-borderColor`, guide cell borders, scroll bar thumb, slider track | line | |
| `text-primary`, titles, card text, list text | text | |
| `text-secondary`, labels, field help, tabs, `action-active` | dim | |
| `text-disabled`, `action-disabled`, card placeholder icons, the unplayed part of a slider | faint | |
| `primary-*`, `secondary-*` (main, light, dark) | accent | Jellyfin uses primary for buttons and progress and secondary for focus. Both are "you are here" |
| `primary-contrastText`, `secondary-contrastText`, and every other `contrastText` | on_accent | Text on a filled button |
| Links, focused labels and fields, checked boxes, sliders, switches, spinners, progress bars, the selected menu item, the active tab, **Save** and other submit buttons, focused cards | accent | |
| `action-selected`, `::selection`, radio focus ring | accent wash | Selection is a firelight wash |
| `error-*`, delete and shutdown buttons, the recording progress bar, the important-notification icon | error | |
| `warning-*` | warning | |
| `success-*` | success | |
| `info-*` | info | |
| `Alert-<state>FilledBg` with `Alert-<state>FilledColor`, `.infoBanner` | the state's wash, with text | Calm banners, text stays readable |
| `SnackbarContent-bg` with `-color` | raised with text | |
| Played, count, sync and media-source badges | accent with on_accent | Jellyfin draws them in its primary color; kept for sameness with the app |
| Played check and favorite heart when on | oxblood | Detail color. Jellyfin draws them red, which here would read as an error |
| Rating star | brass | The slot is about the color itself (a gold star) |
| `.mediaInfoText` (rating and resolution chips) | raised with dim | Chips |
| Live TV guide: sports, movie, kids, news | dusk, heather, pine, ivy washes | Categories with no meaning, told apart by hue; text stays on a wash |
| Guide: the program on now | hover | |
| Book, comic and PDF readers | base | |

## Gaps and trade-offs

- Tier 2. Jellyfin Web has no syntax, so the syntax colors are unused, and Jellyfin has no search-match highlight, so ADR 0009 does not apply.
- One file per variant. The custom CSS fields hold one stylesheet, and the build renders one variant per file, so a single file that switches on Jellyfin's Light and Dark themes is not possible. The README pairs Day with Jellyfin's Light theme and Night with Dark, so the browser's `color-scheme` and anything Jellyfin draws outside the variables match the variant.
- The server-wide field (Dashboard > Branding) holds one variant for everyone; a user can override it with their own Custom CSS code and the "Disable server-provided custom CSS code" switch. The README gives the per-user route first.
- MUI builds tints from `*Channel` variables (`rgba(var(--jf-palette-primary-mainChannel) / <opacity>)`). Their format is space-separated channels, which no placeholder filter writes, and setting them would be transparency anyway. The template overrides the Legacy rules that use them with solid colors instead. In the default Modern layout (12.0+), MUI components still use them, so some hover and selection tints stay Jellyfin's blue. The README says the theme is made for the Legacy and TV layouts, as Catppuccin does.
- `primary-dark` (submit-button hover) is set to accent too: the palette has one firelight, and a darker one would be an invented color.
- Backdrops: with Backdrops on, Jellyfin draws the page at 86% opacity over the title's art. That is the app's own setting, so the README lists it as the optional see-through extra. The theme sets no transparency; the detail ribbon's 80% tint is replaced by solid deep.
- Shadows on raised buttons and switch thumbs are left as Jellyfin draws them (neutral black at low alpha); the theme adds none.
- The font is left alone: Jellyfin Web shows no code. The README gives an optional `font-family` line.

## Research

- Catppuccin for Jellyfin (https://github.com/catppuccin/jellyfin, MIT, Copyright (c) 2021 Catppuccin): a `theme.css` of selector overrides plus one small file of variables per flavor, loaded by `@import` from its own GitHub Pages site and pasted into Settings > Display > Custom CSS code. This port takes its list of selectors (sliders, spinners, switches, radios, progress bars, badges, guide cells, list icons, raised buttons) as the starting point. Its colors, names and translucent backgrounds are not used. It tells Jellyfin 12+ users to pick the TV or a Legacy display mode; this port does the same.
- No `@import` from a CDN: the README has the reader paste the file itself, as the Jellyfin docs warn that external resources are loaded by each client and break when unreachable. A raw GitHub URL of `dist/<variant>/jellyfin.css` would also work in an `@import`, but GitHub serves raw files as `text/plain`, which browsers refuse as a stylesheet, so the paste route is the only one the README gives.
- Jellyfin 12.4's web client (the server's `jellyfin-web` folder, read as data): `themes/<id>/theme.css` lists every variable the Legacy layout reads and the rules with hard-coded colors; `main.jellyfin.bundle.js` sets `cssVarPrefix: "jf"` and `colorSchemeSelector: '[data-theme="%s"]'`, and inserts the server's CustomCss and then the user's custom CSS as `<style>` elements after the theme. Menu and field names in the README come from its English strings (`Display mode`, `Desktop (Legacy)`, `Custom CSS code`, `Disable server-provided custom CSS code`).
- Official docs: https://jellyfin.org/docs/general/clients/css-customization/ (where the two fields are, load order, external resources) and https://jellyfin.org/posts/jellyfin-release-12.0/ (Modern and Legacy layouts, themes built on CSS variables).

## Screenshot recipe

- Manual. Jellyfin is free and needs no license (GPL-2.0), but its themed pages need a running Jellyfin server, its first-run setup wizard, and a signed-in account (https://jellyfin.org/docs/general/post-install/setup-wizard/). Its server also refuses to start without FFmpeg. Running the server inside the Photographer and signing in automatically was tried and set aside: it needs FFmpeg in the image and a scripted sign-in, beyond the port's time box.
- Suggested shot, for both variants: Settings > Display, with Display mode set to Desktop (Legacy), the variant's file pasted in Custom CSS code, the drawer open, and one field focused, so the header, drawer, inputs, a checkbox, the Save button and the focus color all show.
