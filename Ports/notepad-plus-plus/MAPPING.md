# Notepad++: color mapping

For maintainers. The install guide is [README.md](README.md).

One template, `template/{{variant.name}}.xml`, builds both themes. Notepad++ shows a theme by its file name, so the files are `Inglenook Day.xml` and `Inglenook Night.xml`. Colors are `RRGGBB` with no `#` (`|nohash`). Every style has `bgColor` `base` unless the table says otherwise, and every `fontStyle` is `0` (no bold or italic) except where noted.

## Color mapping

**Global Styles**

| App setting | Color | Why |
|---|---|---|
| Default Style, Global override | `text` on `base` | Default Style also sets the font: IBM Plex Mono, size 10 (Notepad++'s own default size). Global override only applies where the user ticks its **Enable global** boxes |
| Current line background colour, search results current line | `raised` | as VS Code's current line |
| Selected text colour, Multi-selected text color | `accent` wash | the fgColor (`text`) is ignored unless the user adds `enableSelectFgColor.xml` |
| Caret colour, Multi-edit carets color, Fold active, URL hovered, Active tab focused indicator | `accent` | |
| Document map | `accent` on `base` | fgColor is the view zone (where you are), bgColor the frost over the rest |
| Brace highlight style, Tags match highlighting | `text` on `accent` wash, bold | the match of the brace or tag at the cursor |
| Bad brace colour | `error`, bold | |
| Smart Highlighting, Find matches highlight all, Find Mark Style | `steel` wash | every match, per Search and matches in PHILOSOPHY.md |
| Tags attribute | `hover` | a quiet mark with no meaning |
| Mark Style 1 to 5, Tab color 1 to 5, Tab color dark mode 1 to 5 | `ivy`, `pine`, `dusk`, `heather`, `oxblood` washes, in that order | the user's own marks and tab colors: distinct, with no meaning. Not `steel` (matches), `firelight` (selection), or a status color |
| Line number margin | `faint` on `base` | |
| Bookmark margin, Change History margin, Fold margin (both colors) | `base` | the gutter is part of the page |
| Fold | `faint` on `base` | the fold box outline and fill |
| Indent guideline style, Edge colour, White space symbol, EOL custom color, Non-printing characters custom color | `line` | |
| Change History modified | `warning` | changed, not saved |
| Change History saved | `success` | |
| Change History revert modified, Change History revert origin | `info` | |
| Find status: Not found | `error` | |
| Find status: Message | `info` | |
| Find status: Search end reached | `warning` | the search wrapped |
| Active tab text | `text` | |
| Active tab unfocused indicator | `faint` | |
| Inactive tabs | `dim` on `deeper` | inactive tabs sit back in the tab strip |

**Languages**

The template themes 27 languages plus the search results panel: bash, batch, C, C++, C#, CSS, diff, Go, HTML, ini, Java, JavaScript (embedded and `.js`), JSON, Lua, Makefile, PHP, PowerShell, properties, Python, Ruby, Rust, SQL, TOML, TypeScript, XML, YAML. Each one lists the same styles, `styleID`s, and `keywordClass`es as `DarkModeDefault.xml` in Notepad++ 8.9.9.1.

| Style names | Color |
|---|---|
| DEFAULT, IDENTIFIER, VARIABLE, WORD (embedded JavaScript), SCALAR, PARAM, WHITESPACE, CDATA, Ruby GLOBAL, INSTANCE VAR, CLASS VAR | `text` |
| INSTRUCTION WORD, KEYWORD(S), USER KEYWORDS, SQL USER1 and KEYWORD2, PHP WORD and PREDEFINED, CSS IMPORTANT, DIRECTIVE, MEDIA, PSEUDOCLASS, PSEUDOELEMENT, makefile PREPROCESSOR, SGML COMMAND, JSON KEYWORD | `keyword` |
| FUNCTION, CMDLET, ALIAS, DEF NAME, BUILTINS, FUNC1 to FUNC3, FUNCS AND METHODS, WINDOW INSTRUCTION, MACRO, PROPERTY NAME, KEY, ATTRIBUTE (HTML, XML, CSS, Python), CSS IDENTIFIER (property names), YAML and TOML IDENTIFIER (keys), USER ATTRIBUTES, batch COMMAND, makefile TARGET, Go PREDECLARED IDENTIFIERS, diff POSITION | `info` |
| TYPE WORD, CLASS NAME, MODULE NAME, Rust KEYWORDS 2 (primitive types), LIFETIME, CSS CLASS, ini and properties SECTION, TOML TABLE | `type` |
| TAG, TAG END, TAG UNKNOWN, USER TAGS, XMLSTART, XMLEND, PHP QUESTION MARK, DECORATOR, PREPROCESSOR, COMMENT DOC KEYWORD, JSON LD KEYWORD | `tag` |
| URI, COMPACT IRI, YAML REFERENCE, LABEL, CSS ID, diff HEADER (file paths) | `reference` |
| NUMBER, DATETIME, ESCAPE SEQUENCE, ESCAPE CHAR, REGEX, Ruby SYMBOL, ENTITY, CSS VALUE | `literal` |
| Every STRING style, CHARACTER, TRIPLE, F STRING, VERBATIM, HERE STRING, TEMPLATE LIT., BACKTICKS, HTML VALUE, ini DEFVAL, YAML TEXT, diff ADDED | `success` |
| Every COMMENT style, POD, Ruby DATA SECTION | `faint` |
| OPERATOR, SYMBOLS, ASSIGNMENT, HERE DELIM, SGML DEFAULT, SGML 1ST PARAM, SGML BLOCK DEFAULT, YAML DOCUMENT, diff COMMAND | `dim` |
| ERROR, LEXICAL ERROR, STRING EOL, COMMENT DOC KEYWORD ERROR, makefile IDEOL, diff DELETED | `error` |

Search results panel:

| Style | Color |
|---|---|
| Search Header | `text` on `deep`, bold |
| File Header | `reference` |
| Line Number | `faint` |
| Hit Word | `text` on `steel` wash |

## Gaps and trade-offs

- **Window chrome.** A theme file colors only the editor and the tabs. In Light Mode the menu bar, toolbar, status bar, panels, and dialogs are Windows'. In Dark Mode they use Notepad++'s dark tone (`config.xml`, `DarkMode` `colorTone` and `customColor*`). The Customized tone could take palette colors, but it is an app setting stored as numbers in `config.xml`, not part of a theme file, so the port does not ship it. This is why the port is Tier 2.
- **The match at the cursor.** Notepad++ draws find and smart highlights as see-through indicators over the text and keeps its syntax colors. It has no style for the current match apart from the selection, so the current match is the selection's firelight wash. The see-through drawing also makes the steel wash look lighter than the palette value.
- **Selected text color.** Notepad++ ignores the selection's fgColor unless the user adds `enableSelectFgColor.xml`, so the selection keeps syntax colors on its firelight wash.
- **Languages left out.** The theme has no `modelDate`, so Notepad++ (8.8.9 and later) merges every language and style the file lacks from `stylers.model.xml` the first time it loads the theme, and saves them into the theme file. From 8.9 the added styles take the Default Style colors (`text` on `base`). This keeps the template to the common languages without leaving any language in another theme's colors.
- **User Defined Languages** keep their own colors; a theme cannot change them.
- **What the shots show.** The editor scene opens `Contrast.psm1` in PowerShell, with "Hex" selected so Smart Highlighting marks the other occurrences. They show `keyword`, `info` (cmdlets, functions), `type`, `literal`, `success`, `faint`, `dim`, `text`, the selection, the current line, line numbers, the caret, the tabs, and the steel match wash if Smart Highlighting fires on the restored selection. They cannot show `reference`, `tag`, `error`, the Change History marks, brace highlighting, the Mark styles, or the search results panel.

## Research

- [catppuccin/notepad-plus-plus](https://github.com/catppuccin/notepad-plus-plus): one XML per flavor in `%AppData%\Notepad++\themes`, picked in the Style Configurator, the font left to Default Style, and the dark-mode chrome handled separately with the Customized tone. Method only.
- `DarkModeDefault.xml` and `stylers.model.xml` from the [Notepad++ 8.9.9.1 source](https://github.com/notepad-plus-plus/notepad-plus-plus/tree/v8.9.9.1/PowerEditor): the list of styles, their `styleID`s and `keywordClass`es, and every Global Styles widget name. The user manual says to start a dark theme from `DarkModeDefault.xml`.
- `Parameters.cpp` in the same source: themes are chosen per mode by `darkThemeName` and `lightThemeName` on the `DarkMode` `GUIConfig` in `config.xml`; the missing-style merge and its Default Style colors (`modelDate`); `Caret` `blinkRate`; the session file's `startPos` and `endPos`.
- `documentMap.cpp`: the Document map widget's fgColor is the view zone ("focus") and bgColor the frost.

## Screenshot recipe

- Notepad++ is free software under the GPL. It needs no login or license key. See its [LICENSE](https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/LICENSE).
- The recipe uses the portable ZIP of 8.9.9.1, pinned by sha256, so `config.xml`, `session.xml`, and `themes\` sit next to `notepad++.exe`. Portable builds ship `disableNppAutoUpdate.xml`, so nothing updates during the shot.
- **apply** copies both themes into `themes\`, as Install steps 2 and 3 do. Writing the `DarkMode` line in `config.xml` (enabled for Night, with `darkThemeName` and `lightThemeName`) stands in for Install steps 5 to 8, picking the mode and the theme in the dialogs: not tested by hand.
- **stage** sets the font to BlexMono Nerd Font Mono at size 12 in the copied themes: the Photographer installs BlexMono, not IBM Plex Mono, and the glyphs are the same. It also sets the window size, stops the caret from blinking (`blinkRate` 0), and writes `session.xml`, which opens the scene file with a word selected.
