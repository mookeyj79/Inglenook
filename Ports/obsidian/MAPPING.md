# Obsidian: color mapping

For maintainers. The install guide is [README.md](README.md).

## How Day and Night ship

An Obsidian theme is a folder in `<vault>/.obsidian/themes/<name>/` with `manifest.json` and `theme.css`, and a vault uses one theme at a time. A theme normally holds a light set under `.theme-light` and a dark set under `.theme-dark` in one `theme.css`, and Obsidian picks the set from **Base color scheme**.

The build renders each template once per variant, so one file cannot hold both variants' colors. The port follows the VS Code port instead: each variant is a whole theme of its own, `dist/day/` named **Inglenook Day** and `dist/night/` named **Inglenook Night** (the folder name must match the manifest `name`). Each sets its colors on `.theme-light, .theme-dark` together, with `color-scheme` from `{{variant.mode}}`, so a variant looks the same under either base scheme instead of falling back to Obsidian's colors for the other one. The README pairs Day with **Light** and Night with **Dark**, so Obsidian's own scheme-dependent parts (form controls, scrollbars, the few rules it keys on `.theme-dark`) match.

The cost: Obsidian cannot switch from Day to Night by itself when the system does. A single "Inglenook" theme with Day under `.theme-light` and Night under `.theme-dark` would follow the system, but needs a build feature that renders one file from both variants. If the owner wants that, it is a `build/` change (a cross-variant placeholder or a combined output), and the template here would move over with one selector per variant.

## Color mapping

Obsidian's colors come from CSS variables (the [CSS variables reference](https://docs.obsidian.md/Reference/CSS+variables/CSS+variables), and `app.css` in 1.15.1 for the defaults). The port sets the base layer that plugins read and the semantic layer the app reads, so nothing derives from Obsidian's own values.

