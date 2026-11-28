# VS Code: color mapping

For maintainers. The install guide is [README.md](README.md).

## Layout

- **Frame** (`deeper`): title bar, activity bar, status bar, the empty part of the tab strip, and inactive tabs.
- **Recessed** (`deep`): the side bar, the bottom panel and the terminal in it, and the peek view's result list and title.
- **Content** (`base`): the editor, its gutter and minimap, the active tab, breadcrumbs, sticky scroll, and the peek view's editor. Running code always sits on `base`.
- **Raised** (`raised`): inputs, dropdowns, menus, quick pick, the command center, notifications, and the hover, suggest and find widgets. The current line and range highlights are `raised` too.
- **Hover** (`hover`): hovered rows, tabs, status bar items, and secondary buttons.
- **Washes**: selections, find matches, word highlights, diff and merge lines.

Each variant is its own extension (`dist/day/`, `dist/night/`), with `uiTheme` from `values.json` (`vs` for Day, `vs-dark` for Night), so unset keys fall back to Light Modern or Dark Modern.

## Color mapping

Every color the theme sets. Every key was checked against the [Theme Color reference](https://code.visualstudio.com/api/references/theme-color).

**Base**

| App setting | Color | Why |
|---|---|---|
| `foreground` | `text` |  |
| `descriptionForeground`, `icon.foreground` | `dim` |  |
| `disabledForeground`, `scrollbarSlider.hoverBackground` | `faint` |  |
| `errorForeground` | `error` |  |
| `focusBorder`, `sash.hoverBorder`, `textLink.foreground`, `textLink.activeForeground`, `scrollbarSlider.activeBackground`, `progressBar.background`, `badge.background` | `accent` |  |
| `selection.background` | `accent` wash |  |
| `textPreformat.foreground` | `literal` |  |
| `textPreformat.background`, `textBlockQuote.background`, `textCodeBlock.background` | `raised` |  |
| `textBlockQuote.border`, `textSeparator.foreground`, `scrollbarSlider.background` | `line` |  |
| `scrollbar.shadow` | transparent | switched off |
| `badge.foreground` | `on_accent` |  |

**Title bar, activity bar, status bar**

| App setting | Color | Why |
|---|---|---|
| `titleBar.activeBackground`, `titleBar.inactiveBackground`, `activityBar.background`, `activityBarTop.background`, `statusBar.background`, `statusBar.noFolderBackground` | `deeper` | the most recessed frame |
| `titleBar.activeForeground`, `commandCenter.foreground`, `commandCenter.activeForeground`, `activityBar.foreground`, `activityBarTop.foreground`, `statusBar.foreground`, `statusBar.noFolderForeground`, `statusBarItem.hoverForeground` | `text` |  |
| `titleBar.inactiveForeground`, `activityBar.inactiveForeground`, `activityBarTop.inactiveForeground` | `dim` |  |
| `titleBar.border`, `window.inactiveBorder`, `commandCenter.border`, `commandCenter.inactiveBorder`, `activityBar.border`, `statusBar.border` | `line` |  |
| `window.activeBorder`, `commandCenter.activeBorder`, `menubar.selectionBackground`, `activityBar.activeBorder`, `activityBarTop.activeBorder`, `activityBar.dropBorder`, `activityBarTop.dropBorder`, `activityBarBadge.background`, `statusBar.focusBorder`, `statusBar.debuggingBackground`, `statusBarItem.remoteBackground`, `statusBarItem.prominentBackground` | `accent` |  |
| `commandCenter.background`, `commandCenter.activeBackground` | `raised` |  |
| `menubar.selectionForeground`, `activityBarBadge.foreground`, `statusBar.debuggingForeground`, `statusBarItem.remoteForeground`, `statusBarItem.prominentForeground`, `statusBarItem.errorForeground`, `statusBarItem.warningForeground` | `on_accent` |  |
| `statusBarItem.hoverBackground`, `statusBarItem.activeBackground` | `hover` |  |
| `statusBarItem.errorBackground` | `error` |  |
| `statusBarItem.warningBackground` | `warning` |  |

**Side bar, panels, tabs**

| App setting | Color | Why |
|---|---|---|
| `sideBar.background`, `sideBarSectionHeader.background`, `panel.background`, `panelSectionHeader.background` | `deep` | recessed beside the editor |
| `sideBar.foreground`, `sideBarTitle.foreground`, `sideBarSectionHeader.foreground`, `tab.activeForeground`, `tab.unfocusedActiveForeground`, `breadcrumb.focusForeground`, `breadcrumb.activeSelectionForeground`, `panelTitle.activeForeground`, `panelSectionHeader.foreground` | `text` |  |
| `sideBar.border`, `sideBarSectionHeader.border`, `editorGroupHeader.tabsBorder`, `editorGroup.border`, `tab.unfocusedActiveBorderTop`, `tab.border`, `panel.border`, `panelSectionHeader.border` | `line` |  |
| `sideBar.dropBackground`, `editorGroup.dropBackground` | `accent` wash |  |
| `editorGroupHeader.tabsBackground`, `tab.inactiveBackground`, `tab.unfocusedInactiveBackground` | `deeper` | inactive tabs sit back in the tab strip |
| `editorGroupHeader.noTabsBackground`, `tab.activeBackground`, `tab.unfocusedActiveBackground`, `breadcrumb.background` | `base` |  |
| `tab.inactiveForeground`, `tab.unfocusedInactiveForeground`, `breadcrumb.foreground`, `panelTitle.inactiveForeground` | `dim` |  |
| `tab.activeBorderTop`, `panel.dropBorder`, `panelTitle.activeBorder` | `accent` |  |
| `tab.hoverBackground`, `tab.unfocusedHoverBackground` | `hover` |  |
| `tab.activeModifiedBorder`, `tab.inactiveModifiedBorder` | `warning` |  |
| `breadcrumbPicker.background` | `raised` |  |

**Lists and trees**

| App setting | Color | Why |
|---|---|---|
| `list.activeSelectionBackground`, `list.focusAndSelectionOutline`, `list.focusOutline`, `list.inactiveFocusOutline` | `accent` |  |
| `list.highlightForeground` | `steel` | Matched characters in lists and the quick pick, per Search and matches in PHILOSOPHY.md. On the focused row they are `on_accent` (`list.focusHighlightForeground`) |
| `list.activeSelectionForeground`, `list.activeSelectionIconForeground`, `list.focusHighlightForeground` | `on_accent` |  |
| `list.inactiveSelectionBackground`, `list.focusBackground`, `list.dropBackground` | `accent` wash |  |
| `list.inactiveSelectionForeground`, `list.focusForeground`, `list.hoverForeground` | `text` |  |
| `list.hoverBackground` | `hover` |  |
| `list.errorForeground`, `list.invalidItemForeground` | `error` |  |
| `list.warningForeground` | `warning` |  |
| `list.deemphasizedForeground` | `faint` |  |
| `tree.indentGuidesStroke`, `tree.inactiveIndentGuidesStroke` | `line` |  |

**Inputs, buttons, menus, quick pick**

| App setting | Color | Why |
|---|---|---|
| `input.background`, `dropdown.background`, `dropdown.listBackground`, `checkbox.background`, `button.secondaryBackground`, `menu.background`, `quickInput.background`, `quickInputTitle.background`, `keybindingLabel.background` | `raised` |  |
| `input.foreground`, `dropdown.foreground`, `checkbox.foreground`, `inputOption.activeForeground`, `inputValidation.errorForeground`, `inputValidation.warningForeground`, `inputValidation.infoForeground`, `button.secondaryForeground`, `menu.foreground`, `quickInput.foreground`, `keybindingLabel.foreground` | `text` |  |
| `input.border`, `dropdown.border`, `checkbox.border`, `button.border`, `menu.separatorBackground`, `menu.border`, `pickerGroup.border`, `keybindingLabel.border`, `keybindingLabel.bottomBorder` | `line` |  |
| `input.placeholderForeground` | `faint` |  |
| `inputOption.activeBackground` | `accent` wash |  |
| `inputOption.activeBorder`, `button.background`, `button.hoverBackground`, `menu.selectionBackground`, `quickInputList.focusBackground` | `accent` |  |
| `inputValidation.errorBackground` | `error` wash |  |
| `inputValidation.errorBorder` | `error` |  |
| `inputValidation.warningBackground` | `warning` wash |  |
| `inputValidation.warningBorder` | `warning` |  |
| `inputValidation.infoBackground` | `info` wash |  |
| `inputValidation.infoBorder` | `info` |  |
| `button.foreground`, `button.separator`, `menu.selectionForeground`, `quickInputList.focusForeground`, `quickInputList.focusIconForeground` | `on_accent` |  |
| `button.secondaryHoverBackground` | `hover` |  |
| `pickerGroup.foreground` | `dim` |  |

**Notifications and widgets**

| App setting | Color | Why |
|---|---|---|
| `notifications.background`, `notificationCenterHeader.background`, `editorWidget.background`, `editorHoverWidget.background`, `editorSuggestWidget.background`, `debugExceptionWidget.background`, `debugToolBar.background` | `raised` |  |
| `notifications.foreground`, `notificationCenterHeader.foreground`, `editorWidget.foreground`, `editorHoverWidget.foreground`, `editorSuggestWidget.foreground`, `peekViewTitleLabel.foreground`, `peekViewResult.fileForeground` | `text` |  |
| `notifications.border`, `notificationCenter.border`, `notificationToast.border`, `editorWidget.border`, `editorHoverWidget.border`, `editorSuggestWidget.border`, `editorHoverWidget.statusBarBackground`, `debugToolBar.border` | `line` |  |
| `notificationLink.foreground`, `editorWidget.resizeBorder`, `editorSuggestWidget.selectedBackground`, `peekView.border`, `peekViewResult.selectionBackground` | `accent` |  |
| `notificationsErrorIcon.foreground`, `debugExceptionWidget.border` | `error` |  |
| `notificationsWarningIcon.foreground` | `warning` |  |
| `notificationsInfoIcon.foreground` | `info` |  |
| `editorSuggestWidget.selectedForeground`, `editorSuggestWidget.selectedIconForeground`, `editorSuggestWidget.focusHighlightForeground`, `peekViewResult.selectionForeground` | `on_accent` |  |
| `peekViewEditor.background`, `peekViewEditorGutter.background` | `base` |  |
| `peekViewResult.background`, `peekViewTitle.background` | `deep` |  |
| `peekViewTitleDescription.foreground`, `peekViewResult.lineForeground` | `dim` |  |
| `editorSuggestWidget.highlightForeground` | `steel` | Matched characters in the other suggestions; on the selected row they are `on_accent` |
| `peekViewEditor.matchHighlightBackground`, `peekViewResult.matchHighlightBackground` | `steel` wash | Matches, per Search and matches in PHILOSOPHY.md |

**Diff and merge**

| App setting | Color | Why |
|---|---|---|
| `diffEditor.insertedLineBackground`, `merge.currentHeaderBackground`, `merge.currentContentBackground` | `success` wash |  |
| `diffEditor.removedLineBackground` | `error` wash |  |
| `diffEditor.insertedTextBackground`, `diffEditor.removedTextBackground` | transparent |  |
| `diffEditor.insertedTextBorder`, `diffEditorGutter.insertedLineBackground`, `diffEditorOverview.insertedForeground`, `editorOverviewRuler.currentContentForeground` | `success` |  |
| `diffEditor.removedTextBorder`, `diffEditorGutter.removedLineBackground`, `diffEditorOverview.removedForeground` | `error` |  |
| `diffEditor.border`, `diffEditor.diagonalFill`, `merge.border` | `line` |  |
| `merge.incomingHeaderBackground`, `merge.incomingContentBackground` | `info` wash |  |
| `merge.commonHeaderBackground`, `merge.commonContentBackground` | `heather` wash | no meaning, only distinct from current and incoming |
| `editorOverviewRuler.incomingContentForeground` | `info` |  |
| `editorOverviewRuler.commonContentForeground` | `heather` |  |

**Editor**

| App setting | Color | Why |
|---|---|---|
| `editor.background`, `editorGutter.background`, `minimap.background`, `editorStickyScroll.background` | `base` |  |
| `editor.foreground`, `editorLineNumber.activeForeground` | `text` |  |
| `editorLineNumber.foreground`, `editorIndentGuide.activeBackground1`, `editorCodeLens.foreground`, `editorInlayHint.foreground`, `editorGhostText.foreground`, `editorHint.foreground`, `editorUnnecessaryCode.border` | `faint` |  |
| `editorCursor.foreground`, `editor.findMatchBorder`, `editorBracketMatch.border`, `editorLink.activeForeground`, `editorOverviewRuler.selectionHighlightForeground`, `minimap.selectionHighlight` | `accent` |  |
| `editorCursor.background` | `on_accent` |  |
| `editor.selectionBackground`, `editor.inactiveSelectionBackground`, `editorBracketMatch.background` | `accent` wash |  |
| `editor.findMatchBackground`, `editor.findMatchHighlightBackground` | `steel` wash | Every find match, per Search and matches in PHILOSOPHY.md. VS Code keeps syntax colors on a match, so the current one is told apart by the firelight `editor.findMatchBorder`, not a fill |
| `editorOverviewRuler.findMatchForeground`, `minimap.findMatchHighlight` | `steel` | Marks for the matches |
| `editor.selectionHighlightBackground`, `editor.wordHighlightBackground`, `editor.wordHighlightTextBackground` | `reference` wash | occurrences are references to the symbol |
| `editor.wordHighlightStrongBackground`, `editor.stackFrameHighlightBackground` | `warning` wash |  |
| `editor.findRangeHighlightBackground`, `editor.rangeHighlightBackground`, `editor.hoverHighlightBackground`, `editor.lineHighlightBackground`, `editor.lineHighlightBorder`, `editorInlayHint.background` | `raised` | lifted line; syntax colors keep their floor on `raised` |
| `editorWhitespace.foreground`, `editorIndentGuide.background1`, `editorRuler.foreground`, `editorOverviewRuler.border`, `editorStickyScroll.border` | `line` |  |
| `editorBracketHighlight.foreground1`, `editorBracketHighlight.foreground2`, `editorBracketHighlight.foreground3`, `editorBracketHighlight.foreground4`, `editorBracketHighlight.foreground5`, `editorBracketHighlight.foreground6`, `editorGutter.foldingControlForeground` | `dim` | brackets are punctuation |
| `editorBracketHighlight.unexpectedBracket.foreground`, `editorError.foreground`, `editorGutter.deletedBackground`, `editorOverviewRuler.errorForeground`, `editorOverviewRuler.deletedForeground`, `minimap.errorHighlight`, `minimapGutter.deletedBackground` | `error` |  |
| `editorWarning.foreground`, `editorGutter.modifiedBackground`, `editorOverviewRuler.warningForeground`, `editorOverviewRuler.modifiedForeground`, `editorOverviewRuler.wordHighlightStrongForeground`, `minimap.warningHighlight`, `minimapGutter.modifiedBackground` | `warning` |  |
| `editorInfo.foreground`, `editorOverviewRuler.infoForeground` | `info` |  |
| `editorGutter.addedBackground`, `editorOverviewRuler.addedForeground`, `minimapGutter.addedBackground` | `success` |  |
| `editorOverviewRuler.wordHighlightForeground` | `reference` |  |
| `editor.focusedStackFrameHighlightBackground` | `success` wash |  |
| `editorStickyScroll.shadow` | transparent |  |

**Git, problems, testing, debug, charts**

| App setting | Color | Why |
|---|---|---|
| `gitDecoration.addedResourceForeground`, `gitDecoration.untrackedResourceForeground`, `testing.iconPassed`, `testing.runAction`, `debugIcon.startForeground`, `debugIcon.continueForeground` | `success` |  |
| `gitDecoration.modifiedResourceForeground`, `gitDecoration.stageModifiedResourceForeground`, `gitDecoration.renamedResourceForeground`, `problemsWarningIcon.foreground`, `debugIcon.breakpointCurrentStackframeForeground`, `debugConsole.warningForeground`, `settings.modifiedItemIndicator` | `warning` |  |
| `gitDecoration.deletedResourceForeground`, `gitDecoration.stageDeletedResourceForeground`, `gitDecoration.conflictingResourceForeground`, `problemsErrorIcon.foreground`, `testing.iconFailed`, `testing.iconErrored`, `debugIcon.breakpointForeground`, `debugIcon.stopForeground`, `debugIcon.disconnectForeground`, `debugConsole.errorForeground` | `error` |  |
| `gitDecoration.ignoredResourceForeground`, `testing.iconSkipped`, `testing.iconUnset`, `debugIcon.breakpointDisabledForeground`, `debugIcon.breakpointUnverifiedForeground` | `faint` |  |
| `gitDecoration.submoduleResourceForeground` | `reference` |  |
| `problemsInfoIcon.foreground`, `testing.iconQueued`, `debugIcon.pauseForeground`, `debugIcon.restartForeground`, `debugIcon.stepOverForeground`, `debugIcon.stepIntoForeground`, `debugIcon.stepOutForeground`, `debugIcon.stepBackForeground`, `debugConsole.infoForeground` | `info` | queued is in progress |
| `debugConsole.sourceForeground` | `dim` |  |
| `debugConsoleInputIcon.foreground` | `accent` |  |
| `settings.headerForeground`, `charts.foreground` | `text` |  |
| `charts.lines` | `line` |  |
| `charts.red` | `ember` |  |
| `charts.green` | `moss` |  |
| `charts.yellow` | `brass` |  |
| `charts.blue` | `steel` |  |
| `charts.purple` | `heather` | chart colors are about the color itself |
| `charts.orange` | `clay` |  |

**Symbol icons**

| App setting | Color | Why |
|---|---|---|
| `symbolIcon.functionForeground`, `symbolIcon.methodForeground`, `symbolIcon.constructorForeground`, `symbolIcon.propertyForeground`, `symbolIcon.fieldForeground`, `symbolIcon.keyForeground`, `symbolIcon.eventForeground` | `steel` | an event is a member, like a property |
| `symbolIcon.stringForeground` | `moss` |  |
| `symbolIcon.numberForeground`, `symbolIcon.unitForeground` | `literal` |  |
| `symbolIcon.keywordForeground`, `symbolIcon.constantForeground`, `symbolIcon.booleanForeground`, `symbolIcon.nullForeground`, `symbolIcon.enumeratorMemberForeground` | `keyword` |  |
| `symbolIcon.classForeground`, `symbolIcon.interfaceForeground`, `symbolIcon.structForeground`, `symbolIcon.enumeratorForeground`, `symbolIcon.typeParameterForeground`, `symbolIcon.moduleForeground`, `symbolIcon.namespaceForeground`, `symbolIcon.packageForeground` | `type` |  |
| `symbolIcon.referenceForeground` | `reference` |  |
| `symbolIcon.variableForeground` | `text` |  |
| `symbolIcon.fileForeground`, `symbolIcon.folderForeground`, `symbolIcon.operatorForeground`, `symbolIcon.snippetForeground`, `symbolIcon.textForeground`, `symbolIcon.arrayForeground`, `symbolIcon.objectForeground`, `symbolIcon.colorForeground` | `dim` |  |

**Terminal**

| App setting | Color | Why |
|---|---|---|
| `terminal.inactiveSelectionBackground` | `accent` wash |  |
| `terminal.findMatchBackground`, `terminal.findMatchHighlightBackground` | `steel` wash | As in the editor: the current match has the firelight `terminal.findMatchBorder` |
| `terminal.findMatchBorder`, `terminalCursor.foreground`, `terminal.selectionBackground` | `accent` |  |
| `terminal.background` | `deep` | sits in the panel |
| `terminal.foreground` | `text` |  |
| `terminal.border` | `line` |  |
| `terminalCursor.background`, `terminal.selectionForeground` | `on_accent` |  |
| `terminalCommandDecoration.successBackground` | `success` |  |
| `terminalCommandDecoration.errorBackground` | `error` |  |
| `terminalCommandDecoration.defaultBackground` | `faint` |  |
| `terminal.ansiBlack` | ANSI `black` |  |
| `terminal.ansiRed` | ANSI `red` |  |
| `terminal.ansiGreen` | ANSI `green` |  |
| `terminal.ansiYellow` | ANSI `yellow` |  |
| `terminal.ansiBlue` | ANSI `blue` |  |
| `terminal.ansiMagenta` | ANSI `magenta` |  |
| `terminal.ansiCyan` | ANSI `cyan` |  |
| `terminal.ansiWhite` | ANSI `white` |  |
| `terminal.ansiBrightBlack` | ANSI `bright_black` |  |
| `terminal.ansiBrightRed` | ANSI `bright_red` |  |
| `terminal.ansiBrightGreen` | ANSI `bright_green` |  |
| `terminal.ansiBrightYellow` | ANSI `bright_yellow` |  |
| `terminal.ansiBrightBlue` | ANSI `bright_blue` |  |
| `terminal.ansiBrightMagenta` | ANSI `bright_magenta` |  |
| `terminal.ansiBrightCyan` | ANSI `bright_cyan` |  |
| `terminal.ansiBrightWhite` | ANSI `bright_white` |  |

**Syntax (TextMate scopes)**

| Token | Color |
|---|---|
| Variables and plain text | `text` |
| Punctuation and operators | `dim` |
| Keywords, booleans, constants | `keyword` |
| Keys, properties, functions | `steel` |
| Types | `type` |
| Paths, references, anchors | `reference` |
| Tags, annotations, decorators | `tag` |
| Numbers and literals | `literal` |
| Strings | `moss` |
| Comments | `faint` |
| Errors and invalid | `error` |
| Diff: ranges | `info` |
| Diff: added | `success` |
| Diff: removed | `error` |
| Diff: changed | `warning` |

Bold, italic, headings and strikethrough set a font style only.

**Semantic tokens**

| Token | Color |
|---|---|
| `namespace`, `type`, `class`, `enum`, `interface`, `struct`, `typeParameter` | `type` |
| `label` | `reference` |
| `parameter`, `variable` | `text` |
| `property`, `function`, `method`, `event` | `steel` |
| `enumMember`, `keyword`, `macro` | `keyword` |
| `decorator` | `tag` |
| `comment` | `faint` |
| `string`, `regexp` | `moss` |
| `number` | `literal` |
| `operator` | `dim` |

## Ornaments

This port uses ornaments (ADR 0010): it is installed as a packaged extension.

- **Markdown preview divider.** Each extension contributes `markdown.previewStyles` ([Markdown extension guide](https://code.visualstudio.com/api/extension-guides/markdown-extension#changing-the-look-of-the-markdown-preview-with-css)): `media/markdown.css` draws `hr` as `divider.svg` from `assets/ornaments/`, masked in `oxblood`, the same as `.guide hr` on the preview site. Every rule is scoped to `body[data-vscode-theme-id="<variant name>"]` ([webview theming](https://code.visualstudio.com/api/extension-guides/webview#theming-webview-content)), so the divider shows only while that variant is the active theme; with any other theme the preview keeps its plain rule.
- `template/media/divider.svg.ornament` names the ornament, and the build copies it into `dist/<variant>/media/divider.svg`, so the extension carries its own copy and `vsce` packages it.

## Gaps and trade-offs

- **Solid highlights.** The reference asks for the inactive selection, selection and word highlights, find match highlights, the find range, range and hover highlights, diff and merge line backgrounds, and the overview ruler marks not to be opaque, so decorations under them show through. Inglenook is solid (washes are solid by design), so where two of them overlap, the upper one hides the lower. The current line and range highlights are solid `raised`, where every syntax color still passes the floor for running text.
- **Selected text keeps its syntax colors.** VS Code only allows a selected text color in high contrast themes, so the selection is an `accent` wash.
- **Changed characters inside a diff line** get a thin `success` or `error` border instead of a second wash on top of the line wash.
- **Rainbow brackets are off.** All bracket pair colors are `dim`, since brackets are punctuation.
- **Button hover** does not change color. The palette has one accent, with no hover shade.
- **Shadows** under widgets and menus use VS Code's default shadow. The palette has no shadow color.
- **Syntax colors without a role.** Functions, properties and events are `steel`, and strings `moss`, by name: their roles (`info`, `success`) mean state, not syntax.
- **Detail colors.** `oxblood` and `ivy` are not used: VS Code has no badge or decoration slot that is about a color and not a state.
- **Settings not listed above** keep VS Code's default for the base theme (Light Modern or Dark Modern). That covers newer or rarely seen parts, such as the notebook editor, chat, and the welcome page.
- **Publisher.** `template/package.json` uses the theme's name as the publisher ID. Replace it with the real Marketplace publisher ID once one exists, then rebuild.
- **Colors the screenshots cannot show.** The editor scene has no tags, decorators or links, so `tag` and `reference` are themed but not shown, and no terminal, so the ANSI slots are not shown either. `warning` shows as the gutter's changed mark and the Explorer's modified files, `error` as the removed mark, the error underline and the file with a problem; `info` is not shown. Washes other than the selection (find matches, word highlights, diff lines) are not staged.

## Research

- Started from the Hyaline port of VS Code in this owner's previous theme (`../Hyaline/Ports/vscode`): the same workbench keys, packaging and recipe, with every glass and alpha value replaced by a solid neutral or a wash, and each Hyaline role mapped to Inglenook's (its single cyan split into `type` and `reference`, its yellow into `warning` and `tag`).
- Ports studied: [Catppuccin for VS Code](https://github.com/catppuccin/vscode) and [Nord for VS Code](https://github.com/nordtheme/visual-studio-code), both MIT. Method only: which workbench keys to cover, `semanticHighlighting`, and the recommended `terminal.integrated.minimumContrastRatio` and `window.titleBarStyle` settings. No files or colors reused.
- [Diff editor color defaults](https://github.com/microsoft/vscode/blob/main/src/vs/platform/theme/common/colors/editorColors.ts): diff line and text colors default to VS Code tints, so both are set.

## Screenshot recipe

- VS Code needs no login or license to open a folder and edit: its [license](https://code.visualstudio.com/license) allows use without an account, and [Settings Sync](https://code.visualstudio.com/docs/configure/settings-sync) and Copilot sign-in are optional. A normal recipe.
- `screenshot.json` shoots the editor scene (`build/photograph/scenes/editor/`) in VS Code `1.148.0-1795526052` from Microsoft's apt repository, with Node.js 26.13.1 and `@vscode/vsce` 4.1.1 installed for the packaging steps, and `fonts-ibm-plex` for the editor font. `vsce` is installed globally, so the README's `npx @vscode/vsce` uses it and downloads nothing.
- **apply** runs Install steps 3 to 5 (`npx @vscode/vsce package` in each `dist/` folder) with `--out "$HOME"`, since the repo is read-only in the container. Steps 6 to 8 are the README's terminal form, `code --install-extension`, for both VSIX files.
- **Scripted stand-ins, not tested by hand:** Install step 9 (pick the theme with **Ctrl+K** **Ctrl+T**) and **Set the font** (two lines in the settings editor) are one line that writes `settings.json` with the font lines and `workbench.colorTheme` set to the variant's theme label, read from its `package.json`.
- **Not tested:** **Install without Node.js**, and **Switch between Day and Night** (`window.autoDetectColorScheme` needs a desktop that reports its mode).
- **stage** runs the scene's `prepare.sh`, then this port's own `vscode/stage.sh`, which copies a short note with a horizontal rule to `~/Notes/Hearth.md` (outside the workspace, so the Explorer is unchanged) and installs `preview-scene`, a tiny extension that opens the note in the Markdown preview beside `Contrast.psm1` without taking the focus. Then it adds settings that change no color: self-update, extension updates, recommendations, telemetry, experiments, the welcome page, tips, workspace trust, AI features, the secondary side bar and git autofetch off, a solid cursor, and `editor.fontSize` 16.
- **launch** opens `~/Inglenook` with `--no-sandbox` (Chromium's sandbox cannot start in the container), `--password-store=basic` (no keyring prompt), `--disable-gpu`, and `--disable-partial-raster` with `--ui-disable-partial-swap` (whole-frame redraws, so takes match pixel for pixel).
- **window** is matched by title, which names `Contrast.psm1` only once the scene extension has opened it.
- **Frame.** VS Code on Linux draws its own title bar by default, so the shots show the port's `titleBar` colors and no Adwaita frame.
