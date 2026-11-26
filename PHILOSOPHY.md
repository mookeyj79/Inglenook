# Inglenook: Design Philosophy

> An inglenook is the warm corner beside a big open fireplace, with a bench to sit on.

## The idea

Technology meets simple life charm. Inglenook is a cozy, soothing theme for the tools you spend all day in, so the screen feels like a calm room rather than a control panel.

It has two variants, and they are equals:

- **Inglenook Day** (light): a cabin room in natural light, with plants on the sill. A soft neutral background that leans faintly green.
- **Inglenook Night** (dark): a Victorian library and smoking lounge by the fire. A warm smoked-walnut background.

Light is not an afterthought. Both variants get the same care, the same colors by name, and the same checks. Switching between them should feel like the evening coming in, not like opening a different app.

The goal of this repo is simple: every tool I use should look like it belongs in the same room.

## Principles

1. **Eye comfort first.** Body text sits around 10:1 contrast, not more. There is no pure black and no pure white. Colors are muted and evenly matched, so none of them shouts. Alerts are calm and earthy: an error is ember, not alarm red.
2. **Sameness beats perfection.** A port that matches the others at 90% is better than one that looks amazing on its own. When in doubt, do what the other ports do.
3. **Roles, not values.** Ports never pick a color value. They pick a role or a named color, and the palette decides what that looks like.
4. **Solid first.** Every surface is a solid color. Transparency is an app setting a user may turn on; it is never part of the theme, and the theme never depends on it.
5. **Calm surface, quiet signal.** Surfaces and text stay neutral. Color is for things that mean something: state, syntax, focus.
6. **Two variants, one theme.** Anything that exists in one variant exists in the other.

## The palette

The palette has two layers. Values live only in `palette/palette.json`, as OKLCH lightness, chroma, and hue. The build turns them into hex.

### Neutrals

Nine plain-named neutrals per variant, from the surfaces to the text:

| Neutral | Used for |
|---|---|
| **deeper** | The most recessed surfaces: title bars, activity bars, the area behind panels |
| **deep** | Recessed surfaces: sidebars, panels, code blocks in prose |
| **base** | The main background, where content lives |
| **raised** | Lifted surfaces: popups, cards, inputs, menus |
| **hover** | Hovered and active rows and buttons |
| **line** | Borders and dividers. Carries no meaning |
| **faint** | Comments, placeholders, metadata |
| **dim** | Supporting text and punctuation |
| **text** | Content |

### Named colors

Twelve named colors per variant, each with a Day and a Night value:

| Color | Feels like |
|---|---|
| **firelight** | Amber glow of the fire. The one accent |
| **ember** | A coal going red |
| **oxblood** | Old leather bindings |
| **clay** | A terracotta pot |
| **brass** | A lamp base, a door handle |
| **moss** | Moss on stone |
| **ivy** | Ivy on a wall |
| **pine** | Pine needles, a green-blue |
| **steel** | A blue-gray poker |
| **dusk** | The sky after sunset |
| **heather** | Heather on a hill |
| **rosewood** | A polished rosewood table |

### Roles

Roles sit on top of the named colors. Each role points at one named color and keeps its meaning in every port.

| Role | Points at | Means |
|---|---|---|
| **accent** | firelight | "You are here": focus, cursor, selection, links, primary buttons. Nothing else |
| **on_accent** | raised (Day), deeper (Night) | Text on an accent fill |
| **error** | ember | Failure, removal |
| **warning** | brass | Caution, change |
| **success** | moss | Success, addition |
| **info** | steel | Information, in progress |
| **keyword** | heather | Keywords, booleans, constants |
| **reference** | pine | Paths, references, anchors |
| **literal** | clay | Numbers, flags, literals |
| **type** | dusk | Types |
| **tag** | rosewood | Tags, annotations, decorators |

Oxblood and ivy are detail colors for badges and small UI accents. They have no role and carry no meaning.

Ports use roles or named colors, never raw values. Prefer a role where one fits, so a port keeps working if a role ever points elsewhere.

### One accent

Firelight is the only accent. It means "you are here" and nothing else: not success, not a brand color, not decoration.

### Washes

A wash is a named color mixed into `base` at the variant's wash strength, as a solid color. It marks a line or an item without hiding the text on it: selections (a firelight wash), diff lines (moss and ember washes), find matches, chips.

### Syntax mapping

| Token | Color |
|---|---|
| Keys, properties, functions | steel (info) |
| Strings | moss (success) |
| Numbers, flags, literals | clay (literal) |
| Keywords, booleans, constants | heather (keyword) |
| Types | dusk (type) |
| Paths, references, anchors | pine (reference) |
| Tags, annotations, decorators | rosewood (tag) |
| Errors, invalid | ember (error) |
| Punctuation | dim |
| Comments | faint |

If a language has a token that does not fit, pick the closest row. Do not add a color.

### Terminal colors

| Slot | Color |
|---|---|
| red | ember |
| green | moss |
| yellow | brass |
| blue | steel |
| magenta | heather |
| cyan | pine |
| black, white | neutrals, by brightness (below) |

