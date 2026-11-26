---
name: new-port
description: Create a new port of this repo's theme for an app, tool, OS, or website. Use when asked to "make a theme for X", "create a Windows theme", "port the theme to X", or "add X support".
argument-hint: [app-name]
---

# New port

Create a port of the theme for: $ARGUMENTS

A port is done when it builds from the palette, passes the checks, has real screenshots of both variants, has a README someone else could install from, and the owner has approved it. Follow the steps in order.

## 1. Load the rules

- Read `PHILOSOPHY.md` and `palette/palette.json`.
- Look at one existing port in `Ports/` for conventions, if any exist. `Ports/preview/` is the preview site, not an app port.

## 2. Pin down the target

- Pick the folder name (`<app_name>`): lowercase, hyphenated, the app's common name (`windows-terminal`, `typora`, `vscode`).
- If `Ports/<app_name>/` exists, this is an update, not a new port. Say so and continue as an update.
- If the request is ambiguous, ask one question before going further. "Windows theme" is the classic case: it could mean the OS theme, Windows Terminal, or both. An OS theme usually controls far less than people expect, so say what it can and cannot change.

## 3. Research how the app is themed

Search the web and read the app's official documentation. Do not rely on memory for file formats or setting names. Find:

- **Format**: CSS, JSON, XML, INI, a settings UI, a browser user style, something else
- **Location**: where the theme file goes on Windows first, then other platforms
- **Reach**: what can be colored (background, text, syntax, UI surfaces, status colors)
- **Palette size**: full 24-bit color, or only 16 or 256 terminal colors (then the port is approximate and says so)
- **Modes**: does it support light and dark, and can it follow the OS setting
- **Font**: can the font be set, and where (setting name, file key, or menu)
- **Transparency**: whether the app offers it. The theme is always solid; if the app has its own transparency setting, the README may mention it as an optional extra
- **Versioning**: does the format differ between app versions

Then look at how other themes ported to this app. This is expected, not optional. Find the Catppuccin port first (it has the widest coverage), then Nord, Dracula, Gruvbox, or Rosé Pine. From them, learn:

- The file layout and install method that works in practice
- Which settings are worth theming and which are ignored by the app
- How they ship light and dark together
- Workarounds for things the app does not officially support

Take the method, never the colors or the names. Every color still comes from the palette. If you reuse more than the basic structure of someone's port, check its license and credit it in the README.

Keep the source URLs. The official docs go in the README's **Sources**. The ports you studied go in `MAPPING.md` under **Research**.

If the app cannot be themed at all, say so and stop. Do not ship a workaround that patches app files unless the user asks for it.

## 4. Choose the tier

Per PHILOSOPHY.md:

- **Tier 1, Full**: the complete palette
- **Tier 2, Partial**: most of the palette, with gaps the app imposes
- **Tier 3, Minimal**: only background, accent, and status colors

Tell the user the tier and the known gaps in two or three lines, then carry on. Only wait for an answer if the port would be Tier 3 or worse than they likely expect.

## 5. Map the app's slots to colors

List every color slot the app exposes and give each one a neutral, a role, or a named color. Copy `port-mapping-template.md` from this skill's folder to `Ports/<app_name>/MAPPING.md` and write the table there. It is for maintainers, not in the README.

