# Insomnia: color mapping

For maintainers. The install guide is [README.md](README.md).

Insomnia turns a theme's blocks into CSS variables (`--color-bg`, `--color-font`, `--color-<state>`, `--color-font-<state>`, `--hl`, `--hl-xxs` to `--hl-xl`) on `:root` and on each `styles` part (`.theme--sidebar` and the rest), then appends `rawCss` after them (`generateThemeCSS` in `packages/insomnia/src/ui/plugins/misc.ts`, core@13.4.0). The app's own CSS sits in the `base` cascade layer, so the unlayered `rawCss` wins over its normal rules. Where the app uses `!important` (method colors, line numbers), the theme sets the variable on that element instead.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `background.default`, `pane`, `paneHeader`, `editor` | base | |
| `appHeader` | deeper | The title strip |
| `sidebar`, `sidebarHeader`, `sidebarList` | deep | |
| `dialog`, `dialogHeader`, `dialogFooter`, `dropdown`, `tooltip` | raised | |
| `foreground.default` | text | |
| `background.surprise` | accent | Insomnia's own accent: Send, primary buttons, the selected row's bar, the active tab mark |
| `foreground.*` (text on a state fill) | on_accent | Text on every solid fill: Send, the status tag, the method button |
| `background.success` | success | POST, 2xx status |
| `background.warning`, `background.notice` | warning | PUT, PATCH, 4xx status. Insomnia's notice is its yellow, a caution |
| `background.danger` | error | DELETE, 5xx status, lint marks |
| `background.info` | info | 1xx status, info notes |
| 3xx status tag (`.tag.bg-surprise`) | info | Insomnia draws redirects in its accent; a redirect is information, not "you are here" |
| `highlight.default` | faint | Insomnia's subtle text: placeholders, toolbar icons, metadata |
| `highlight.xxs` | deep | Faint fills behind rows and inputs |
| `highlight.xs` | hover | Hovered and selected rows, the active line |
| `highlight.sm`, `highlight.md` | line | Borders and dividers |
| `highlight.lg` | faint | Input borders, placeholders |
| `highlight.xl` | dim | Secondary text |
| `link` foreground | accent | |
| Editor selection, `::selection` | accent wash | |
| Editor cursor, matching-bracket underline | accent | |
| Editor search matches (`.cm-searching`) | steel wash, text | ADR 0009. CodeMirror's search marks every match the same, so there is no current-match fill |
| Line numbers | faint | |
| JSON keys (`.cm-string.cm-property`), properties, attributes, builtins, defs | info | Syntax mapping: keys and functions |
| Strings | success | |
| Numbers | literal | |
| `true`, `false`, `null` (`.cm-atom`), keywords, headers | keyword | |
| Types (`.cm-variable-3`, `.cm-type`) | type | |
| Tags | tag | |
| Links, template variables and tags (`{{ }}`, `{% %}`) | reference | References to environment values |
| Brackets, meta, qualifiers | dim | |
| Comments | faint | |
| Errors (`.cm-error`) | error | Text only, no fill |
| GET, QUERY, GraphQL method | info | Reading. Insomnia draws them in its accent, which would make every GET look like "you are here" |
| POST | success | Creating |
| PUT, PATCH | warning | Changing |
| DELETE | error | Removing |
| HEAD, OPTIONS | dim | Asking about a resource, no state |
| Method button beside the URL | the method's color, solid, on_accent text | The app's darkening gradient is removed |
| Method tags in the sidebar and tabs | the method's color as a wash, text on it (HEAD and OPTIONS: hover) | The app draws them at 50% opacity; the theme makes them solid chips |

## Gaps and trade-offs

- JSON punctuation has no token class in CodeMirror's JSON mode, so braces, commas and colons stay `text`, not `dim`. Coloring all unclassed text dim would dim plain-text bodies too.
- Search has one look for every match: CodeMirror's search addon marks the match at the cursor only through the selection, which is the accent wash.
- The modal backdrop (`.theme--transparent-overlay`) keeps Insomnia's own see-through dark layer. The theme does not set it, since a solid one would hide the app behind every dialog.
- Hard-coded app colors the variables do not reach: the Insomnia logo, the Welcome page's animated lines, the gRPC method color, the fat (vim) cursor, the diff colors in the merge editor, and some `rgba(...)` text that fades `--color-font` to 80%.
- The Monaco editor (used for OpenAPI specs) takes its colors from Insomnia's light or dark Monaco theme, not from these variables.
- The scene cannot show: search matches, the selection, errors, types, tags, references, comments, PUT/PATCH/DELETE in the URL bar, 3xx to 5xx status tags, dialogs and dropdowns.

## Research

- Catppuccin for Insomnia (github.com/catppuccin/insomnia): one plugin, `module.exports.themes` built from the background, foreground and highlight blocks plus a few `styles` parts (sidebar, dialog, paneHeader, appHeader). Their comments mapping each state slot to what it colors (POST, PATCH, PUT, DELETE, GET, OPTIONS/HEAD, Send) confirmed what the source shows. Method only.
- Insomnia's built-in themes (`packages/insomnia/src/plugins/themes/*.ts`) and `baseTheme` in `misc.ts`: any highlight a theme leaves out falls back to translucent grays, so this theme sets all seven, solid.
- The app's CSS (`packages/insomnia/src/ui/css/main.css`, `styles.css`) for where each variable lands: `.editor .cm-*` token rules, `.http-method-*` and `.bg-http-method-*`, `.tag.bg-*` for the status.

## Screenshot recipe

- Login: not required. Kong's docs say the local Scratch Pad can be used before logging in, from the login screen ([Storage options](https://developer.konghq.com/insomnia/storage/)), and on a fresh install with no earlier login Insomnia opens the Scratch Pad itself (`getInitialEntry` in `packages/insomnia/src/ui/utils/router.ts`). The Login and Sign up buttons stay on screen; the recipe never uses them.
- Pinned to Insomnia 13.4.0, the `.deb` from Kong's GitHub release, checked against the release's published sha256.
- Not tested by hand: the recipe picks the theme by writing `theme` into `insomnia.Settings.db` (the reader clicks it in **Preferences** > **Themes**), and the stage adds the editor font and turns off analytics, update prompts, the sidebar tip and the menu bar in the same file.
- Not tested by hand: `insomnia-scene/onboarded.mjs` stands in for three clicks (Continue on the first-run Welcome page, Create order in the sidebar, its Body tab). The Welcome page keeps its answer only in the window's localStorage, so the script sets that key over the DevTools protocol, then clicks the two elements, then drops focus so no caret blinks.
