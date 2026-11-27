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
Ports/<app_name>/screenshot.json  the recipe the Photographer shoots the port with
Ports/<app_name>/screenshots/ day.png and night.png, from the real app
Ports/preview/                the preview site and the ports page
build/                        turns palette + templates into dist, runs the checks
build/photograph/             the Photographer's pins, base image, and scenes
wallpapers/                   optional images, with credits
docs/adr/                     recorded decisions and why
PHILOSOPHY.md                 the design rules
```

Requires [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell), and Docker to take Linux screenshots.

```sh
pwsh build/build.ps1                     # rebuild every port
pwsh build/build.ps1 -Port <app_name>    # rebuild one port
pwsh build/check.ps1                     # every check CI runs
pwsh build/test.ps1                      # test the build modules and entry scripts
pwsh build/contrast.ps1                  # every contrast measurement, passing or not
pwsh build/roles.ps1                     # which palette names each port's templates use
pwsh build/site.ps1                      # assemble the Pages site into _site/
pwsh build/photograph.ps1 -Port <app>    # take a Linux port's screenshots in Docker
pwsh build/photograph.ps1                # retake every stale Linux port (-All: every Linux port)
pwsh build/photograph.ps1 -Port preview  # retake the preview shots (Ports/preview/shots.json)
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
   | `{{color\|sgr}}` | `r;g;b`, for terminal escape codes: `38;2;{{text\|sgr}}` is a foreground, `48;2;...` a background |
   | `{{color\|comma}}` | `r,g,b` with no spaces, for tools that take a comma list, such as ripgrep's `--colors` |
   | `{{color\|wash}}` | `#rrggbb`, the color mixed into `base` at the variant's wash strength, for selections, diff lines, and chips. Named colors only, or a role or ANSI slot that points at one |
   | `{{color\|wash\|comma}}` | the wash in another format: `\|wash` can take one more filter, `nohash`, `rgb`, `sgr`, or `comma`, such as `{{steel\|wash\|comma}}` for ripgrep |
   | `{{color\|clear}}` | `#rrggbb00`, fully transparent, for app settings that can only be switched off with a color |
   | `{{color\|name}}` | the neutral or named color drawn, by name, such as `firelight` for `{{accent\|name}}` |
   | `{{ansi.<slot>}}` | the terminal color for an ANSI slot (`black` to `white`, `bright_<slot>`), per ADR 0005. Bright slots are computed by the build |
   | `{{meta.name}}`, `{{meta.version}}`, `{{meta.repository}}` | theme name, palette version, repo URL |
   | `{{variant.name}}`, `{{variant.mode}}`, `{{variant.key}}` | variant name, `light` or `dark`, `day` or `night` |
   | `{{variant.name\|slug}}` | the name as an identifier, such as `inglenook-night`. Works on any `meta.`, `variant.`, or `port.` value |
   | `{{meta.slug}}`, `{{variant.slug}}` | the theme and variant names as identifiers, `inglenook` and `inglenook-night`, with no filter. Use these in file names: Windows does not allow `\|` in a file name, and `build/check.ps1` fails on any path Windows cannot check out |
   | `{{port.<key>}}` | a per-variant app value that is not a color, from `Ports/<app_name>/values.json` (`{ "day": { "<key>": "..." }, "night": { ... } }`) |

   `build/lib/Placeholders.psm1` defines them. `build/check.ps1` reports every placeholder that does not resolve, and fails if this table misses a filter.

   **Tools that take their colors from the shell** (fzf, less, zsh plugins, PSReadLine) ship a shell file per variant, named after the tool, that the user sources from their profile:

   | Template | dist/day/ and dist/night/ | For |
   |---|---|---|
   | `<tool>.env` | `<tool>.sh` and `<tool>.ps1` | a tool that takes environment variables, in any shell. One `NAME=value` per line, plus blank lines and `# comments`. The build writes `export NAME='value'` and `$env:NAME = 'value'`, so both shells get the same values. A value cannot contain a single quote |
   | `<tool>.sh` and `<tool>.ps1` | the same | a tool that needs code in both shells, such as adding to a variable that is already set |
   | `<tool>.zsh` | the same | a Zsh-only tool (the line editor, Zsh plugins). Bash is not supported: say so in the README |
   | `<tool>.ps1` | the same | a PowerShell-only tool (PSReadLine, `$PSStyle`) |

   `check.ps1` parses every shell file and sources it in a fresh shell, which must print nothing: `.sh` in bash and zsh, `.zsh` in zsh, `.ps1` in PowerShell. A script that starts with a shebang (`#!`), such as an install script the reader runs, is only parsed, by the shell its shebang names. A shell that is not installed is a warning locally; CI checks them all. `build/lib/Shell.psm1` holds these rules.

