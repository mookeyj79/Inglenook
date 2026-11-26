# Preview site: color mapping

For maintainers. What visitors read is [README.md](README.md).

The preview is not an app port. It is unlisted in `Ports/ports.json`, so it has no `port.json` and no tier. Its pages are built from `template/` like any port, and `build/site.ps1` publishes them with the port list and the install guides (`site.json`).

## How both variants share a page

`template/theme.css` sets every palette color as a CSS variable on `[data-variant="<key>"]`. Every page loads both variants' `theme.css`, so any element with `data-variant` takes that variant's colors. The demos on the index page carry their own `data-variant`, so they always show Day and Night side by side. The page frame follows the switch (`variant.js`).

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
| Code | the syntax mapping in PHILOSOPHY.md | |

## Gaps and trade-offs

- Swatch values and contrast on the index page are read from the page's own colors by a short script, so they always match the build. Without JavaScript the swatches show only the color.
- The role table shows each role's color by name through CSS `content`, from the `|name` filter in `theme.css`.
