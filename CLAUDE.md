# Theme ports repo

This repo holds one color theme and every app port of it. The theme has two variants that always ship together:

- **Inglenook Day** (light): a cabin room in natural light, soft neutral background leaning faintly green
- **Inglenook Night** (dark): a library by the fire, warm smoked-walnut background

The theme's family name lives in `palette/palette.json` under `meta.name`. Read it from there. Never hardcode it.

The design rules are in PHILOSOPHY.md. They are binding, not background reading. The user owns them: when what the user sees disagrees with a rule or an ADR, render it, show both, and offer to change the rule.

@PHILOSOPHY.md

## Layout

```
PHILOSOPHY.md               design rules (source of truth for decisions)
GLOSSARY.md                 project terms
docs/adr/                   recorded decisions and why
docs/research/              research notes behind the palette
prototypes/                 throwaway prototype pages, gitignored
palette/palette.json        every color as OKLCH, for both variants, and the roles (source of truth for values)
wallpapers/                 optional found images, thumbnails, and credits (README.md)
Ports/ports.json            category names, planned ports, and unlisted folders for the ports page
Ports/preview/              the preview site: landing page with live demos, ports page, install-guide shell
Ports/<app_name>/
  port.json                 name, category, tier, platforms, icon credit (feeds the ports page)
  icon.svg                  optional single-color card icon (ADR 0008)
  values.json               optional per-variant app values that are not colors ({{port.<key>}})
  site.json                 what the Pages site publishes (only the preview has one)
  template/                 files with palette placeholders, no raw colors
  dist/day/                 generated output, committed
  dist/night/               generated output, committed
  screenshot.json           the recipe: how the Photographer installs, applies, stages and finds the app
  shots.json                the preview's shot list instead of a recipe (only the preview has one)
  screenshots/              day.png and night.png, from the Photographer
  README.md                 step-by-step install guide for users; also its page on the Pages site
  MAPPING.md                color mapping, trade-offs, and research notes, for maintainers
build/lib/                  the rules, as modules the scripts share:
  Palette.psm1              loads and validates the palette; OKLCH to hex, gamut, contrast, wash, ANSI
  Placeholders.psm1         the {{...}} grammar: resolves, lists problems, reads template files
  Shell.psm1                shell files: <tool>.env to .sh and .ps1, and whether a shell file sources cleanly
  Build.psm1                renders a port into dist/ and compares a build with dist/
  Catalog.psm1              finds ports, validates port.json, ports.json, icons, site.json,
                            screenshot.json, shots.json
  Wallpaper.psm1            wallpaper rules: grades, variant marks and pairs, license
  Photographer.psm1         screenshot rules: step order, step scripts, backdrop, crop, README table,
                            pins, fingerprint, take verdict, why line
  Png.psm1                  PNG files: the stamp in a shot's text chunk, pixel compare, crop
  ScreenshotRun.psm1        screenshot workflow: what a run shoots, what it delivers, what the PR says
build/build.ps1             palette + templates = dist
build/check.ps1             runs the rules: palette, gamut, contrast, structure, port list, raw color,
                            placeholders, drift, leftovers, file format, wallpapers, em dashes
build/test.ps1              tests the build/lib modules on small fixtures
build/contrast.ps1          every contrast measurement, and trying values before they go in
build/roles.ps1             which palette names each port uses
build/site.ps1              assembles the GitHub Pages site, the port list, and the install guides into _site/
build/icon.ps1              finds and fetches a port's card icon
build/wallpaper.ps1         finds, checks, and adds wallpapers from Wikimedia Commons
build/photograph.ps1        takes a port's Day and Night screenshots (the Photographer): Linux in
                            Docker, Windows only on a hosted runner in the screenshots workflow
build/photograph/           pins.json, the Linux base image and take script, the Windows desktop
                            and take scripts, scenes/<kind>/ content
build/screenshots.ps1       the screenshot workflow's steps that are not a shot (plan, summary, delivery)
.github/workflows/screenshots.yml  retakes stale ports after a merge; delivers one rolling PR from build/screenshots
.githooks/pre-commit        runs test.ps1 and check.ps1 before a commit (git config core.hooksPath .githooks)
.claude/skills/new-port/    the new-port skill and the port README and MAPPING templates
.claude/skills/port-icon/   the port-icon skill
.claude/skills/wallpaper/   the wallpaper skill
```

## Rules that are never broken

