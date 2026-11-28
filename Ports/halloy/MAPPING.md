# Halloy: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Theme file (`inglenook-<variant>.toml`), every key from Halloy's custom theme guide:

| App setting | Color | Why |
|---|---|---|
| general.background | deep | The window behind the panes: the sidebar and the gaps between panes |
| general.border | line | |
| general.horizontal_rule | line | |
| general.horizontal_rule_text | faint | |
| general.scrollbar | line | |
| general.unread_indicator | info | The dot beside a buffer with unread messages: information |
| general.highlight_indicator | warning | The mark beside a buffer where someone mentioned you: asks for attention, not "you are here" |
| text.primary | text | |
| text.secondary | dim | |
| text.tertiary | faint | |
| text.success, error, warning, info | success, error, warning, info | |
| text.debug | dim | Log levels in the logs buffer; debug and trace stay quiet |
| text.trace | faint | |
| buttons.primary.background | deep | Sidebar buffer buttons sit on the sidebar |
| buttons.primary.background_hover | hover | |
| buttons.primary.background_selected, background_selected_hover | accent wash | The focused buffer is "you are here" |
| buttons.primary.border_active | accent | |
| buttons.secondary.background | raised | Lifted controls: menu items, dialog buttons |
| buttons.secondary.background_hover | hover | |
| buttons.secondary.background_selected, background_selected_hover | accent wash | |
| buttons.secondary.border_active | accent | |
| buffer.background | base | Where the chat lives |
| buffer.background_text_input | raised | An input |
| buffer.background_title_bar | deeper | Pane title bars |
| buffer.border | line | |
| buffer.border_selected | accent | The focused pane |
| buffer.focus_border | accent | Keyboard focus |
| buffer.focus_background | raised | |
| buffer.highlight | accent wash | The message you jumped to, and the row under the mouse: "you are here" |
| buffer.selection | accent wash | Text selection |
| buffer.action | dim, italic | `/me` actions read as narration, set apart by italics, not a color |
| buffer.code | literal | Inline monospace text |
| buffer.nickname | dusk | The one nickname color in `"solid"` mode. A named color with no state meaning |
| buffer.nickname_offline | faint | |
| buffer.timestamp | faint | Metadata |
| buffer.topic | dim | |
| buffer.url | accent | Links are accent |
| buffer.backlog_rule, backlog_rule_text | accent | The "new messages" line marks where you left off |
| buffer.date_rule | line | |
| buffer.date_rule_text | faint | |
| buffer.server_messages.default | faint | Joins, parts, mode changes stay quiet |
| server_messages.join, monitored_online | success | Someone arrived |
| server_messages.kick, standard_reply_fail | error | |
| server_messages.standard_reply_warn | warning | |
| server_messages.standard_reply_note | info | |
| formatting.white, black, grey, lightgrey | ANSI bright white, black, bright black, white | mIRC's neutrals, by brightness, as in a terminal |
| formatting.red, green, yellow, blue, magenta, cyan | ember, moss, brass, steel, heather, pine | The terminal mapping |
| formatting.lightgreen, lightcyan, lightblue | ANSI bright green, bright cyan, bright blue | The same hue, slightly stronger |
| formatting.brown | oxblood | Closest named color |
| formatting.orange | clay | Firelight is the accent, so never a message color |
| formatting.pink | rosewood | Closest named color |

Nickname list (`nicknames.toml`, a `[buffer.nickname]` snippet for `config.toml`):

| App setting | Color | Why |
|---|---|---|
| buffer.nickname.color palette | clay, pine, dusk, heather, rosewood, oxblood, ivy | Named colors only. No firelight (the accent), and no ember, brass, moss or steel, whose roles mean failure, caution, success and information. A nickname is a person, not a state |

## Gaps and trade-offs

- Halloy's default nickname color mode, `"unique"`, keeps the theme nickname color's saturation and lightness and randomizes the hue in OKHSL. That makes colors the palette does not have, so the README sets `"solid"` (one color, from the theme) or the palette list.
- The nickname palette lives in `config.toml`, not in the theme file, so one `config.toml` cannot hold a Day list and a Night list. While following the system (`theme = { light, dark }`), nicknames use `"solid"`. The list is offered per variant for readers who use one variant.
- Halloy draws some colors with its own alpha: `buffer.highlight` fades out after a jump and is drawn faint under the hovered row, and away nicknames are dimmed against the background. The theme's colors are solid; the blend is the app's.
- mIRC white on Day and black on Night are nearly the background, as in a terminal.
- Halloy has no search with match highlighting, so ADR 0009 does not apply.
- Halloy's own icons (the sidebar menu, title bar buttons) take the text colors; nothing to map.
- The screenshots cannot show: `buffer.highlight` (only after a jump or under the mouse), text selection, kick and standard replies, the logs buffer's debug and trace colors, `nickname_offline`, and button hover states. The scripted join and quit are sent but Halloy does not list them in the channel, so the join color is not shown either.
- Channel names are links, so the pane title's channel name is in the link color.

## Research

- [catppuccin/halloy](https://github.com/catppuccin/halloy): one TOML file per flavor in Halloy's `themes` folder, picked by `theme = "<file name>"`. Covers only a subset of keys (no warning, info, server message kinds, formatting, focus or rules). Method only.
- Halloy's own Ferra theme (`assets/themes/ferra.toml` in the Halloy repo) as the reference for which keys a full theme sets.
- Source checked at tag 2026.9 and 2026.10: `data/src/appearance/theme.rs` for every key and its fallback (`focus_border` falls back to `border_selected`, `focus_background` to `background_text_input`, missing colors to transparent), and `nickname_color` / `compute_randomized_color` for the nickname modes. The theme keys are the same in both tags.
- `theme` is a root key: it must come before every section in `config.toml`, or TOML reads it as part of that section.

## Screenshot recipe

- Halloy is free software (GPL-3.0) and needs no login or license. The themed window needs a connection to show chat, so the scene runs `build/photograph/scenes/app/halloy/irc.py`, a scripted local IRC server with a fixed conversation and fixed server-time stamps. No real network.
- The recipe pins 2026.9: the 2026.10 Linux build needs glibc 2.43, newer than the base image's Ubuntu 24.04. The theme keys are the same in both.
- Halloy renders with wgpu; in the container it draws through Mesa's software renderer (llvmpipe), installed by the recipe.
- The stage steps write the server, the font and `check_for_update_on_launch = false` into `config.toml`; a reader adds their own servers by hand. Not tested by hand.
- Halloy has no setting to open a channel at launch, so `scenes/app/halloy/open.sh` clicks `#inglenook` in the sidebar, as a reader would, and moves the pointer back to the corner.
- The message box cursor blinks, so the screen would never settle. `scenes/app/halloy/launch.sh` loads libfaketime into Halloy with the clock running; `open.sh` stops that clock just before the click, so the cursor shows and stays. Only Halloy's clock is affected; the messages carry fixed server-time stamps.
