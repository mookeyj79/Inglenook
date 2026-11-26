# Contributing to Inglenook

Thanks for helping. Inglenook only works if every port looks like it belongs in the same room, so the rules below are strict. Read [PHILOSOPHY.md](PHILOSOPHY.md) first: it is the source of truth for every design decision.

## Ways to help

- **Port Inglenook to an app.** See [Add a port](#add-a-port).
- **Fix a port** that looks wrong, is out of date, or has unclear install steps.
- **Suggest a wallpaper.** See [Add a wallpaper](#add-a-wallpaper).
- **Propose a palette change.** See [Change the palette](#change-the-palette).
- **Report a problem** in [GitHub Issues](https://github.com/mookeyj79/Inglenook/issues). Include the app, its version, the variant, and a screenshot.

## Rules every port follows

1. **No color values outside `palette/palette.json`.** Templates use placeholders only. No hex, `rgb()`, `hsl()`, or named CSS colors. Wallpapers are the one exception ([ADR 0007](docs/adr/0007-wallpapers-are-found-images-chosen-by-taste.md)).
2. **Never invent a color.** If a port needs something the palette lacks, open an issue proposing a palette change.
3. **Never edit `dist/` by hand.** Change the template or the palette, then rebuild.
4. **Both variants or neither.** If the app supports only one mode, ship that one and say so in the port README.
5. **Roles keep their meaning.** Ember is failure, moss is success, brass is a warning. Do not reassign a role because it looks nicer.
6. **Solid surfaces only.** The theme never sets transparency.
7. **Do not guess an app's theme format.** Follow the app's official docs and link them in the port README.
8. **Every port gets its own folder and its own README**, written as a step-by-step install guide.
9. **Real screenshots of both variants**, and the owner's approval, before a port ships.

Studying how Catppuccin, Nord, Dracula, and other themes ported to the same app is expected. Borrow their method, never their colors or names, and credit them if you reuse more than the basic structure.

## Layout and build

```
palette/palette.json          every color as OKLCH, for both variants, and the roles
Ports/<app_name>/README.md    install guide, for the person installing the theme
Ports/<app_name>/MAPPING.md   color mapping and research, for maintainers
Ports/<app_name>/port.json    name, category, tier, and platforms for the ports page
Ports/<app_name>/template/    theme files with palette placeholders
Ports/<app_name>/dist/        generated themes, ready to use
Ports/preview/                the preview site and the ports page
build/                        turns palette + templates into dist, runs the checks
wallpapers/                   optional images, with credits
docs/adr/                     recorded decisions and why
PHILOSOPHY.md                 the design rules
```

Requires [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell).

```sh
pwsh build/build.ps1                     # rebuild every port
pwsh build/build.ps1 -Port <app_name>    # rebuild one port
pwsh build/check.ps1                     # every check CI runs
pwsh build/test.ps1                      # test the build modules and entry scripts
pwsh build/contrast.ps1                  # every contrast measurement, passing or not
pwsh build/roles.ps1                     # which palette names each port's templates use
pwsh build/site.ps1                      # assemble the Pages site into _site/
```

`check.ps1` prints the contrast table for both variants and warns about any color outside the sRGB gamut. `contrast.ps1` takes the same measurements. To try values before they go in the palette, point it at an edited copy with `-Palette <file>`, or change single numbers with `-Set`, repeated as needed. Narrow the list with `-Variant`, `-Role`, `-Surface`, or `-Failing`, or print the table with `-Table`:

```sh
pwsh build/contrast.ps1 -Set day.colors.brass.l=0.48 -Variant day -Role brass
```

The preview page, the ports page, and each port's install guide are published to GitHub Pages by [`.github/workflows/pages.yml`](.github/workflows/pages.yml) on every push to `main` that changes them. To look at the site locally:

```sh
pwsh build/site.ps1
python3 -m http.server -d _site 8765    # then open http://127.0.0.1:8765/
```

## Add a port

The quickest way is [Claude Code](https://claude.com/claude-code): open the repo and run `/new-port <app_name>`. The steps it follows are in [`.claude/skills/new-port/SKILL.md`](.claude/skills/new-port/SKILL.md), and they work by hand too:

1. **Research** the app's theme format, install path, light and dark support, how many colors it can show, and where it sets its font. Use official docs.
2. **Pick a tier**: 1 Full, 2 Partial, or 3 Minimal (see [PHILOSOPHY.md](PHILOSOPHY.md#port-tiers)).
3. **Map every color slot** to a neutral, a role, or a named color. Follow the syntax and terminal mappings in PHILOSOPHY.md.
4. **Write the template** in `Ports/<app_name>/template/`, using these placeholders. `color` stands for any neutral, named color, role, or `ansi.<slot>`:

   | Placeholder | Output |
   |---|---|
   | `{{color}}` | `#rrggbb`, such as `{{base}}`, `{{moss}}`, or `{{error}}` |
   | `{{color\|nohash}}` | `rrggbb` |
   | `{{color\|rgb}}` | `r, g, b` |
   | `{{color\|wash}}` | `#rrggbb`, the color mixed into `base` at the variant's wash strength, for selections, diff lines, and chips. Named colors only, or a role or ANSI slot that points at one |
   | `{{color\|clear}}` | `#rrggbb00`, fully transparent, for app settings that can only be switched off with a color |
   | `{{color\|name}}` | the neutral or named color drawn, by name, such as `firelight` for `{{accent\|name}}` |
   | `{{ansi.<slot>}}` | the terminal color for an ANSI slot (`black` to `white`, `bright_<slot>`), per ADR 0005. Bright slots are computed by the build |
   | `{{meta.name}}`, `{{meta.version}}`, `{{meta.repository}}` | theme name, palette version, repo URL |
   | `{{variant.name}}`, `{{variant.mode}}`, `{{variant.key}}` | variant name, `light` or `dark`, `day` or `night` |
   | `{{variant.name\|slug}}` | the name as an identifier, such as `inglenook-night`. Works on any `meta.`, `variant.`, or `port.` value |
   | `{{port.<key>}}` | a per-variant app value that is not a color, from `Ports/<app_name>/values.json` (`{ "day": { "<key>": "..." }, "night": { ... } }`) |

   `build/lib/Placeholders.psm1` defines them. `build/check.ps1` reports every placeholder that does not resolve, and fails if this table misses a filter.

5. **Build and check**:

   ```sh
   pwsh build/build.ps1 -Port <app_name>
   pwsh build/check.ps1
   ```

6. **Write the README** from [`port-readme-template.md`](.claude/skills/new-port/port-readme-template.md). Fill in every section, including **Set the font**. Put the color mapping, trade-offs, and research in `MAPPING.md` from [`port-mapping-template.md`](.claude/skills/new-port/port-mapping-template.md).
7. **Take the screenshots.** Install the port in the real app and take one screenshot per variant, saved as `Ports/<app_name>/screenshots/day.png` and `night.png`. Show them in the README's table.
8. **List the port** on the ports page by adding `Ports/<app_name>/port.json`:

   ```json
   {
     "name": "Windows Terminal",
     "category": "terminal",
     "tier": 1,
     "platforms": ["windows"]
   }
   ```

   `category` is one of the ids in [`Ports/ports.json`](Ports/ports.json). `platforms` takes `windows`, `macos`, `linux`, and `web`. An optional `monogram` (1 to 3 characters) replaces the initials on the card. If the app was in `planned` in `Ports/ports.json`, remove it from there. `check.ps1` enforces all of this.
9. **Add a card icon** (optional). Icons are single-color SVGs that take their color from the page ([ADR 0008](docs/adr/0008-port-icons-are-single-color.md)):

   ```sh
   pwsh build/icon.ps1 -Search "<app name>"
   pwsh build/icon.ps1 -Port <app_name> -Glyph <name>
   pwsh build/icon.ps1 -Port <app_name> -Brand <slug> -Mark <url showing the mark may be used>
   ```

   The script writes `Ports/<app_name>/icon.svg` and prints an `"icon"` credit to paste into `port.json`.

## Change the palette

1. Edit `palette/palette.json` only. Values are OKLCH: `l` from 0 to 1, `c` from 0 to 0.4, `h` in degrees.
2. Bump `meta.version`: patch for a tuned value, minor for a new role or named color, major for a role whose meaning changed or a color that was removed.
3. Run the build and the checks. Every port rebuilds, and the build prints one line per port: `changed`, `version stamp only`, or `unchanged`. Read the contrast table and any gamut warnings.
4. For a new role or a changed meaning, add an ADR in [`docs/adr/`](docs/adr/) explaining why.

## Add a wallpaper

Wallpapers come from [Wikimedia Commons](https://commons.wikimedia.org/), where every file has a recorded license and author. `build/wallpaper.ps1` finds, checks, and adds them:

```sh
pwsh build/wallpaper.ps1 -Search "cabin window plants"                    # grade Commons candidates from previews
pwsh build/wallpaper.ps1 -Search "library fireplace" -Variant night       # only images that suit Night
pwsh build/wallpaper.ps1 -Check "File:Example.jpg"                        # grade one from a large copy
pwsh build/wallpaper.ps1 -Add "File:Example.jpg" -Name example -Variant night  # save it, its thumbnail, and its credit
```

Wallpapers are chosen by taste: calm and cozy, with warm color that sits well with the palette. Day: sunlit cabin interiors, window light on plants, a forest through a window. Night: firelit or lamplit libraries and reading rooms, fireplaces. Two rules are hard:

- **License**: allows redistribution: CC0, public domain, CC BY, or CC BY-SA. No NonCommercial or NoDerivatives.
- **Format**: a landscape JPEG at least 1920 px wide.

Lightness, saturation, and detail are grades. They rank search results and suggest a variant from lightness: `day` at L* 60 or above, `night` at 40 or below, `both` in between.

`-Add` needs `-Variant day`, `night`, or `both`. It saves the original unmodified as `wallpapers/<name>.jpg`, a 640 px thumbnail in `wallpapers/thumbs/`, and prints the credit section for [`wallpapers/README.md`](wallpapers/README.md). A pair (one Day and one Night image of the same kind of scene) is one section with a subsection per image, listed before single images. `check.ps1` confirms every image has a thumbnail, a credit, and a variant mark, and every pair has one Day and one Night image.

## Branches and pull requests

- Branch names: `port/<app_name>` for ports, `palette/<change>` for palette changes, `build/<change>` for tooling and docs. Never commit to `main` directly.
- Run `pwsh build/build.ps1` and `pwsh build/check.ps1` before every commit that touches `palette/` or `Ports/`. CI runs the same checks on every pull request. To run them automatically before each commit, turn on the repo's hook once per clone: `git config core.hooksPath .githooks`.
- Changing the build itself: the rules live in `build/lib/`, and the scripts in `build/` only run them. Run `pwsh build/test.ps1` too, and add a test there for a new rule.
- Show both variants in the pull request.

## Writing style

Plain and short. Numbered steps, one action each. Real paths and real menu names. Use a colon, comma, or period where an em dash would go; `check.ps1` fails on em dashes.

## License

By contributing, you agree your work is released under the [MIT License](LICENSE). Third-party assets (wallpapers, fonts) must have a license that allows redistribution, and that license and its credit must be recorded next to the asset.
