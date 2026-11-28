# Web: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

The port has no app slots. It exposes the palette as CSS custom properties, named `--<variant>-<name>`, where `<variant>` is `{{variant.name|slug}}` (`inglenook-day`, `inglenook-night`). Role names use a hyphen (`on_accent` is `-on-accent`).

| Property | Color | Why |
|---|---|---|
| `-deeper` to `-text` | the nine neutrals | One to one |
| `-firelight` to `-rosewood` | the twelve named colors | One to one |
| `-accent` to `-tag` | the eleven roles, as `var()` of the color they point at (`{{<role>\|name}}`) | A site that reads a role follows the palette if the role ever points elsewhere, and the file shows which color each role is |
| `-<color>-wash` | each named color with `wash` | Solid, mixed into `base` by the build |
| `-<role>-wash` | `var()` of the wash of the role's color | Every role but `on_accent`, which points at a neutral |
| `-syntax-key` | info | PHILOSOPHY's syntax table, one property per row |
| `-syntax-string` | success | |
| `-syntax-number` | literal | |
| `-syntax-keyword` | keyword | |
| `-syntax-type` | type | |
| `-syntax-reference` | reference | |
| `-syntax-tag` | tag | |
| `-syntax-error` | error | |
| `-syntax-punctuation` | dim | |
| `-syntax-comment` | faint | |

## Gaps and trade-offs

- Tier 1: every neutral, named color, role and wash is there. The port defines properties only; a site decides which elements use them.
- Property names carry the variant so both files can load together and a site switches sets without swapping stylesheets (the method of Hyaline's web port and Catppuccin's palette CSS). Plain names on `:root` would make the second file overwrite the first.
- The file is named after its variant (`template/{{variant.slug}}.css`, built as `inglenook-day.css` and `inglenook-night.css`), so the reader copies both files as they are. `{{variant.slug}}` has no `|`, which Windows does not allow in a file name.
- No `color-scheme` in the files: with both loaded, the site sets it alongside its own switch.
- No `-rgb` channel forms: the theme never sets transparency, so a site has no use for channels to add alpha to.
- The syntax properties exist so every site maps its highlighter the same way. Pygments-style class names have tokens the table has no row for; the README says to take the closest row. Hugo's Chroma gives YAML and JSON keys the same class as HTML tags (`.nt`), so a site has to pick one for both (the mikewashere.com mock picked `-syntax-key`).
- Shadows: a shadow would need a transparent color. The README says to draw edges with `-line` borders instead.
- Not in the scene: `deeper` (the page's most recessed area, its header, is `deep`), a focus ring (a focused field needs a blinking caret, which fails a take), the washes of clay, oxblood, ivy, pine, steel, dusk, heather and rosewood, and `-syntax-error`. They follow the same roles as what the scene shows.

## Research

- Catppuccin's palette CSS (https://github.com/catppuccin/palette) names properties `--ctp-<flavor>-<color>` and loads every flavor at once. This port takes the same method: one prefix per variant.
- Hyaline's web port (the previous theme, `Ports/web` there): two files of variant-prefixed properties and a demo site in Chromium for the shots. Method only; its glass forms (rgba, blur, tint) are dropped, since Inglenook is solid.
- The mikewashere.com mock (PaperMod) used a hand-written version of these properties: page base, cards raised with a line border, header, footer and code deep, tags on hover, selection on the firelight wash, no shadows. The demo page follows the same choices.
- Pygments short class names (https://pygments.org/docs/tokens/) are shared by Pygments, Rouge and Hugo's Chroma, so the README's highlighter example uses them.

## Screenshot recipe

- The port needs no login or license, and has no app of its own: the recipe shoots the web scene in the Photographer's pinned Chromium (`chromium` in `build/photograph/pins.json`, Mint 22.3's package). The recipe has no `version`; the pins file pins the browser and the Ubuntu package date pins the font package.
- **apply** follows Install: steps 2 and 3 are the two `cp` lines, into `~/site/css`.
- **Scripted stand-ins** (not tested by hand):
  - Step 1 (download or clone the repo) is the repo the Photographer mounts.
  - Steps 4 and 5 (link both files, use the properties) are the scene's own page, `build/photograph/scenes/web/web/`: `index.html` links both files before `site.css`, and `site.css` maps the properties once, with the Night set under `:root[data-theme="night"]`. The page sets `data-theme` from `#day` or `#night` in its address, as a site's own switch would.
  - Set the font: `install` adds Ubuntu's `fonts-ibm-plex` so the page finds IBM Plex Mono (and IBM Plex Sans for prose) without the network, in place of the Google Fonts link or `@font-face` files.
- **launch** runs `scenes/web/browser.sh`: Chromium as an app window (no toolbar) with the stock frame, 1200x660 at scale 1, centered, with no first-run page, sync, updates or background networking.
- **Shown:** base (page), deep (header, footer, code block, inline code), raised (the Checks card, tag pills), hover (the current menu item), line (every border and divider), text, dim (lead, menu, tags, code punctuation), faint (date line, comment, footer, card note), accent (the link, the button) with on_accent, the accent wash (a selected phrase), the error and success washes (diff lines), the warning wash (the note), error, warning, success and info (the Checks list, each with a word as well as a color), oxblood and ivy (badges), and the syntax colors for keys and functions, strings, numbers, keywords, types, references (a path) and tags (an attribute).
