# Ghidra: color mapping

For maintainers. The install guide is [README.md](README.md).

## Layout

One `.theme` file per variant, built on FlatLaf: Day on **Flat Light** with `useDarkDefaults = false`, Night on **Flat Dark** with `useDarkDefaults = true` (`values.json`). Anything the theme does not set falls back to that look and feel and to Ghidra's own light or dark defaults.

- **Content** (`base`): the listing, decompiler, byte viewer, trees, tables and the terminal.
- **Recessed** (`deep`): panels, toolbars, split panes, tab strips, table headers, scrollbar tracks, alternate table rows, undefined bytes.
- **Frame** (`deeper`): the menu bar and the docking headers of windows without focus.
- **Raised** (`raised`): buttons, inputs, combo boxes, popup menus, tooltips, the current line.
- **Hover** (`hover`): hovered buttons, menu bar items and tabs.

## Color mapping

**Look and Feel groups** (`[color]system.color.*`, which Ghidra maps onto every Swing widget)

| App setting | Color | Why |
|---|---|---|
| `bg.view` | `base` |  |
| `fg.view`, `fg.control`, `fg.tooltip`, `fg.selected.view` | `text` | selected rows keep body text on the wash |
| `bg.control`, `bg.tooltip` | `raised` |  |
| `bg.selected.view` | `accent` wash | selection |
| `bg.border` | `line` |  |
| `fg.disabled` | `faint` |  |

**Look and Feel widgets** (`[laf.color]*`, FlatLaf keys the groups do not reach)

| App setting | Color | Why |
|---|---|---|
| `Panel`, `SplitPane`, `ToolBar`, `TabbedPane` background, `ScrollBar.track`, `TableHeader.background`, `ProgressBar.background` | `deep` |  |
| `MenuBar.background`, `Menu.background` | `deeper` |  |
| `PopupMenu`, `MenuItem`, `Button`, `TextField`, `FormattedTextField`, `PasswordField`, `ComboBox`, `ComboBox.buttonBackground`, `Spinner` background | `raised` |  |
| `TabbedPane.selectedBackground` | `base` | the open tab joins the content |
| `MenuBar.hoverBackground`, `Button.hoverBackground`, `Button.pressedBackground`, `ToggleButton.selectedBackground`, `TabbedPane.hoverColor` | `hover` |  |
| `Menu`, `MenuItem`, `CheckBoxMenuItem`, `RadioButtonMenuItem` selection background, `Button.default.*` background and border, `Component.focusColor`, `Component.focusedBorderColor`, caret colors, `TabbedPane.underlineColor`, `ProgressBar.foreground`, `CheckBox.icon.selected*`, `Hyperlink.linkColor` | `accent` |  |
| menu selection foregrounds, `Button.default.foreground`, `ProgressBar.selectionForeground`, `CheckBox.icon.checkmarkColor` | `on_accent` |  |
| `Table`, `Tree`, `List` inactive selection background | `accent` wash |  |
| `MenuBar.borderColor`, `PopupMenu.borderColor`, `Separator.foreground`, `Component.borderColor`, `Component.disabledBorderColor`, `Button.borderColor`, `TabbedPane.contentAreaColor`, `ScrollBar.thumb`, `TableHeader.*SeparatorColor`, `Table.gridColor` | `line` |  |
| `ScrollBar.hoverThumbColor`, `ScrollBar.pressedThumbColor`, `TabbedPane.inactiveUnderlineColor`, `TextField.placeholderForeground` | `faint` |  |
| `MenuItem.acceleratorForeground` | `dim` |  |
| `TableHeader.foreground`, inactive selection foregrounds, `ProgressBar.selectionBackground` | `text` |  |

**Shared app colors**

