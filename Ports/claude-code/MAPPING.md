# Claude Code: color mapping

For maintainers. The install guide is [README.md](README.md).

The port is one Claude Code custom theme per variant (`~/.claude/themes/<slug>.json`): `base` is the variant's mode (`light` or `dark`), and `overrides` sets every token Claude Code 2.1.326's built-in themes define, so nothing falls through to the base preset's colors. Claude Code takes solid colors only, so every wash is the build's solid wash over `base`, the Inglenook terminal background.

## Color mapping

Text and accents:

| App setting | Color | Why |
|---|---|---|
| `claude`, `claudeShimmer` (spinner, assistant label, welcome box) | `clay` | Claude's own brand color. Firelight means "you are here" and is never a brand color, so the slot takes the named color closest to the brand's terracotta |
| `clawd_body` (the mascot) | `clay` | the same brand color |
| `clawd_background` (cutouts in the mascot) | `base` | they show the background |
| `briefLabelClaude` | `clay` | the same brand color |
| `briefLabelYou` | `dim` | |
| `claudeBlue_FOR_SYSTEM_SPINNER`, its shimmer | `info` | in progress |
| `text` | `text` | |
| `inverseText` (text on colored badges) | `on_accent` | |
| `inactive`, `inactiveShimmer` (hints, timestamps, disabled items) | `faint` | metadata |
| `subtle` (faint borders, dividers, symbols) | `line` | |
| `suggestion` (autocomplete, picker highlight) | `accent` | |
| `permission`, `permissionShimmer` (dialog and picker borders) | `accent` | the dialog waiting for you |
| `remember` (memory and `CLAUDE.md` marks) | `reference` | a file reference |
| `skill` | `tag` | an annotation on the turn |
| `background`, `professionalBlue`, `chromeYellow` (undocumented) | `pine`, `steel`, `brass` | the named color closest to each default (teal, blue, yellow), so none falls through |

Status:

| App setting | Color | Why |
|---|---|---|
| `success` | `success` | |
| `error` | `error` | |
| `warning`, `warningShimmer` (also the auto mode mark) | `warning` | |
| `merged` | `dusk` | the purple of a merged pull request, without a role |

Input box and modes:

| App setting | Color | Why |
|---|---|---|
| `promptBorder`, `promptBorderShimmer` | `line` | a border |
| `planMode` | `info` | |
| `autoAccept`, `autoAcceptShimmer` (accept-edits mode) | `warning` | edits land without asking: caution |
| `bashBorder` (`!` shell commands) | `heather` | the default is pink; heather is the pink named color, kept apart from roles |
| `ide` | `info` | |
| `fastMode`, `fastModeShimmer` | `clay` | the default is orange |
| `effortUltra` | `heather` | |

Surfaces and highlights:

| App setting | Color | Why |
|---|---|---|
| `diffAdded`, `diffAddedWord` | `success` wash | |
| `diffRemoved`, `diffRemovedWord` | `error` wash | |
| `diffAddedDimmed`, `diffRemovedDimmed` (rejected edits) | `raised` | |
| `userMessageBackground` | `raised` | a card |
| `userMessageBackgroundHover` | `hover` | |
| `selectionBg` | `accent` wash | |
| `bashMessageBackgroundColor` | `heather` wash | matches `bashBorder` |
| `memoryBackgroundColor` | `pine` wash | matches `remember` |
| `composerSidebarBackground` | `deep` | a side panel |

Usage meter:

| App setting | Color | Why |
|---|---|---|
| `rate_limit_fill` | `info` | a progress bar, not "you are here" |
| `rate_limit_empty` | `line` | |

Subagent colors are names, not meanings, so each takes the named color it names: `red` ember, `blue` steel, `green` moss, `yellow` brass, `purple` dusk, `orange` clay, `pink` heather, `cyan` pine (`<color>_FOR_SUBAGENTS_ONLY`).

