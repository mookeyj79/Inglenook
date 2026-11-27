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
The single-color mark on a port's card on the ports page, colored by the page. A brand mark or a glyph. A port without one shows its category's icon, a glyph; the monogram stands in only when an icon fails to load.
_Avoid_: Logo, favicon

**Preview site**:
The published pages built from `Ports/preview/`: the landing page with live demos of both variants, the ports page, and one install-guide page per port.

## Screenshots

**Photographer**:
The shared part that reads a recipe and takes a port's Day and Night screenshots (`build/photograph.ps1`). It owns everything the scene fixes and everything that is the same for every port.
_Avoid_: Runner, shooter

**Recipe**:
A port's instructions for its screenshot (`screenshot.json`): which scene kind and platform it is shot on, any host, and how to install the app, apply the port, stage and launch it, and find its window.
_Avoid_: Script, screenshot config

**Scene**:
What a port's screenshot shows: the staged content, window size, font, frame and backdrop. Set per scene kind and the same for every port of that kind.
_Avoid_: Demo, sample

**Scene kind**:
The group a port belongs to for its scene: terminal, prompt, CLI/TUI, editor, icon theme, document, desktop or web.

**Backdrop**:
What is behind every shot of a variant: that variant's wallpaper, shown as it is: Cabin Seating in Day and Mission Fireplace in Night. The preview site shows the same pair behind its page.

**Host**:
The app a port lives inside, shot wearing its own Inglenook port in the same variant. A prompt is hosted by a terminal, an icon theme by an editor.

**Shot list**:
The preview's own list of screenshots of its page (`shots.json`), in place of a recipe.

**Stale**:
Said of a port whose screenshots were made from inputs that have since changed, or that has no screenshots.
_Avoid_: Outdated, dirty

**Pin**:
The exact version of an app, font or base that a port's screenshots are made with. It stays until someone moves it on purpose, which makes the ports that use it stale.
_Avoid_: Lock, freeze

## Wallpapers

**Wallpaper**:
An optional found image that goes with the theme, marked with the variant it suits: day, night, or both.
_Avoid_: Background image

**Wallpaper pair**:
Two wallpapers of the same kind of scene, one for Day and one for Night.

**Web copy**:
A smaller copy of a wallpaper in `wallpapers/web/`, made by `build/wallpaper.ps1 -Web`, for the preview site.
