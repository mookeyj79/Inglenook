# Typora: color mapping

For maintainers. The install guide is [README.md](README.md).

Each variant is its own theme file, `template/{{variant.slug}}.css`, built to `inglenook-day.css` and `inglenook-night.css`. Typora turns the lowercase, hyphenated file name into the menu label, so the files show as Inglenook Day and Inglenook Night. No asset folder: the font is the user's installed IBM Plex Mono.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `color-scheme` | the variant's mode | Native scrollbars and form controls follow light or dark |
| `--bg-color`, `html`, `body` | base | |
| `--text-color`, `#write`, headings | text | |
| h1 and h2 underline, `hr`, table borders, `--window-border` | line | |
| h6 | dim | Typora's own themes dim the smallest heading |
| `--md-char-color`, `.md-meta` (the `**`, `#` shown at the cursor) | faint | Markdown syntax is metadata |
| `--meta-content-color`, `.md-content`, link and image addresses | reference | Paths and URLs |
| Links, footnote marks | accent | |
| Blockquote text, border | dim, line | |
| `mark` (`==highlight==`) | brass wash, text on it | A highlighter, chosen for the color itself; not a warning. See Gaps |
| `del` | dim | |
| `kbd` | raised, line, text | |
| List markers | dim | Punctuation |
| Task checkbox (`accent-color`) | accent | The control's own accent |
| Table header | deep | |
| Table rows | base | No zebra stripes: calm surface |
| Table edit toolbar | raised, line | |
| Inline `code` | literal on deep, line border | Matches VS Code's `markup.inline.raw`; a short label on deep |
| Code fence surface, gutter | deep, line border | Every syntax color clears 4.5 on deep in both variants (`contrast.ps1 -Surface deep`), so running code is fine there |
| Fence language box (`.code-tooltip`) | raised, dim | |
| Line numbers | faint | |
| Cursor | accent | |
| Selection, `--select-text-bg-color`, CodeMirror selection | accent wash, text | |
| Active line in fences | deep (no change) | Typora only shows it while editing; kept quiet |
| `.cm-property`, `.cm-attribute`, `.cm-def`, `.cm-builtin`, `.cm-qualifier`, `.cm-variable-2` | info | Keys, properties, functions |
| `.cm-string`, `.cm-string-2` | moss | Strings |
| `.cm-number` | literal | |
| `.cm-keyword`, `.cm-atom` | keyword | Keywords, booleans, constants |
| `.cm-type`, `.cm-variable-3` | type | |
| `.cm-link`, `.cm-url` | reference | |
| `.cm-tag`, `.cm-meta` | tag | Tags, annotations, decorators |
| `.cm-error`, `.cm-invalidchar`, non-matching bracket | error | |
| `.cm-operator`, `.cm-punctuation`, `.cm-bracket`, `.cm-quote`, `.cm-hr` | dim | Punctuation |
| `.cm-comment` | faint | |
| `.cm-variable`, `.cm-header`, `.cm-strong`, `.cm-em` | text | |
| `.cm-positive`, `.cm-negative` | success, error | Diff lines |
| Matching bracket | accent, underlined | The bracket at the cursor |
| Source mode surface | base | |
| Source mode headings | info, bold | Same as VS Code's `markup.heading` |
| Source mode `#`, `*`, `>`, list markers | dim | Punctuation |
| Source mode links and URLs | reference | |
| Source mode inline code | literal | Same as VS Code's `markup.inline.raw` |
| Every search match (`.md-search-hit`, `.cm-search-hit`, `.cm-searching`) | steel wash, text | ADR 0009 |
| Current match (`.md-search-select`, `--search-select-bg-color`) | accent, on_accent | ADR 0009 |
| Find panel | raised, line | |
| Focus mode, blurred blocks (`--blur-text-color`) | faint | |
| Sidebar, file list, `--side-bar-bg-color` | deep | |
| File list summaries, dates | faint | Metadata |
| Hovered rows, `--item-hover-bg-color` | hover | |
| Active file, `--active-file-bg-color` | accent wash, accent border | "You are here" in the file tree |
| Outline labels, sidebar tabs | dim | |
| Current outline item, current sidebar tab | accent | |
| TOC links | dim, accent on hover | |
| Footer (word count bar) | deep, line, dim | |
| Windows and Linux title bar (`#top-titlebar`) | deeper | |
| Menus, context menus, popovers, tooltips, quick open, dialogs | raised, line, text | |
| Menu dividers | line | |
| Quick open active item, autocomplete active item | accent wash | A selection |
| File menu (megamenu) sidebar | deep | |
| File menu (megamenu) panel | base | |
| Buttons | raised, line; hover on hover | |
| Primary buttons, `--primary-color` | accent, on_accent | |
| Inputs | raised, line; accent border on focus | |
| Placeholders | faint | |
| Notifications | raised, line | |
| Diagram and math errors | error | |
| Scrollbar thumb, track | line (faint on hover), base | |

