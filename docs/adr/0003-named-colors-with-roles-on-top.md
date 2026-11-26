# Named colors, with roles on top

The palette has two layers. Nine plain-named neutrals and twelve themed named colors hold the values. Roles such as `error` or `keyword` sit on top and point at a named color. `on_accent` points at a neutral, `raised` in Day and `deeper` in Night.

Names give the theme its character and make the palette easy to talk about ("make moss a little warmer"). Roles keep meaning stable across ports: every port uses `error` for failure, whatever color that is.

## Consequences

- Ports may use roles or named colors, never values. A role is preferred where one fits.
- Two named colors, oxblood and ivy, are detail colors with no role. They are for badges and small accents, and carry no meaning.
- Every named color, role or not, must pass the contrast floor, since any of them may be used as text.
- A role always points at the same named color in both variants, except `on_accent`, which may differ per variant.
