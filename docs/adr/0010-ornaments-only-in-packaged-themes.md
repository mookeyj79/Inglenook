# Ornaments only in packaged themes

`assets/ornaments/` holds filigree: corner brackets, frame corners, a divider, diamonds and two backdrops. The owner made them for MikeWasHere (generated with ChatGPT), so the repo can ship them under its own license with no outside credit.

Decoration is allowed only where the build makes the whole theme and it installs as a package, such as a VS Code extension, and on the preview site. A theme the user installs by hand (copying a file, pasting settings, sourcing a script) gets no ornaments. A hand install should take as few steps as possible, and an ornament would add files and steps to it. A package installs in one step however many files it has.

Text glow and gradients on text stay out everywhere.

## Consequences

- An ornament is a `currentColor` shape from `assets/ornaments/`, filled with a palette color that has no role: oxblood or ivy, or a wash of either (`{{oxblood|wash}}`, `{{ivy|wash}}`). A wash is still a solid color with no meaning, and it lets a large ornament, such as a backdrop, sit quietly behind content. An ornament never uses firelight or a status color, so it never reads as "you are here" or as state.
- A port that uses ornaments says so in its MAPPING.md.
- The preview site draws them in oxblood (`Ports/preview/template/base.css`), and `build/site.ps1` publishes the folder.