1. **No color values outside `palette/palette.json`.** Templates use placeholders only. This includes hex, rgb(), hsl(), and named CSS colors. The one exception is wallpapers, which are images (ADR 0007). Port icons use `currentColor` only (ADR 0008).
2. **Never invent a color.** If a port needs something the palette lacks, stop and propose a palette change to the user. Do not approximate.
3. **Never edit files in `dist/` by hand.** Change the template or the palette, then rebuild.
4. **Both variants or neither.** If the app supports only one mode, ship that one and say so in the port README.
5. **Roles keep their meaning.** Ember is failure, moss is success, brass is a warning, firelight is "you are here", per PHILOSOPHY.md. Do not reassign a role because it looks nicer.
6. **Solid surfaces only.** The theme never sets transparency. A README may point to the app's own setting as an optional extra.
7. **Do not guess an app's theme format.** Look it up in the app's official docs and link the source in the port README.
8. **Every port gets its own folder and its own README.** The folder is `Ports/<app_name>/`. The README is a step-by-step install guide. A `port.json` lists it on the ports page; never list ports by hand in the root README.
9. **A port ships only with real screenshots of both variants, passing checks, and the owner's approval.**

## When asked for a new theme or port

Requests look like "create a Windows theme" or "make a theme for Typora". Use the `new-port` skill (`/new-port <app_name>`). It covers research, tier choice, color mapping, templates, build, checks, screenshots, and the install guide.

Studying how Catppuccin, Nord, Dracula, and other themes ported to the same app is expected, per PHILOSOPHY.md. Borrow their method, never their colors or names.

## When asked to change a color

1. Edit `palette/palette.json` only. Values are OKLCH.
2. Bump `meta.version` per "Changing the palette" in PHILOSOPHY.md.
3. Run the build, then the checks. Read the contrast table and any gamut warnings the check prints.
4. Summarize which ports changed, from the build's per-port line (`changed`, `version stamp only`, `unchanged`).
5. If the change adds a role, run `pwsh build/roles.ps1 -Role <role>` and list the ports that don't use it.

If a check fails after a change the user asked for, report it. Do not adjust other values to make it pass without asking.

## Commands

```
pwsh build/build.ps1                     # rebuild every port
pwsh build/build.ps1 -Port <app_name>    # rebuild one port
pwsh build/check.ps1                     # run all checks (CI runs this too)
pwsh build/test.ps1                      # test the build modules and entry scripts (CI runs this too)
pwsh build/contrast.ps1                  # every contrast measurement (-Table, -Palette <file>, -Set day.colors.moss.l=0.48)
pwsh build/roles.ps1                     # which palette names each port uses (-Role <name> for one)
pwsh build/site.ps1                      # assemble the Pages site into _site/
pwsh build/icon.ps1 -Search <words>      # find a card icon (see the port-icon skill)
pwsh build/wallpaper.ps1 -Search <words> # find a wallpaper (see the wallpaper skill)
pwsh build/photograph.ps1 -Port <app>    # take a Linux port's screenshots in Docker
pwsh build/photograph.ps1                # retake every stale Linux port (-All: every Linux port)
```

Run build and check before every commit that touches `palette/` or `Ports/`. Run the tests too when `build/` changes.

## Template placeholders

The placeholder table (`{{<neutral>}}`, `{{<color>}}`, `{{<role>}}`, `{{color|wash}}`, `{{ansi.<slot>}}`, `{{port.<key>}}`, and the rest) is in CONTRIBUTING.md, step 4 of "Add a port". `build/lib/Placeholders.psm1` is the source of truth, and `check.ps1` fails if that table misses a filter.

## Working style

- Work on a branch named `port/<app_name>`, `palette/<change>`, or `build/<change>` for tooling and docs. Do not commit to `main` directly.
- Do not install a theme on the user's machine or change system settings unless asked. Building files in the repo is the job.
- For your own look at a render, capture at 1280x800 or crop to the area in question before reading the image.
- Port screenshots come from the Photographer (`pwsh build/photograph.ps1 -Port <app_name>`), never from a mock, and so do the preview shots (`-Port preview`). Ask the user for shots only when the port has a manual recipe. Show the user every new or changed shot (the rolling PR counts).
- Before asking the user to lock a palette candidate, list every check it fails and every gamut warning.
- Run `node --check` on a prototype page's script before rendering it: a syntax error leaves the page blank with no message.
- READMEs are for their readers: a port README for the person installing it, the root README for a visitor. No measurements, role names, palette versions, ADR links, research notes, or notes to an agent in them.
- Writing style for docs: plain and short. `check.ps1` fails on em dashes.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `mookeyj79/Inglenook`, managed with the `gh` CLI. See `../docs/agents/issue-tracker.md`.

### Triage labels

Uses the five default triage labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `../docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `../docs/agents/domain.md`.