The `ultrathink` rainbow (`rainbow_*` and `rainbow_*_shimmer`, 14 tokens) is all `heather`, like `effortUltra`. Every shimmer token takes its base token's color.

## Gaps and trade-offs

- **Tier 2: code colors are not themeable.** Code blocks, diffs and file previews use Claude Code's built-in highlighter, which custom themes cannot reach, so the syntax mapping is not applied. The shots show its colors on the diff's code.
- **Inline code is not themeable.** It should be `literal`. In 2.1.326 the Markdown renderer colors inline code, and fenced code with no language, with `permission` looked up by the base preset's name, so the custom theme's override never reaches it: lavender in Night, blue-violet in Day (`palette/palette.json` in the shots). An `-ansi` base would turn it the terminal's ANSI blue, the wrong role, and change every other default, so it is not used.
- **Washes assume an Inglenook terminal.** They are solid colors mixed over `base`.
- **No word-level diff emphasis.** `diffAddedWord` and `diffRemovedWord` get the line's wash: the palette has one wash strength.
- **No shimmer and no rainbow.** Inglenook does not put gradients on text.
- **Cannot follow the OS light or dark setting.** `auto` switches only between built-in themes.
- **The user message card is faint in Day.** `raised` is a shade lighter than the Day background.
- **Colors the scene does not show:** `claude` (a replayed session is still, so no spinner draws, and the welcome box has scrolled off), `info` (system spinner, plan mode, IDE mark), `accent` (no dialog or picker is open; the cursor is the host's), `reference` and the pine wash (memory notes), `tag` (skills), `dusk` (merged), `hover`, `deep` and the accent wash (fullscreen mode only), the usage meter, and the subagent colors.

## Research

- Format from the [custom theme docs](https://code.claude.com/docs/en/terminal-config#create-a-custom-theme): file location, `name`, `base`, `overrides`, color formats, the token reference, and live reload. Token list checked against the built-in themes in the 2.1.326 binary, which adds the undocumented `background`, `professionalBlue`, `chromeYellow`, `clawd_body` and `clawd_background`.
- Settings facts in the README: the `custom:<slug>` value and `auto` ([`theme`](https://code.claude.com/docs/en/settings-reference#theme)), `CLAUDE_CONFIG_DIR` and settings precedence ([settings](https://code.claude.com/docs/en/settings)).
- Port studied: [Dracula for Claude Code](https://github.com/dracula/claude-code), MIT. It is a built-in code theme for the desktop app and claude.ai, not a CLI theme file. No Catppuccin, Nord or Rose Pine port of the CLI format existed. No files or colors reused.
- The retired Hyaline theme's port (`../Hyaline/Ports/claude-code`) was the starting point for the token list, the inline code finding and the recipe.

## Screenshot recipe

- No login or key is needed to reach the themed screen: `claude --resume` replays a saved session from a file with no model call. Claude Code needs an account to send a prompt, not to start and draw a saved session. The footer shows "Not logged in · Run /login" in `error`.
- The recipe is a guest of the GNOME Terminal port (`host`), so the shot is in an Inglenook terminal on the same variant.
- **install** fetches the official 2.1.326 Linux build, checked against the sha256 in its release manifest, and adds Symbola, a fallback for the few symbols BlexMono Nerd Font lacks (the tool result corner and the mode arrows). Without it they draw as boxes.
- **apply** follows Install steps 3 to 5. Not tested by hand: steps 7 and 8 (run `/theme`, pick the variant) are the `"theme": "custom:inglenook-<variant>"` line in `~/.claude/settings.json`, which the README gives as the by-hand alternative. Step 6, the restart, is the host starting Claude Code after the files are in place.
- **stage** runs `build/photograph/scenes/cli/claude-code/stage.sh`: first-run questions answered ahead in `~/.claude.json`, auto-update and other non-essential traffic off, and the saved session copied where `claude --resume` finds it. It never sets a color.