| Slot | Day | Night |
|---|---|---|
| black | text | raised |
| bright black | faint | faint |
| white | line | dim |
| bright white | raised | text |

Bright slots are the same hue as their normal slot, slightly stronger: Night is 0.05 lighter (at most 0.92), Day is 0.05 darker, and chroma is 1.1 times in both. The build computes them; they are not stored in the palette.

## Contrast floor

Every surface is solid and is measured as drawn.

| What | On | Floor |
|---|---|---|
| text | base | 7 (the target is about 10) |
| dim | base | 4.5 |
| faint | base | 3 |
| every named color | base | 4.5 |
| every named color | raised and deep | 3, short labels only |
| on_accent | firelight | 4.5 |
| text | a wash of any named color | 4.5 |

Short labels are inline code, badges, and a tag in a tab. Running colored text, such as code, goes on `base`. `line` carries no meaning and has no floor. `pwsh build/check.ps1` prints the measured table for both variants.

## Port tiers

Not every app can do everything. Each port declares its tier in its README.

| Tier | Name | What it delivers |
|---|---|---|
| **1** | Full | The complete palette |
| **2** | Partial | Most of the palette, with gaps the app imposes |
| **3** | Minimal | Background, accent, and status colors only |

Apps limited to 16 or 256 colors (such as less or nano) are approximate by nature, and their READMEs say so.

A port ships only when it has real screenshots of both variants, passes the checks, and the owner has approved it.

## Font

IBM Plex Mono, set in every app that allows it. Where an app shows icons (prompts, file trees, status lines), BlexMono Nerd Font, which is IBM Plex Mono with icons added. See [ADR 0006](docs/adr/0006-ibm-plex-mono.md).

## Wallpapers

Wallpapers are optional. The theme must look complete without them. When the repo ships one, it is a found image with a license that allows redistribution and a recorded credit, chosen by taste and paired Day and Night where possible.

- **Day**: sunlit cabin interiors, window light on plants, a forest seen through a window.
- **Night**: firelit or lamplit libraries and reading rooms, fireplaces.

See [ADR 0007](docs/adr/0007-wallpapers-are-found-images-chosen-by-taste.md).

## Hard no's

- **No color values outside the palette.** Ports use roles and named colors only. Wallpapers are the one exception: they are images, not colors.
- **No inventing colors in a port.** If a port truly needs a new one, it goes into the palette and becomes available to every port.
- **No single-variant ports.** Ship Day and Night together. If an app only supports one mode, say so in the README.
- **No pure black and no pure white.** Nothing here should glare.
- **No decoration.** No text glow, no gradients on text.
- **No color as the only signal** where the app gives you a second one (icon, label, shape).

## Learn from other themes

Catppuccin, Nord, Dracula, Gruvbox, Rosé Pine, and others have already ported their themes to hundreds of apps. Looking at how they did it is expected.

Before starting a port, find another theme's port for the same app and study:

- Which file format and install path they use
- Which of the app's settings they found worth theming
- How they handle light and dark together
- What they could not theme, and how they worked around it

What comes from them is the **method**. Their colors and names never come with it. If a port reuses another project's files or structure beyond the basics, check that project's license and credit it in the port README.

## What every port contains

Each port lives in its own folder: `Ports/<app_name>/`.

- A **template** that uses palette placeholders.
- **Generated output** for both variants, committed to the repo.
- A **README** that is a step-by-step install guide, with its tier and known limits.
- A **MAPPING.md** for maintainers: which color each app setting uses, and why.
- **Screenshots** of both variants, from the real app.

## Changing the palette

The palette is versioned.

- **Patch**: a value is tuned. Roles and meaning unchanged.
- **Minor**: a new role or named color is added.
- **Major**: a role changes meaning or a color is removed.

Every palette change rebuilds every port. CI fails if any committed output does not match the current palette.

## Settled questions

- **Source of truth.** OKLCH in `palette/palette.json`; hex is generated. See [ADR 0001](docs/adr/0001-oklch-is-the-source-of-truth.md).
- **Solid surfaces.** Transparency is the user's choice in their app, never the theme's. See [ADR 0002](docs/adr/0002-solid-first-transparency-optional.md).
- **Two layers.** Named colors, with roles on top. See [ADR 0003](docs/adr/0003-named-colors-with-roles-on-top.md).
- **Accent.** Firelight, and only firelight. See [ADR 0004](docs/adr/0004-one-accent-firelight.md).
- **Bright terminal colors.** Same hue, slightly stronger. See [ADR 0005](docs/adr/0005-bright-ansi-same-hue-slightly-stronger.md).
- **Font.** IBM Plex Mono. See [ADR 0006](docs/adr/0006-ibm-plex-mono.md).
- **Wallpapers.** Found images, chosen by taste. See [ADR 0007](docs/adr/0007-wallpapers-are-found-images-chosen-by-taste.md).
- **Port icons.** Single-color, colored by the page. See [ADR 0008](docs/adr/0008-port-icons-are-single-color.md).