| App setting | Color | Why |
|---|---|---|
| `color.fg.error`, `color.fg.error.table.selected`, `color.fg.table.offcut.selected` | `error` |  |
| `color.fg.messages.alert`, `color.fg.messages.warning`, `color.border.provider.disconnected` | `warning` |  |
| `color.fg.messages.normal`, `color.fg.dialog.status.normal`, `color.fg.glasspane.message` | `info` | status messages |
| `color.fg.disabled`, `color.fg.messages.hint`, `color.fg.textfield.hint`, `color.cursor.unfocused`, `color.fg.table.uneditable.unselected` | `faint` |  |
| `color.fg.table.uneditable.selected`, `color.fg.header.inactive`, `color.fg.widget.tabs.unselected` | `dim` |  |
| `color.cursor.focused`, `color.border.button.focused` | `accent` |  |
| `color.bg.selection`, `color.bg.header.active`, `color.bg.widget.tabs.selected.active`, `color.bg.table.row.drag`, `color.bg.tree.drag`, `color.bg.plugin.colorizer.default` | `accent` wash | selection and "you are here" |
| `color.bg.find.highlight` (and `color.bg.search.highlight`, which points at it), `color.bg.highlight` | `steel` wash | matches, per ADR 0009. `color.bg.highlight` is also the middle-click highlight of every use of a token |
| `color.bg.find.highlight.active` | `accent` wash | the current match; see Gaps |
| `color.bg.currentline`, `color.bg.textfield.hint.valid`, `color.bg.widget.tabs.list`, `color.bg.messageoverlay` | `raised` |  |
| `color.bg.table.row.alt`, `color.bg.widget.tabs.unselected`, `color.bg.filechooser.shortcut`, `color.bg.undefined` | `deep` |  |
| `color.bg.header.inactive` | `deeper` | docking headers of windows without focus sit back |
| `color.bg.widget.tabs.selected.inactive`, `color.bg.widget.tabs.highlighted`, `color.bg.widget.tabs.more.tabs.hover` | `hover` |  |
| `color.bg.filterfield`, `color.bg.formatted.field.editing` | `warning` wash | a filter is on, a value is not committed yet |
| `color.bg.textfield.hint.invalid`, `color.bg.formatted.field.error` | `error` wash |  |
| `color.bg.table.grid`, `color.border.bevel.*` | `line` |  |
| `color.fg.dialog.equates.equate` | `literal` | equates name numbers |
| bookmarks: `error`, `warning`, `info`, `note`, `default`, `analysis` | `error`, `warning`, `info`, `keyword`, `tag`, `literal` | the margin marks; analysis bookmarks are the most common, so they get a quiet color with no state meaning |

**Listing**

| App setting | Color | Why |
|---|---|---|
| `color.bg.listing` | `base` |  |
| `color.fg.listing.address`, `label.non.primary`, `block.start`, `function.param.auto`, `function.param.dynamic`, `flow.arrow.active` | `dim` |  |
| `bytes`, `bytes.alignment`, every `comment.*` but offcut, `function.source`, `separator`, `xref.offcut`, `stack.depth`, `collapsed`, `flow.arrow.inactive` | `faint` | bytes are supporting data beside the instruction |
| `mnemonic`, `instruction.parallel`, `pcode.address.space` | `keyword` | instructions read as the keywords of assembly |
| `constant`, `function.purge`, `mask.bits`, `mask.value` | `literal` | immediate values; strings too, see Gaps |
| `function.name`, `ext.entrypoint`, `fieldname`, `register`, `pcode.userop` | `info` | functions and properties per the syntax mapping; registers are the closest row |
| `function.return.type` | `type` |  |
| `label.primary`, `label.local`, `xref`, `xref.read`, `ext.ref.resolved`, `pcode.label` | `reference` | labels are anchors, cross references are references |
| `xref.write` | `warning` | a write changes the target |
| `function.tag`, `function.callfixup`, `mnemonic.override` | `tag` | annotations |
| `comment.offcut`, `ref.bad`, `ext.ref.unresolved`, `mnemonic.unimplemented` | `error` |  |
| `function.param`, `function.param.custom`, `function.variable*`, `label.unreferenced`, `pcode.varnode`, `header.active.field` | `text` | plain identifiers |
| `flow.arrow.selected`, `underline` | `accent` |  |
| `color.bg.listing.header.active.field` | `accent` wash |  |
| `highlighter.middle.mouse` | `steel` wash | every use of the clicked token: a match |
| `highlighter.scoped.read` | `reference` wash |  |
| `highlighter.scoped.write`, `color.bg.highlight.listing.diff`, `comparison.bytes`, `comparison.mnemonic`, `comparison.operand`, `comparison.code.units.diff` | `warning` wash | change |
| `comparison.code.units.unmatched` | `hover` | no meaning beyond "not paired" |
| `color.bg.listing.error` | `error` wash |  |

**Decompiler**

| App setting | Color | Why |
|---|---|---|
| `color.bg.decompiler` | `base` |  |
| `color.fg.decompiler`, `variable`, `parameter`, `message` | `text` |  |
| `keyword` | `keyword` |  |
| `comment` | `faint` |  |
| `constant` | `literal` | numbers and strings, one setting |
| `type` | `type` |  |
| `global` | `reference` | globals are references to memory |
| `external.function` | `info` |  |
| `special` | `tag` |  |
| `error` | `error` |  |
| `color.bg.decompiler.message` | `raised` |  |
| `current.variable`, `highlights.find` | `steel` wash | every use of the token at the cursor, every find match |
| `highlights.find.active` | `accent` wash | the current match |
| `highlights.default` | `literal` wash | the default color of a highlight the user adds; Ghidra's own is a see-through yellow |
| `highlights.special` | `error` wash |  |

