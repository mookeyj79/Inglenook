# Inglenook

A cozy color theme in two variants, ported to many apps, so every tool on the machine feels like one calm room.

## Theme

**Theme**:
Inglenook as a whole: one palette shipped as two variants.
_Avoid_: Skin, scheme

**Variant**:
One of the two looks of the theme: Inglenook Day or Inglenook Night. They are equals and always ship together. Its key is `day` or `night`; its mode is `light` or `dark`.
_Avoid_: Flavor, mode (mode is only the light or dark label)

**Palette**:
The single source of every color value, for both variants, written as OKLCH in `palette/palette.json`.

**Neutral**:
One of the nine plain-named grays of a variant: deeper, deep, base, raised, hover, line, faint, dim, text. Surfaces, borders, and text.
_Avoid_: Background color, gray

**Named color**:
One of the twelve themed colors of a variant, such as firelight, moss, or heather. Each has a Day and a Night value.
_Avoid_: Hue, swatch

**Role**:
A named job, such as `error` or `keyword`, that points at a named color (or, for `on_accent`, a neutral). Its meaning is the same in every port.
_Avoid_: Token, semantic color

**Detail color**:
A named color with no role: oxblood and ivy. Used for badges and small accents, never to carry meaning.

**Accent**:
The role that means "you are here": focus, cursor, selection, links, primary buttons. Always firelight.
_Avoid_: Highlight, primary color

**Wash**:
A named color mixed into `base` at the variant's wash strength, as a solid color. Marks a selection, a diff line, or a chip without hiding the text on it.
_Avoid_: Tint, highlight color

**Contrast floor**:
The lowest contrast a color may have on a surface, as listed in PHILOSOPHY.md. Measured on solid surfaces, as drawn.

**Gamut warning**:
A note from the check that a color lies outside what sRGB screens can show and was clamped. A warning, never a failure.

**Bright ANSI color**:
A terminal's bright slot: the same hue as its normal slot, slightly stronger. Computed by the build, not stored.

## Ports

**Port**:
Inglenook applied to one app, with its own folder, templates, generated output, screenshots, and install guide.
_Avoid_: Theme (for a single app), plugin

**Shell file**:
The file a port ships for a tool that takes its colors from the shell, named after the tool: `<tool>.sh` for bash and zsh, `<tool>.zsh` for Zsh only, `<tool>.ps1` for PowerShell. The user sources it from their profile. Built from a `<tool>.env` when the tool takes environment variables.
_Avoid_: Theme file (Nowhere's name for its own hook file), snippet

**Tier**:
The grade a port declares for how much of the palette the app allows: Full, Partial, or Minimal.

**Full**:
Tier 1. The complete palette.

**Partial**:
Tier 2. Most of the palette, with gaps the app imposes.

**Minimal**:
Tier 3. Background, accent, and status colors only.

**Port icon**:
The single-color mark on a port's card on the ports page, colored by the page. A brand mark or a glyph. The monogram stands in when there is none.
_Avoid_: Logo, favicon

**Preview site**:
The published pages built from `Ports/preview/`: the landing page with live demos of both variants, the ports page, and one install-guide page per port.

## Wallpapers

**Wallpaper**:
An optional found image that goes with the theme, marked with the variant it suits: day, night, or both.
_Avoid_: Background image

**Wallpaper pair**:
Two wallpapers of the same kind of scene, one for Day and one for Night.
