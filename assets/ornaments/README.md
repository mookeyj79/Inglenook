# Ornaments

Filigree for themes and pages: corner brackets, botanical frame corners, a divider, diamonds, and two repeating backdrops.

Every file is a single-color shape filled with `currentColor`, so whatever uses it picks the color from the palette. On a web page, draw one through a CSS mask filled with a palette color:

```css
.flourish {
  background: var(--oxblood);
  mask: url("divider.svg") center / contain no-repeat;
}
```

| File | What it is |
|---|---|
| `bracket-tl.svg`, `bracket-tr.svg`, `bracket-bl.svg`, `bracket-br.svg` | Corner brackets for a panel, one per corner |
| `frame-oak.svg` (top left), `frame-acanthus.svg` (top right), `frame-fern.svg` (bottom left), `frame-ivy.svg` (bottom right) | Botanical frame corners for a picture or a panel |
| `divider.svg` | A fleur-de-lis divider |
| `diamond.svg`, `diamond-half.svg`, `diamond-empty.svg` | Diamonds for a rating: full, half, and empty |
| `backdrop-damask.svg` | A damask tile, 120 by 120 |
| `backdrop-filigree.svg` | A filigree tile in a half-drop repeat, 240 by 160 |

From [MikeWasHere](https://mikewashere.com/).
