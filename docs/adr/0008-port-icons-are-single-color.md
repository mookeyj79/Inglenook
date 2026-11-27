# Port icons are single-color and follow the palette rule

The ports page shows each port as a card. A port can have an icon on its card. Icons follow the palette rule: an icon is a single-color SVG shape with no color of its own, and the page tints it with `text`. Full-color app logos are out: they would need an exemption, and they would clash with each other and with the calm of the page.

Icons come from two open sets, in this order:

1. **Brand mark** from [Simple Icons](https://simpleicons.org/) (CC0), when it has the app and the app's own license or brand guidelines allow its mark to be shown.
2. **Glyph** from [Lucide](https://lucide.dev/) (ISC), a symbol for what the app is, when there is no usable brand mark.

Every category has an icon too, always a glyph. A port with no icon of its own shows its category's icon, so every card has a shape rather than a mix of shapes and letters. The monogram is left only for an icon that fails to load.

## Consequences

- Each icon is `Ports/<app_name>/icon.svg`, and its credit is the `icon` object in `port.json`. `check.ps1` requires both or neither.
- Each category icon is `Ports/categories/<category>.svg`, and its credit is under `categoryIcons` in `Ports/ports.json`. `check.ps1` requires one for every category.
- `check.ps1` rejects any icon with a color value other than `currentColor` or `none`, anything beyond basic shapes, or a viewBox other than `0 0 24 24`.
- `build/icon.ps1` searches both sets and fetches an icon at a pinned version, for a port (`-Port`) or a category (`-Category`). The `port-icon` skill walks through the choice.