5. **Build and check**:

   ```sh
   pwsh build/build.ps1 -Port <app_name>
   pwsh build/check.ps1
   ```

6. **Write the README** from [`port-readme-template.md`](.claude/skills/new-port/port-readme-template.md). Fill in every section, including **Set the font**. Put the color mapping, trade-offs, and research in `MAPPING.md` from [`port-mapping-template.md`](.claude/skills/new-port/port-mapping-template.md).
7. **Write the screenshot recipe.** Screenshots come from the Photographer, which installs the app in a throwaway desktop, applies the port, stages a fixed scene, and shoots Day and Night. Your part is `Ports/<app_name>/screenshot.json`, the recipe. Every port needs one, and `check.ps1` fails without it. A Linux recipe looks like this:

   ```json
   {
     "kind": "terminal",
     "platform": "linux",
     "version": "3.52.0",
     "install": ["apt-get install -y gnome-terminal"],
     "apply": ["bash \"$INGLENOOK_PORT/dist/$INGLENOOK_VARIANT/install.sh\""],
     "stage": [],
     "launch": ["gnome-terminal -- bash \"$INGLENOOK_SCENE/run.sh\""],
     "window": { "class": "gnome-terminal-server" }
   }
   ```

   - `kind` is the scene kind: `terminal`, `prompt`, `cli`, `editor`, `icon-theme`, `document`, `desktop`, or `web`. Its staged content is in `build/photograph/scenes/<kind>/`. If none fits, open an issue before adding one.
   - `platform` is `linux` if the app runs there, else `windows`, else `macos`. A Windows recipe's steps are PowerShell lines.
   - `install` runs as root when the image is built; `apply`, `stage`, and `launch` run for each variant as an ordinary user, from the repo root. Steps see `INGLENOOK_VARIANT` (`day` or `night`), `INGLENOOK_PORT` (the port's folder), `INGLENOOK_SCENE` (the scene's folder), and `INGLENOOK_VERSION`.
   - `apply` is your README's install steps. `stage` never changes a color, and turns off self-update and first-run dialogs.
   - `window` finds the app's window by `class` or by a `title` regex. A whole desktop has no `window`.
   - An app that lives inside another port, such as a prompt in a terminal, names that port as its `host`, which launches it, and gives only `install`, `apply`, and `stage`.
   - `version` is the exact app version, unless the Ubuntu package date in `build/photograph/pins.json` already pins the app. See [Move a pin](#move-a-pin).
   - An app that only recommends a login, or lets you skip it, gets a normal recipe. One that requires a login or a license key to reach its themed screen, or whose trial is licensed for evaluation only, gets a manual recipe: only `kind`, `platform`, and `manual`, the reason in one sentence. Record which, with links to its terms, in `MAPPING.md`. Never put a key or a login in a recipe.

   Behind every shot is the variant's wallpaper, shown as it is: Cabin Seating in Day and Mission Fireplace in Night (credits in [`wallpapers/README.md`](wallpapers/README.md)). The Photographer sets it; a recipe never does. Then take the path that fits:

   - **A Linux recipe, with Docker**: run `pwsh build/photograph.ps1 -Port <app_name>`. It writes `screenshots/day.png` and `night.png` and adds the Day and Night table to the README if it is missing. Check every row of your `MAPPING.md` table in both shots, and list under **Gaps** any color the scene cannot show. Commit the images and the table with the port.
   - **A Windows or macOS recipe, or no Docker**: commit the recipe. On your pull request, the `screenshots` workflow shoots the port and attaches the images to the run. Check them the same way, then commit them as `screenshots/day.png` and `night.png`: they carry their stamp, so the port is fresh. Windows takes run only on a hosted runner, each take in a job of its own, because a take changes system settings. macOS has no runner yet, so a macOS recipe is listed as not shot.
   - **A manual recipe**: run `pwsh build/photograph.ps1 -Port <app_name>` first: with no shots yet, it names the scene content and each variant's backdrop. Shoot both variants by hand to that scene, save them as `screenshots/day.png` and `night.png`, then run the same command again: it stamps them and adds the table. After the merge, the workflow keeps one "Screenshots for <App>" issue open whenever the shots are stale.

   `check.ps1` fails on a port with a recipe and no `screenshots/day.png` or `night.png`.

   **Tested with**: once you have looked at a good run's shots, replace "Not tested yet" in the README with the app version and OS the recipe shot, such as `GNOME Terminal 3.52.0 on Linux Mint 22.3`. You write this line, the pipeline never does. If a recipe step stands in for something the reader does by hand, note it in `MAPPING.md` as not tested by hand.

   **How it stays current.** Each image carries a fingerprint of what it was made from: the port's `dist/` and recipe, its host's, the scene, the Photographer (`build/photograph/`, `photograph.ps1` and its rules modules), and each variant's backdrop wallpaper. When one changes, the port is stale. `pwsh build/photograph.ps1` with no `-Port` retakes every stale Linux port. A take that differs from the committed shot is taken again to confirm it, and only images whose exact pixels changed are written. An image a take matches exactly keeps its pixels and gets the new fingerprint, so the port is fresh again. `check.ps1` never fails on a stale port.

   The `screenshots` workflow does the same in GitHub Actions. On a pull request it shoots the ports the pull request changed, attaches the images, and says in the run summary whether they match the ones you committed. It never blocks a merge. After a merge to `main` it retakes every stale port and puts the changed images in one pull request from `build/screenshots`, rebuilt from `main` on each run. Merge it when you choose. Fix a bad shot on `main`, never on that branch: hand edits to it are lost. **Run workflow** retakes one port, or every port with **all**.
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
5. The preview screenshots show the palette. Retake them with `pwsh build/photograph.ps1 -Port preview` and commit them with the change, or merge the rolling screenshots pull request after it.
## Move a pin

A pin is the exact version of an app, font, base image, or runner that screenshots are made with: a recipe's `version`, or an entry in `build/photograph/pins.json`. Pins move by hand, never on a schedule. Good times are a port's first recipe, an app update that changes or breaks a port, and before a palette major version.

1. Move one pin in its own pull request. The one exception: a port fix that needs a newer app moves that app's pin in the same pull request.
2. Every port that uses the pin goes stale. Look at their new shots on the pull request run. If an app version moved, update that port's **Tested with** line.

## Add a wallpaper

Wallpapers come from [Wikimedia Commons](https://commons.wikimedia.org/), where every file has a recorded license and author. `build/wallpaper.ps1` finds, checks, and adds them:

```sh
pwsh build/wallpaper.ps1 -Search "cabin window plants"                    # grade Commons candidates from previews
pwsh build/wallpaper.ps1 -Search "library fireplace" -Variant night       # only images that suit Night
pwsh build/wallpaper.ps1 -Check "File:One.jpg|File:Two.jpg"              # grade originals, print their credits
pwsh build/wallpaper.ps1 -Add "File:Example.jpg" -Name example -Variant night  # save it, its thumbnail, and its credit
pwsh build/wallpaper.ps1 -Web example                                     # a smaller copy for the preview site
```

Wallpapers are chosen by taste: calm and cozy, with warm color that sits well with the palette. Day: sunlit cabin interiors, window light on plants, a forest through a window. Night: firelit or lamplit libraries and reading rooms, fireplaces. Two rules are hard:

- **License**: allows redistribution: CC0, public domain, CC BY, or CC BY-SA. No NonCommercial or NoDerivatives.
- **Format**: a landscape JPEG at least 1920 px wide.

Lightness, saturation, and detail are grades. They rank search results and suggest a variant from lightness: `day` at L* 60 or above, `night` at 40 or below, `both` in between.

`-Add` needs `-Variant day`, `night`, or `both`. It saves the original unmodified as `wallpapers/<name>.jpg`, a 640 px thumbnail in `wallpapers/thumbs/`, and prints the credit section for [`wallpapers/README.md`](wallpapers/README.md). A pair (one Day and one Night image of the same kind of scene) is one section with a subsection per image, listed before single images. `check.ps1` confirms every image has a thumbnail, a credit, and a variant mark, and every pair has one Day and one Night image.

The preview site shows a web copy, not the original: `-Web` writes a 2400 px copy to `wallpapers/web/`, and the preview's `values.json` names it. `check.ps1` confirms every web copy has its original and that a page shows it only in a variant its original is marked for.

## Branches and pull requests

- Branch names: `port/<app_name>` for ports, `palette/<change>` for palette changes, `build/<change>` for tooling and docs. Never commit to `main` directly.
- Run `pwsh build/build.ps1` and `pwsh build/check.ps1` before every commit that touches `palette/` or `Ports/`. CI runs the same checks on every pull request. To run them automatically before each commit, turn on the repo's hook once per clone: `git config core.hooksPath .githooks`, or `prek install`, which runs the same checks from `.pre-commit-config.yaml`. `check.ps1` warns while neither is on.
- Changing the build itself: the rules live in `build/lib/`, and the scripts in `build/` only run them. Run `pwsh build/test.ps1` too, and add a test there for a new rule.
- Show both variants in the pull request.

## Writing style

Plain and short. Numbered steps, one action each. Real paths and real menu names. Use a colon, comma, or period where an em dash would go; `check.ps1` fails on em dashes.

## License

By contributing, you agree your work is released under the [MIT License](LICENSE). Third-party assets (wallpapers, fonts) must have a license that allows redistribution, and that license and its credit must be recorded next to the asset.