## Gaps and trade-offs

- **Highlights** use a brass wash. Typora has no role for a highlighter; brass is the color of a highlighter pen, and the wash keeps text readable. The owner may prefer another wash (a detail color such as ivy or oxblood).
- **Mermaid, flowchart, and sequence diagrams** keep Typora's colors. They are SVG with many theme-specific classes; Rosé Pine and Dracula restyle them with their own fills. Left for a later pass.
- **Math** (MathJax) is drawn in `currentColor`, so it follows the text color and has nothing else to theme.
- **Source mode search classes** (`.cm-search-hit`, `.cm-searching`, `.cm-search-hit-selected`) are CodeMirror's standard names. Not confirmed in Typora's DevTools yet.
- **Unibody title bar and megamenu selectors** come from studying other themes, not from Typora's docs, which say only that these parts are HTML. Confirm them in DevTools when the shots are taken.
- **macOS title bar** follows `html`'s background in the seamless window style (per the docs); native menus stay the system's.
- The screenshots have not been taken yet, so no row has been checked in a shot.

## Research

- **Catppuccin** has no official Typora port (no `catppuccin/typora` repo, none in Catppuccin's port list). Unofficial ones exist, not studied.
- **[Rosé Pine for Typora](https://github.com/rose-pine/typora)** (MIT, Copyright (c) Rosé Pine): the starting point. One CSS file in the theme folder, Typora's `:root` variables overridden first, then `#write` typography, tables, inline code, `.md-fences` with `.cm-s-inner` for fences and `.cm-s-typora-default` for source mode, `.md-search-hit` and `.md-search-select` for find, focus mode, sidebar file tree and outline, megamenu, dialogs, footer. Method only: none of its colors or names, and none of its transparency or shadows.
- **[Dracula for Typora](https://github.com/dracula/typora)** (MIT): splits the theme into a main file plus `codeblock`, `sourcemode`, and `mermaid` files in an asset folder. Not needed here: one file per variant keeps install to two copies.
- **Typora's docs**: [Write Custom Theme](https://theme.typora.io/doc/Write-Custom-Theme/) lists the CSS variables, the selectors for block and inline elements, `.cm-s-inner` for fences and `.cm-s-typora-default` for source mode, the file name rule (lowercase, hyphens), and `@media print`. [Code Block Styles](https://support.typora.io/Code-Block-Styles/) confirms `.cm-s-inner` and says to style `.md-fences` too, for fences before CodeMirror loads. [Install Theme](https://theme.typora.io/doc/Install-Theme/) gives the theme folder, the restart, and `<theme>.user.css`. [Dark Mode](https://support.typora.io/Dark-Mode/) says macOS and Windows can pick separate light and dark themes.
- Typora has no font preference (only a size), so the theme sets `--monospace` to IBM Plex Mono and leaves the body font as Typora's default. The README shows a `.user.css` override.
- `--select-text-font-color`, `--search-select-text-color`, `--blur-text-color`, `--focus-ring-color`, `--control-text-color` are not in the docs' short list; they come from Typora's built-in themes as used by Rosé Pine and Dracula. Harmless if Typora ignores one.

## Screenshot recipe

- Manual recipe. Typora is paid. Its [License Agreement](https://support.typora.io/License-Agreement/) grants the trial "for the sole purpose of testing and evaluating the Software" and bars commercial use without a license, so the owner treats the themed screen as license-required. The shots are taken by hand in a licensed copy; the Photographer never runs the trial.
- Scene kind `document`. Its staged content is not written yet; the shots match the other ports' framing until it is.
