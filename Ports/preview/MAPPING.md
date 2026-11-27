# Preview site: color mapping

For maintainers. What visitors read is [README.md](README.md).

The preview is not an app port. It is unlisted in `Ports/ports.json`, so it has no `port.json` and no tier. Its pages are built from `template/` like any port, and `build/site.ps1` publishes them with the port list and the install guides (`site.json`).

## How both variants share a page

`template/theme.css` sets every palette color as a CSS variable on `[data-variant="<key>"]`. Every page loads both variants' `theme.css`, so any element with `data-variant` takes that variant's colors. The demos on the index page carry their own `data-variant`, and the page hides the ones that don't match the chosen variant, so the switch (`variant.js`) swaps the whole page.

## Color mapping

| Page part | Color | Why |
|---|---|---|
| Page and demo background | `base` | |
| Panels, inputs, secondary buttons | `raised` | |
| Top bar, window title bars | `deeper` | |
| App sidebar, problems bar, code blocks in guides | `deep` | |
| Hover | `hover` | |
| Borders | `line` | |
| Supporting text | `dim` | |
| Comments, section labels, placeholders | `faint` | |
| Links, focus, cursor, primary button, switch | `accent`, `on_accent` | One accent, "you are here" |
| Selection and the selected row | `firelight` wash | Text stays `text` on it |
| Chips | the color's wash, its border in the color | Text on a wash is checked at 4.5 |
| Warning notice | `brass` wash, `warning` border | |
| Terminal | `ansi.*` | |
| Diagram nodes | `raised`, `faint` border | |
| Diagram groups | `deep`, `line` border | |
| Diagram lines and edge labels | `dim` lines, `text` labels on `base` | |
| Diagram status nodes | the role's wash, its border in the role | Each label also says its status in words |
| Diagram notes | `raised`, `tag` border | Notes are annotations |
| Back button on guides | `raised`, `line` border, `hover` | |
| Ornaments: corner brackets, frame corners, divider, diamonds | `oxblood` | A detail color with no role, so decoration never reads as state |
| Favicon | `firelight` | The site's mark, one per variant; `variant.js` swaps it with the switch |
| Code | the syntax mapping in PHILOSOPHY.md | |

## Gaps and trade-offs

- Swatch values and contrast on the index page are read from the page's own colors by a short script, so they always match the build. Without JavaScript the swatches show only the color.
- Mermaid takes color values, not CSS variables, so a short script reads each variant's palette variables and passes them to Mermaid's `base` theme. Offline or without JavaScript, the diagram shows its source.
- The role table shows each role's color by name through CSS `content`, from the `|name` filter in `theme.css`.
