# Homepage: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Homepage colors almost everything through Tailwind classes `theme-50` to `theme-900`, which read the custom properties `--color-50` to `--color-900` as space-separated `r g b` channels (`rgb(var(--color-500) / 1)`, mixed toward transparent for `/10`-style classes). The palette build has no space-separated filter, so the file sets each one as relative color syntax, `from #rrggbb r g b`, which drops into `rgb(...)` as a valid color. That remaps every widget the file does not name, then the rules below make the main surfaces solid and give the roles their places.

| App slot | Color | Why |
|---|---|---|
| `--color-50` to `-900`, `:root.light` | base, raised, hover, line, faint, faint, dim, text, text, text | Light mode uses 50 for the page and 700 to 900 for text |
| `--color-50` to `-900`, `:root.dark` | text, text, text, dim, faint, faint, line, hover, base, deep | Dark mode uses 800 for the page and 200 to 300 for text. Both blocks are in both files, so a mismatched `theme:` still reads |
| `--bg-color`, `html`, `body` | base | |
| `--color-logo-start`, `-stop` | faint | The fallback logo's gradient, flattened to one color |
| scrollbar thumb, track | line, deep | |
| `::selection` | accent wash, text | |
| focus outline | accent | |
| `.service-card`, `li.bookmark > a` | raised, line border; hover on hover | Solid instead of Homepage's translucent white or theme wash |
| service and bookmark names, group names | text | |
| descriptions | dim | |
| `.bookmark-icon` (abbreviation box) | deep, dim text | |
| `.service-block` (widget values) | deep, text value, dim label | |
| block highlight `good`, `warn`, `danger` | success, warning, error washes, text | Homepage's default classes are emerald, amber and rose tints |
| ping, site monitor, Docker, Kubernetes, Proxmox status | deep tag; success (up, running), error (down, error), warning (unhealthy, exited, partial), info (starting), faint (unknown) | Text and dot styles |
| boxed widgets (`.widget-container`, `.information-widget-form`, `.information-widget-container-button`) | raised, line border | |
| search widget input | raised, line border, faint placeholder, accent border on focus | |
| search provider button | hover, dim | |
| tab strip `#myTab` | deep, line border | |
| current tab | raised, accent underline, text | "You are here", the same as VS Code's active tab border |
| hovered tab | hover | |
| resource bars | line track, info fill | In progress, not success |
| quick launch backdrop | deeper, solid | Homepage dims the page with a half-transparent gray |
| quick launch dialog, input | raised, line border | |
| quick launch selected result | accent, on_accent | The result Enter opens |
| quick launch match | steel wash, text | ADR 0009 |
| footer icons | faint, accent on hover | |
| config error boxes | error wash, warning wash, text | |
| link underline | accent | |

## Gaps and trade-offs

- Tier 2: the neutrals, roles and washes cover Homepage's own surfaces, but service widgets hard-code Tailwind colors (emerald, rose, amber, blue and more) for charts, badges and some values. Remapping every one would mean chasing each widget's classes; the file covers the shared status components and block highlights instead.
- Solid: Homepage draws cards as `bg-white/5` or `bg-theme-100/20` and offers `cardBlur`. The file sets every card, tab strip and boxed widget to a solid surface, removes `backdrop-filter` and drops `shadow-md` and `shadow-lg` (shadows need a transparent color). Classes the file does not name that still use a `/NN` opacity now mix palette neutrals over a solid page.
- One file per variant, because Homepage reads one `custom.css`. The `theme:` line picks Tailwind's `dark:` classes; both scale blocks are in each file so the wrong mode still reads. Homepage itself follows `prefers-color-scheme` when no `theme:` is set (`src/utils/contexts/theme.jsx`), so a future version could scope Day to `:root.light` and Night to `:root.dark` and have the reader join both files into one `custom.css`. Not done here: it doubles the install steps.
- Relative color syntax needs Chromium 119, Firefox 128 or Safari 18. The README says "a browser from 2024 or later".
- The sign-in page (`pages/auth/signin.jsx`) uses `bg-white/80`, `slate-950/70` and blur directly; it picks up the scale and text colors only.
- Not in the scene: the block highlight washes (the custom API widget cannot highlight, and every other widget calls a real service), warning and info status, the quick launch dialog, resource bars, selection and focus (a focused field needs a blinking caret, which fails a take), the config error boxes, and hover.

## Research

- Catppuccin has no Homepage port (checked github.com/catppuccin and catppuccin.com/ports, November 2026).
- Dracula for Homepage (https://github.com/dracula/homepage-app, MIT): one `custom.css` that redefines the `--color-*` channels inside `.theme-gray` and then targets `.service-card`, `.service-block`, `.bookmark-icon`, `li.bookmark > a`, `#information-widgets`, `.resource-usage` and the status color classes. This port takes that layout: the scale first, then the components. Its colors and translucent card values are not used, and the scale here applies to any `color:` (`:root.light` and `:root.dark` outrank `.theme-<color>`), so the README does not ask for a palette.
- Homepage 2.8.0 source (https://github.com/gethomepage/homepage/tree/v2.8.0): `src/styles/theme.css` (the palettes), `src/styles/globals.css` (`--bg-color` and scrollbars per mode), `src/utils/contexts/theme.jsx` (`light`/`dark` class on `html`), `src/utils/highlights.js` (block highlight classes), `src/components/services/{ping,site-monitor,status}.jsx` (status classes). The built CSS compiles `bg-theme-100/20` to `color-mix(in oklab, rgb(var(--color-100)/1) 20%, transparent)`.

## Screenshot recipe

- Homepage needs no login or license: it is Apache-2.0 and its optional authentication is off by default (https://gethomepage.dev/configs/settings/).
- **install** puts Homepage 2.8.0 in `/opt/homepage` without Docker-in-Docker: it fetches the three `app/` layers of the official image (`ghcr.io/gethomepage/homepage:v2.8.0`, linux/amd64 manifest) from the registry by digest, checks each against its digest, and runs it with Node.js 24.22.3 from nodejs.org, checked by hash. The image's builder stage is Debian-based, so its native modules run on Mint. The `version` field is the Homepage version; the layer digests pin it.
- **apply** follows Install: step 4 is the `cp` of `custom.css`, step 6 the `theme:` line.
- **Scripted stand-ins** (not tested by hand):
  - Step 7 (reload) is the browser opening the dashboard after the server starts.
  - Set the font: `font: plex` is in the scene's `settings.yaml`.
- **stage** (`scenes/web/homepage/stage.sh`) adds the scene's settings (layout, tabs, `statusStyle: dot`, `font: plex`, `disableUpdateCheck`) to `settings.yaml` and copies services, bookmarks and two information widgets (greeting and search). Nothing calls the network: site monitors point at Homepage itself (up) and a closed local port (down), and the custom API widget reads a fixed JSON file served on port 8130. Status dots instead of response times, and no clock or resource widget, so the page holds still.
- **launch** runs `serve.sh` (Homepage on 127.0.0.1:3000, the JSON on 8130) and then the web scene's Chromium at the dashboard.
- **Shown:** base (page), deep (tab strip, status tags, widget blocks, bookmark abbreviations), raised (cards, boxed widgets, search input, current tab), hover (search provider button), line (every border), text, dim (descriptions, block labels), faint (search placeholder), accent (current tab underline), success (up dots), error (the down dot).