- Surfaces: `base` for the main background, `deep` and `deeper` for recessed areas (sidebars, title bars, panels behind content), `raised` for lifted ones (popups, cards, inputs), `hover` for hovered and active rows, `line` for borders and dividers.
- Text: `text` for content, `dim` for supporting text and punctuation, `faint` for comments, placeholders, and metadata.
- Focus, selection, cursor, links, primary buttons: `accent`, with `on_accent` for text on an accent fill. Selections and highlighted lines use a wash (`{{accent|wash}}`, or another color's wash for diff lines).
- State: `error`, `warning`, `success`, `info`.
- Syntax: follow the syntax mapping in PHILOSOPHY.md exactly.
- Detail colors: `oxblood` and `ivy` for badges and small accents only. They carry no meaning.
- Terminal ANSI: use `{{ansi.<slot>}}` for all sixteen slots. The build fills them from the palette (ADR 0005): red is ember, green moss, yellow brass, blue steel, magenta heather, cyan pine, and each bright slot is the same hue, slightly stronger. Black and white map to neutrals:

  | Slot | Day | Night |
  |---|---|---|
  | black | `text` | `raised` |
  | bright black | `faint` | `faint` |
  | white | `line` | `dim` |
  | bright white | `raised` | `text` |

Prefer a role where one fits; use a named color only for a slot that is about the color itself. If a slot has no fitting color, use the closest one. If nothing is close, stop and propose a palette change. Never invent a color.

## 6. Write the template

- Put files in `Ports/<app_name>/template/`, named the way the app expects.
- Use placeholders for every color. The table is in CONTRIBUTING.md, step 4 of "Add a port".
- One template should serve both variants. Split only if the app needs structurally different files per mode.
- Use `{{meta.name}}` and `{{variant.name}}` for display names inside the file.
- No raw color values, including in comments.

## 7. Build and check

```
pwsh build/build.ps1 -Port <app_name>
pwsh build/check.ps1
```

The checks cover drift, raw colors, contrast, and whether JSON, SVG, XML, and CSS output is valid. Then verify by hand:

- Formats the check does not parse (TOML, INI, HTML, app-specific files) load in a parser or match a known-good file.
- Both `dist/day/` and `dist/night/` exist, unless the app is single mode.

Fix the template and rebuild until everything passes. Never edit `dist/`.

## 8. Write the install guide

Copy `port-readme-template.md` from this skill's folder to `Ports/<app_name>/README.md` and fill in every section.

The README is first and foremost a step-by-step install guide. Write it for someone who has never themed this app:

- Number every step. One action per step.
- Use real paths, real menu names, and real setting names, taken from the docs you read in step 3. Windows first.
- Say what the reader should see when a step worked.
- Include how to switch variants and how to uninstall.
- Fill in **Set the font**: where this app sets its font, pointing to IBM Plex Mono, or BlexMono Nerd Font Mono where the app shows icons (ADR 0006). If the app cannot change its font, say so.
- **Known limits** says what the reader will notice, in the app's own terms. A 16 or 256 color app says its colors are approximate. The reasons go in `MAPPING.md`.
- **Sources** lists the official docs, and a credit for any reused files. Nothing else.
- Keep out role names, placeholders, contrast numbers, palette versions, ADR links, build commands, research notes, TODOs, and notes to an agent.
- The README is also published as the port's page on the Pages site (`/Ports/<app_name>/`). Link to repo files with relative paths: a link to another port's README opens that port's guide, other files open on GitHub, and `build/site.ps1` stops on a link to a file that does not exist.

## 9. Screenshots

A port ships only with real screenshots of both variants. Until the screenshot tooling is back, take them by hand:

1. Install the port from `dist/day/` in the real app, set the font, and take a screenshot of a typical screen. Save it as `Ports/<app_name>/screenshots/day.png`.
2. Do the same for Night as `screenshots/night.png`.
3. Add a two-column table (Day, Night) with both images near the top of the README.
4. Check every row of the `MAPPING.md` table in both shots. List any color the screen cannot show under **Gaps** in `MAPPING.md`.

Never use a mock. If you cannot run the app here, ask the user for the shots.

## 10. Finish

- Write `Ports/<app_name>/port.json` so the port shows on the ports page: `name`, `category` (an id from `Ports/ports.json`), `tier` (1 to 3), and `platforms` (`windows`, `macos`, `linux`, `web`). If the app is in `planned` in `Ports/ports.json`, remove it from there. If no category fits, ask the user before adding one.
- Give the card an icon with the `port-icon` skill (`/port-icon <app_name>`). If no icon fits, the monogram stays.
- Commit on a branch named `port/<app_name>`.
- Show the user both screenshots and ask for approval. The port is not done without it.
- Report back in a few lines: tier, what is covered, what is not, and what the user needs to do.

Do not install the theme on the user's machine unless they ask.