| App setting | Color | Why |
|---|---|---|
| `--color-base-00`, `-05` | base | The editor and note background |
| `--color-base-10`, `-20` | deep | Code blocks, side bars |
| `--color-base-25` | raised | Form fields |
| `--color-base-30`, `-35` | line | Borders |
| `--color-base-40`, `-50` | faint | |
| `--color-base-60`, `-70` | dim | |
| `--color-base-100` | text | |
| `--color-red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `pink` | ember, clay, brass, moss, pine, steel, dusk, heather | Slots named for the color itself (canvas colors, highlight colors, graph groups, Mermaid, plugins), so each takes the named color nearest its hue, as the terminal slots do. The `-rgb` forms are the same colors as channels |
| `--mono-rgb-0`, `--mono-rgb-100` | base, text | Obsidian mixes these for hover tints in some plugins |
| `--color-accent`, `-1`, `-2`, `--interactive-accent`, `--text-accent` and hovers | accent | One accent, no lighter steps |
| `--text-on-accent`, `-inverted` | on_accent | |
| `--caret-color` | accent | The cursor |
| `--background-primary` | base | Notes |
| `--background-primary-alt` | deep | Code background, setting groups |
| `--background-secondary` | deep | Side bars, tab bar |
| `--background-secondary-alt` | deeper | |
| `--background-modifier-hover`, `-active-hover` | hover | Solid, in place of a see-through tint of the text color |
| `--background-modifier-border`, `-border-hover` | line | |
| `--background-modifier-border-focus` | accent | Focus |
| `--background-modifier-form-field`, `-hover` | raised | Inputs |
| `--background-modifier-message`, `--notice-*`, `--tooltip-*` | raised, text | Solid, in place of a see-through near-black with near-white text |
| `--background-modifier-error`, `-warning`, `-success` | error, warning, success | |
| `--interactive-normal`, `-hover` | raised, hover | Buttons |
| `--blur-background`, `--raised-background` | raised | Solid, in place of the glassy mix |
| `--divider-color`, `-hover` | line, accent | |
| `--text-normal`, `-muted`, `-faint` | text, dim, faint | |
| `--text-error`, `-warning`, `-success` | error, warning, success | |
| `--text-selection` | accent wash | |
| `--heading-formatting`, list markers, collapse icons | faint (dim on hover, accent when collapsed) | |
| `--blockquote-border-color`, `--embed-border-start`, `--hr-color`, indentation guides | line (active guide faint) | Obsidian uses the accent for quote and embed bars; they are not "you are here" |
| `--titlebar-*` | deeper, line, dim, text | Obsidian draws its own frame by default |
| `--ribbon-background` | deeper | `--ribbon-background-collapsed` base |
| `--tab-container-background` | deep | Same as the side bars |
| `--tab-background-active` | base | The open note's tab joins the note |
| `--tab-text-color*` | faint, dim, text, accent | Obsidian's own steps |
| `--nav-item-*` | dim, text, hover, accent wash (selected) | The file explorer |
| `--status-bar-*` | deep, line, dim | |
| `--icon-color*` | dim, text, accent | `--icon-opacity` 1, so icons are solid |
| `--scrollbar-thumb-bg`, `-active-thumb-bg` | line, faint | Solid |
| `--menu-*`, `--modal-*`, `--prompt-*`, `--suggestion-background`, `--embed-actions-background` | raised, line | Lifted surfaces |
| `--drag-ghost-*`, `--lightbox-*` | raised and text, deeper and text | |
| `--hotkey-background`, `--code-bracket-background` | hover | |
| `--checkbox-*` | accent, on_accent, faint, dim | |
| `--toggle-thumb-color` | on_accent | On the accent track |
| `--slider-*` | raised, line, accent | |
| `--link-*` | accent | Links are "you are here" targets, per PHILOSOPHY |
| `--link-unresolved-*` | accent, dashed underline, opacity 1 | Shape instead of see-through for a missing note |
| `--tag-color`, `--tag-background`, `--tag-border-color` | tag, tag wash | Tags are the tag role |
| `--text-highlight-bg`, `--highlight-background-yellow` | brass wash | `==marks==` are a yellow highlighter; the yellow slot is brass |
| `--highlight-background-red` to `-purple` | washes of ember, clay, brass, moss, steel, dusk | The highlight colors, solid |
| `--highlight-mix-blend-mode` | normal | Washes are solid, so no blending |
| `--table-*` | line, text, accent wash, accent, faint | |
| `--font-monospace-theme` | IBM Plex Mono | ADR 0006; the user's **Monospace font** still wins |
| `--code-background`, `--code-normal` | deep, text | |
| `--code-comment` | faint | |
| `--code-punctuation`, `--code-operator` | dim | Operators take the punctuation row |
| `--code-function`, `--code-property` | info | Keys, properties, functions |
| `--code-string` | success | |
| `--code-value` | literal | Numbers |
| `--code-keyword`, `--code-important` | keyword | `!important` and regex flags are closest to keywords |
| `--code-tag` | tag | |
| `.token.class-name`, `.token.builtin`, `.cm-type`, `.cm-builtin` | type | Obsidian groups these with functions; PHILOSOPHY gives types their own row |
| `.token.boolean`, `.token.constant`, `.cm-atom` | keyword | Obsidian groups booleans with numbers and constants with tags |
| `.token.attr-name`, `.token.attr-value` | info, success | Obsidian colors attribute names as strings and values as functions |
| `.token.url` | reference | Paths |
| `.token.deleted`, `.token.inserted` | error, success | Diff blocks |
| `--callout-default`, `-info`, `-todo` | info | Note, info, todo |
| `--callout-success`, `-warning`, `-error`, `-fail`, `-bug` | success, warning, error | State callouts by role |
| `--callout-question` | clay | Obsidian's orange slot; a question is not a warning |
| `--callout-summary`, `-tip`, `-important` | pine | Obsidian's cyan slot |
| `--callout-example` | dusk | Obsidian's purple slot |
| `--callout-quote` | dim | |
| `.callout` background | the wash of the callout's color (quote: deep) | Solid, in place of a 10% see-through mix; `mix-blend-mode` normal |
| Search matches (`.obsidian-search-match-highlight`, `.cm-searchMatch`, `.search-result-file-matched-text`) | steel wash, text | ADR 0009. Obsidian marks them with the selection tint by default |
| `.cm-searchMatch-selected` | accent, on_accent | The match at the cursor |
| Reading view search (`.search-highlight`) | steel ring, accent ring for the active one | Obsidian draws a ring, not a fill |
| `.is-flashing` | accent wash | A block Obsidian jumps to |
| `--graph-*` | text, line, dim, faint, accent, tag, reference | Attachments are files, so reference |
| `--canvas-dot-pattern` | line | |

## Gaps and trade-offs

- Tier 1: every surface, text strength, state, syntax row and the accent are set; the theme sets no transparency.
- **Follow the system.** See "How Day and Night ship": each variant is its own theme, so Obsidian cannot switch between them on its own.
- **Accent color setting.** **Appearance** > **Accent color** sets `--accent-h`, `-s`, `-l`; the theme sets `--color-accent` and the rest directly, so the setting has no effect. Intended: firelight is the one accent.
- **Left to Obsidian:** `--background-modifier-cover` (the see-through dimming behind a dialog), `--background-modifier-box-shadow`, `--shadow-*` and `--input-shadow*` (shadows need a see-through color; the VS Code port leaves VS Code's shadows the same way), and the tab switcher's gradient menubar. The README says shadows and the dimming are Obsidian's own.
- **Find in a note:** Obsidian's in-note search selects the current match, so it shows as the selection (firelight wash), not a firelight fill. The other matches get the steel wash. The README says so.
- **Callout titles** are the callout's color on its own wash: short labels, measured on the wash rather than `base`.
- **Shown:** base (note), deep (side bar, tab bar, status bar, code block), deeper (title bar strip and ribbon), line (dividers), hover (the open file in the explorer), text, dim, faint (comment, done task), accent (link, checked box with on_accent), the tag chip (tag on its wash), the note callout (info on the steel wash), and the syntax rows for keywords, functions, types (`str`, `int`, `bool`), numbers, strings, punctuation and comments.
- **Not in the scene:** raised (menus, prompts, inputs, which the scene does not open), the selection and the accent wash, search matches, the warning, error and success colors (the status bar's sync icon is Obsidian's own error color), highlights, tables, the graph and canvas, and the syntax rows for references, tags and errors. They follow the same mapping.

## Research

- Obsidian's [Build a theme](https://docs.obsidian.md/Themes/App+themes/Build+a+theme) tutorial: variables shared by both schemes go on `body`, per-scheme ones under `.theme-light` and `.theme-dark`, and `:root` sparingly. The variables themselves come from the [CSS variables reference](https://docs.obsidian.md/Reference/CSS+variables/CSS+variables) and from `app.css` inside `obsidian.asar` (1.15.1), which shows every default, which ones mix with see-through colors, and how callouts and search highlights are drawn.
- Catppuccin for Obsidian (https://github.com/catppuccin/obsidian): sets Obsidian's `--color-base-*` scale and the `--color-<name>` and `-rgb` slots, so the semantic variables and plugins follow, and overrides syntax per token where Obsidian's groups are too coarse. This port takes the same two-layer method. Its colors and its Style Settings flavor picker are not used.
- Obsidian's own defaults mix most fills with `transparent` (hover, selection, tags, callouts, highlights). Each one the theme sets is a solid neutral or wash instead.

## Screenshot recipe

- Obsidian needs no account or license: its [license page](https://obsidian.md/license) says "Obsidian is free for all purposes, including personal, commercial, and non-profit use" and "You can download and use Obsidian without creating an account." Sync and Publish are optional paid services. A normal recipe.
- `screenshot.json` shoots the document scene (`build/photograph/scenes/document/`) in Obsidian 1.15.1, the official `obsidian_1.15.1_amd64.deb` from the [obsidian-releases](https://github.com/obsidianmd/obsidian-releases/releases/tag/v1.15.1) GitHub release, checked against its sha256 (`f77b6dfc...`), with `jq` and Ubuntu's `fonts-ibm-plex`.
- **apply** runs Install steps 4 to 8 for the variant being shot: it creates the theme folder named after the manifest's `name` in `~/Fireside/.obsidian/themes/` and copies both files.
- **Scripted stand-ins, not tested by hand:** Install steps 10 and 11 (pick the theme, set **Base color scheme**) and **Set the font** are one line that writes the vault's `appearance.json`: `cssTheme` set to the theme name, `theme` to `moonstone` (Light) for Day or `obsidian` (Dark) for Night, `monospaceFontFamily` to IBM Plex Mono, and `baseFontSize` 16. Install step 9 (restart) is the first launch.
- **stage** runs the scene's `obsidian/stage.sh`: it copies the two notes into the vault, registers the vault as open in `~/.config/obsidian/obsidian.json` with `updateDisabled`, so no vault picker and no update check, sets the window's place and size in the per-vault window file, writes `app.json` with the inline title off (the note's own heading is its title; this changes no color), and writes `workspace.json` with the note open in reading view beside the file explorer. Reading view has no blinking caret, so the screen settles.
- **launch** runs `obsidian` with `--no-sandbox` (Chromium's sandbox cannot start in the container), `--disable-gpu`, and `--disable-partial-raster` with `--ui-disable-partial-swap`, as VS Code's recipe does.
- **window** is matched by title, which names the note and the vault once the note is open.
- **Frame.** Obsidian on Linux draws its own title bar by default, so the shots show the port's title bar colors and no Adwaita frame.
- **Not tested:** Uninstall, and switching variants in **Settings**.