**Byte viewer**

| App setting | Color | Why |
|---|---|---|
| `color.bg.byteviewer` | `base` |  |
| `color.bg.byteviewer.highlight` | `steel` wash |  |
| `color.fg.byteviewer.changed` | `warning` |  |
| `separator`, `boundary.crossing`, unfocused cursors | `faint` |  |
| focused cursors | `accent` |  |

**Terminal** (`color.fg.plugin.terminal.*`)

| App setting | Color | Why |
|---|---|---|
| `color.bg.plugin.terminal` | `base` |  |
| `color.fg.plugin.terminal` | `text` |  |
| `normal.<slot>`, `dim.<slot>` | `ansi.<slot>` | Ghidra draws normal text bold and dim text plain, in the same colors |
| `bright.<slot>` | `ansi.bright_<slot>` |  |

Fonts are not in the theme: a family that is not installed falls back to Java's proportional Dialog font, which breaks the listing. The README sets `font.monospaced` by hand.

## Gaps and trade-offs

- **Current match**: the ADR wants a firelight fill with `on_accent` text, or a steel wash with a firelight border where syntax colors stay. Ghidra's find highlights are a background only, with the syntax colors kept and no border. The current match is an `accent` wash, the nearest "you are here" that keeps the text readable.
- **Strings**: Ghidra has no string color in the listing or the decompiler. Strings take `constant`, which is `literal`.
- **Not themed**: graph vertices and edges (`color.bg.graph.*`, `color.*.functiongraph.*`, `color.bg.decompiler.pcode.dfg.*`), the Debugger, Version Tracking, BSim and Program Diff colors, the interpreter console's ANSI colors, and the splash screen (`color.bg.splashscreen` is "always black" in Ghidra's own file and is drawn before the theme loads). They keep Ghidra's light or dark defaults.
- **`laf.palette.color.NN`**: FlatLaf colors the groups do not cover land in numbered palette ids that change between look and feels and Ghidra versions. The theme names the FlatLaf keys instead, so a few rarely seen widgets keep FlatLaf's grays.
- **Screenshot coverage**: the scene is the CodeBrowser on `/bin/true`. It shows the menu bar, toolbars, docking headers, program tree, symbol tree, listing (addresses, bytes, mnemonics, registers, constants, labels, xrefs, comments), the decompiler (keywords, types, constants, comments), the cursor and the current line. It does not show find matches, the byte viewer, the terminal, bookmarks, filter fields, or error states.

## Research

- [catppuccin/ghidra](https://github.com/catppuccin/ghidra) (MIT): one `.theme` per flavor, imported with **Edit** > **Theme** > **Import...**, the header keys `name`, `lookAndFeel`, `useDarkDefaults`, and the `system.color.*` groups as the main lever. It also overrides numbered `laf.palette.color.NN` ids, which this port avoids. Method only.
- Ghidra 12.2 source: `ThemeWriter.java` writes the header keys `name`, `lookAndFeel` and `useDarkDefaults`. The user documentation still shows `Look and Feel = ...`; the reader follows the source.
- `AbstractThemeReader.java`: a line starting with `#` is a comment, and anything after `//` on a line is dropped.
- `ThemePreferences.java`: the active theme is the `Theme` preference, `File:<path>` for a theme in the user's `themes` folder.
- Default ids and values: `gui.theme.properties`, `docking.theme.properties`, `base.theme.properties`, `base.listing.theme.properties`, `decompiler.theme.properties`, `byteviewer.theme.properties` in the 12.2 tag. Every app id the theme sets was checked against them.

## Screenshot recipe

- Ghidra needs no login or license: it is Apache 2.0 ([LICENSE](https://github.com/NationalSecurityAgency/ghidra/blob/master/LICENSE)). Its first-run user agreement is skipped with the `USER_AGREEMENT=ACCEPT` preference, the tip of the day with `SHOW_TIPS=false`, and the What's New page with `GhidraShowWhatsNew=false`.
- The release zip is pinned by version and sha256, and so is the Temurin JDK 25 it needs (`application.java.min=25`).
- The scene is `/bin/true` from the image, imported and analyzed with `analyzeHeadless`, then opened with `ghidraRun <project>.gpr:/true`, which opens the CodeBrowser on it. The project window opens too and sometimes lands on top, so the launch minimizes it once both windows are up. Kind `editor`, without the editor scene's content: no scene kind fits a disassembler better.
- Not tested by hand: the recipe copies the theme file into `~/.config/ghidra/ghidra_12.2_PUBLIC/themes/` and sets the `Theme` preference, standing in for **Edit** > **Theme** > **Import...**; it appends a `font.monospaced` line to the copy, standing in for the font steps in the Theme editor.
