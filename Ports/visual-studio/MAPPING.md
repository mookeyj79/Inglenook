# Visual Studio: color mapping

For maintainers. The install guide is [README.md](README.md).

The template, `template/{{variant.slug}}.vstheme`, lists about 1,580 colors in 61 categories. The table covers the ones a reader sees; the rest follow the same rules (below the table). Each color in a `.vstheme` is a `Background` or `Foreground` with `Type="CT_RAW"` and `Source="AARRGGBB"`, written with the `{{color|argb}}` filter, always opaque.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| **Visual Studio 2026 Shell tokens** (`Shell`, `ShellInternal`) | | Read first by Visual Studio 2026 |
| `SolidBackgroundFillBase`, `SolidBackgroundFillQuaternary`, `LayerFillDefault` | `base` | |
| `SolidBackgroundFillSecondary`, `SolidBackgroundFillTertiary`, `SurfaceBackgroundFillDefault`, `CardBackgroundFillDefault` | `deep` | |
| `SolidBackgroundFillBaseAlt`, `EnvironmentBackground`, `EnvironmentHeader`, `EnvironmentTabInactive`, `StatusBarBackgroundFillRest` | `deeper` | Title bar, tab well and status bar, as in VS Code |
| `SolidBackgroundFillQuinary`, `ControlFillDefault`, `ControlSolidFillDefault`, `ControlFillActiveInput` | `raised` | Controls and inputs |
| `SolidBackgroundFillSenary`, `ControlFillSecondary`, `ControlFillTertiary` | `hover` | |
| `SurfaceStrokeDefault`, `SurfaceStrokeFlyout`, `DividerStrokeDefault`, `ControlStrokeDefault`, `CardStroke*`, `EnvironmentBorderInactive` | `line` | |
| `TextFillPrimary`, `EnvironmentBodyText`, `StatusBarTextFillRest`, `TextOnAccentFillSelectedText` | `text` | |
| `TextFillSecondary`, `TextFillTertiary`, `EnvironmentLogo` | `dim` | The logo is not "you are here" |
| `TextFillDisabled`, `SystemFillSolidNeutral`, `EnvironmentIndicator` | `faint` | |
| `AccentFill*`, `AccentTextFill*`, `FocusStrokeOuter`, `HyperlinkFill*`, `EnvironmentBorder` | `accent` | Fluent's tiers are alpha steps of one accent; here they are one solid accent |
| `AccentFillSenary`, `AccentFillSelectedTextBackground`, `AccentFillSelectedTextBackgroundSubtle` | `{{accent\|wash}}` | Selection |
| `TextOnAccentFillPrimary`, `TextOnAccentFillSecondary` | `on_accent` | |
| `StatusBarBackgroundFillBuilding`, `...Debugging`, `...SolutionLoading` with their `StatusBarTextFill*` | `accent`, `on_accent` | As VS Code's debugging status bar |
| `SystemFillCritical`, `SystemFillCaution`, `SystemFillSuccess`, `SystemFillAttention` | `error`, `warning`, `success`, `info` | |
| `SystemFillCriticalBackground`, `...CautionBackground`, `...SuccessBackground`, `SystemFillSolidAttentionBackground` | washes of the same | |
| `CaptionControlCloseFill*`, `CaptionControlCloseTextFill*` | `error`, `on_accent` | Close is removal; `on_accent` on an `error` fill as in VS Code's status bar items |
| `ShadowFlyout`, `PopupShadow` | not set | The palette has no shadow color |
| **Visual Studio 2022 tokens** (`Environment`, `CommonControls`, `TreeView`, `ThemedDialog`, and others) | | |
| Title bar, menu bar, tool bars, tab well | `deeper` | |
| Tool windows, panels, combo boxes | `deep` | |
| Selected document tab | `base`, `text`, `accent` border | VS Code's active tab |
| Inactive document tabs | `deeper`, `dim` | |
| Hovered buttons, menu items, tab buttons | `hover`, `text` | |
| Menus and popups (`CommandBarMenu*`, `EditorOverride`) | `raised`, `text`, `line` border | |
| Selected menu item, popup item | `accent`, `on_accent` | VS Code's `menu.selectionBackground` |
| Tree and list selection with focus (`TreeView`, `ThemedDialog` `SelectedItemActive`) | `accent`, `on_accent` | VS Code's `list.activeSelection*` |
| Tree and list selection without focus | `{{accent\|wash}}`, `text` | VS Code's `list.inactiveSelectionBackground` |
| Buttons | `raised`, `text`, `line` border | |
| Default button (`ButtonDefault`) | `accent`, `on_accent` | Primary button |
| Focus borders and focus visuals | `accent` | |
| Text boxes | `raised`, `text`, `line` border | |
| Links (`*Link*`, `*Hyperlink*`) | `accent` | |
| Scroll bar thumb | `line`, `faint` on hover | VS Code's scrollbar slider |
| Info bars | `raised`, `text`, `line` border | |
| Validation errors | `error` | |
| **Code editor** (`Text Editor Text Manager Items`, `Text Editor Text Marker Items`, `Text Editor Language Service Items`, and the editor's MEF category) | | |
| Plain Text | `base`, `text` | |
| Indicator margin, line numbers | `base`, `faint` | |
| Selected Line Number | `text` | |
| Current line (`CurrentLineActiveFormat`) | `raised` | VS Code's `editor.lineHighlightBackground` |
| Caret (Primary), Caret (Secondary) | `accent` | |
| Selected Text, Inactive Selected Text | `{{accent\|wash}}` | Syntax colors stay |
| Find highlight (`MarkerFormatDefinition/FindHighlight`), Matched Selected Text, Peek Highlighted Text, Definition Window Current Match | `{{steel\|wash}}` | Every match, per ADR 0009 |
| Highlighted references and definitions | `{{reference\|wash}}` | VS Code's `editor.wordHighlightBackground` |
| Highlighted written reference | `{{warning\|wash}}` | VS Code's `editor.wordHighlightStrongBackground` |
| Brace Matching (Rectangle), Brace Matching (Highlight) | `{{accent\|wash}}` | VS Code's `editorBracketMatch.background` |
| Visible Whitespace, outlining lines, Block Structure Adornments | `line` | |
| Outlining chevrons | `dim` | |
| syntax error, compiler error, other error, Error Message | `error` | Squiggles |
| compiler warning | `warning` | |
| information | `info` | |
| hinted suggestion, inline hints, Excluded Code, unnecessary code | `faint` | |
| deltadiff add, remove (line and word) | `{{success\|wash}}`, `{{error\|wash}}` | |
| Track Changes before save, after save | `warning`, `success` | VS Code's gutter marks |
| Track additions, modifications, deletions under source control | `success`, `warning`, `error` | |
| Breakpoint (Enabled) | `{{error\|wash}}` | Syntax colors stay |
| Current Statement | `{{warning\|wash}}` | |
| Rename field | `{{accent\|wash}}`, `accent` border | |
| Peek window | `base`, `deep` unfocused, `accent` border | |
| Sticky scroll | `base`, `raised` current line | |
| Editor tooltip | `raised`, `text` | |
| **Syntax** | | Per PHILOSOPHY.md and VS Code's semantic tokens |
| Keyword, keyword - control, constant name, enum member name, C++ macros and enums, XML and XAML keywords | `keyword` | |
| String, string - verbatim, regex text, XML and HTML attribute values | `moss` | |
| Number, Literal, string - escape character, CSS property values, HTML entities | `literal` | |
| class, record, struct, interface, enum, delegate, namespace, module and type parameter names, C++ types and namespaces, XAML markup extension class | `type` | |
| method, extension method, property, field and event names, Function, C++ functions and members, XML, XAML, HTML attribute names, JSON property names, CSS property names | `steel` | |
| label name, C++ labels | `reference` | |
| Preprocessor Keyword, HTML element names, XML and XAML element names, CSS selectors, Razor elements | `tag` | |
| local name, parameter name, Identifier, preprocessor text | `text` | VS Code's `parameter` and `variable` |
| punctuation, Operator, brace matching, delimiters, rainbow brace levels | `dim` | |
| Comment, XML Comment, xml doc comment parts | `faint` | |
| mismatched brace, Error | `error` | |
| urlformat, NavigableSymbolFormat | `accent` | Links |

The other colors in the template keep the surface or text role Catppuccin gave them, mapped by meaning: Catppuccin's base, mantle and crust are `base`, `deep` and `deeper`; surface0 to 2 are `raised`, `hover` and `line`; overlays are `faint` and `dim`; subtexts are `dim`; text is `text`. Outside the editor, its accent hues are `accent` only where the color name says the item is focused, selected, active, current or a link: Catppuccin's accent on borders, separators, disabled states and check box labels is `line`, `faint`, `raised` or `text` here. Its status hues are `error`, `warning`, `success` and `info`. Inside the editor categories its hues are syntax roles (its keyword hue is `keyword`, its function hue `steel`, its type hue `type`), then the table above replaces the rest.

## Gaps and trade-offs

- **Colors left to the base theme.** A color is in the template only where Catppuccin set it to one of its palette colors, or where the table names it. Catppuccin leaves about 1,860 colors at Visual Studio's own values, uses transparency for about 290, and sets about 950 to "not set" (`CT_INVALID`, `CT_AUTOMATIC`). Those are left out here, so they come from the theme's `FallbackId`: Visual Studio's Light theme for Day and Dark theme for Night. That is most of the tier 2 gap: profilers, graphics and XAML designers, the diagnostics hub, Azure and database tool windows, ReSharper and other extension categories show Visual Studio's grays and blues.
- **Solid colors only.** Fluent's tiers in the Visual Studio 2026 `Shell` category (`AccentFillSecondary` at 90%, `TextFillSecondary` at about 60%, `ControlFillActiveInput` at 70%, layered backgrounds) are alpha steps. They are solid here, so the secondary and tertiary steps of a ramp often match the primary one.
- **Breakpoints and the current statement are washes.** Visual Studio draws the breakpoint glyph and the margin mark in the line's background color, so a wash makes them paler than Visual Studio's red and yellow. A full `error` fill would need text on it across the whole line, which has no measured pair in the palette. The other breakpoint, tracepoint and snappoint states are not set and keep Visual Studio's colors.
- **The match at the cursor.** Visual Studio has no separate color for the current find match: Find selects it, so it shows as the selection, a firelight wash, with every other match a steel wash.
- **Rainbow braces are off.** All levels are `dim`, as in VS Code.
- **Shadows** keep Visual Studio's default. The palette has no shadow color.
- **Detail colors.** `oxblood` and `ivy` are not used.
- **Close button.** `on_accent` on the `error` fill is not a measured pair; VS Code's status bar does the same.
- **Not built here.** The VSIX project needs Windows and the Visual Studio SDK, so neither `.csproj` has been built in this repo. `check.ps1` only parses `.xml` files, so the `.vstheme`, `.csproj` and `.vsixmanifest` in `dist/` were parsed by hand with an XML parser, and every `Source` checked to be `FF` plus six upper-case hex digits.
- **`.vssettings`.** A `.vssettings` file (Tools > Import and Export Settings) can carry the editor's Fonts and Colors without building anything, but Microsoft does not document its color format, so the port does not ship one. The `.vstheme` covers the editor already.
- **Colors the screenshots cannot show.** The editor scene has no debugging session, so breakpoints, the current statement and the debugging status bar are not shown; no diff, so the deltadiff washes are not shown.

## Research

- Started from [Catppuccin for Visual Studio](https://github.com/catppuccin/visual-studio) (MIT, Copyright (c) 2021 Catppuccin), version 1.7.3: its token list (categories, GUIDs and color names from the Mocha `.vstheme`), which of each color's `Background` and `Foreground` it sets, and its VSIX project (the `.csproj` with `Microsoft.VisualStudio.VsixColorCompiler` pinned to 17.0.31709.430, which its notes say is the only version that builds, and the `.vsixmanifest` targeting Visual Studio 17.0 to 19.0 with `PkgdefProjectOutputGroup`). Its colors and names are not used: every color was mapped by role, as described under the table. The mapping was generated once from Catppuccin's file with a script that is not kept; the template is now edited by hand.
- [VSIX Color Compiler](https://learn.microsoft.com/visualstudio/extensibility/internals/vsix-color-compiler): the theme XML schema (`Themes`, `Theme`, `Category`, `Color`, `Background`, `Foreground`), `CT_RAW` as a raw ARGB value, and the built-in Light and Dark theme GUIDs used as `BaseGUID` and `FallbackId`.
- [Modernize Visual Studio theme colors](https://learn.microsoft.com/visualstudio/extensibility/migration/modernize-theme-colors): Visual Studio 2026 reads the `Shell` and `ShellInternal` tokens first and falls back to the 2022 tokens, so one file serves both versions. It also describes an in-IDE **Theme colors** page and a theme-named JSON override file in `%LOCALAPPDATA%\Microsoft\VisualStudio\18.0_xxxxxxxx\ColorThemes`; its format is not documented, so the port does not use it.
- [microsoft/VS-ColorThemes](https://github.com/microsoft/VS-ColorThemes) and its `ShellColorTokens.md`: the same `.vstheme` format packaged as a VSIX; every token name the template adds beyond Catppuccin's is in that list or in Catppuccin's file.
- [Theme Converter for VS](https://github.com/microsoft/theme-converter-for-vs) converts a VS Code theme into a `.pkgdef`, which also needs a VSIX project to install; it gives less control over the editor's classifications, so the port writes the `.vstheme` directly.

## Screenshot recipe

- Manual. [Sign in to Visual Studio](https://learn.microsoft.com/visualstudio/ide/signing-in-to-visual-studio): Community "might periodically" prompt to sign in "to continue using Visual Studio Community without interruptions", and Professional and Enterprise are "limited to the trial period of 30 days" without a Microsoft account.
- The shots need the VSIX built and installed by hand, which is Install steps 1 to 10 of the README. Nothing is scripted, so nothing stands in for a step.
