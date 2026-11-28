# Which ports could carry the filigree

Research for [#114](https://github.com/mookeyj79/Inglenook/issues/114). For each port: does it install as a package, can the app draw an image, where an ornament would go, and what it would cost. Gathered 2026-11-28 from each app's official docs or source, linked below. Nothing here is built.

The rule being tested is [ADR 0010](../adr/0010-ornaments-only-in-packaged-themes.md): ornaments only where the build makes the whole theme and it installs as a package, plus the preview site. Ornaments are `currentColor` shapes filled with oxblood or ivy.

## How an ornament gets its color

The SVGs in `assets/ornaments/` have no color of their own. How a port fills them depends on the app's renderer:

- **Browser engines** (VS Code webviews, Obsidian, Typora, Insomnia, Heroic, Homepage, Jellyfin, theme.park, the web port). The preview's method works as is: a pseudo-element with `background: {{oxblood}}` and the SVG as a `mask-image` (`Ports/preview/template/base.css`). The SVG can be a file next to the CSS or a data URL inside it, so a single-file theme stays a single file.
- **Qt, GTK and Cinnamon stylesheets** (qBittorrent, Mod Organizer 2, OBS, GTK, Cinnamon). No masks. The SVG has to be a template with the color placeholder in it, built into `dist/`, the way Cinnamon's `assets/` and Mod Organizer 2's `check.svg` already are.
- **Raster only** (GRUB, Telegram's wallpaper, Windows Terminal, the VS Code and Visual Studio extension icons). These need a PNG. The build makes only solid PNGs today (GRUB's `.png.fill`); it has no SVG-to-PNG step. Adding one (resvg, rsvg-convert or ImageMagick) is a new build dependency.

Size: the shapes are 1 KB (diamond) to 24 KB (oak frame) as SVG, about a third more as base64. A divider and a set of brackets add about 45 KB to a stylesheet.

## Every port

**Packaged** means one install step for the whole theme, however many files: an extension, a plugin from a store, a single theme bundle. **Folder** means the user copies one theme folder whole. That adds files but no steps for an extra SVG inside it. **Hand** means copying single files, pasting text, or sourcing a script.

### Candidates (packaged, image possible)

| Port | Install | What the app can draw | Where an ornament would go | Cost |
|---|---|---|---|---|
| VS Code | Packaged (VSIX) | Not the workbench: extensions get no DOM access and cannot add CSS to the UI ([capabilities](https://code.visualstudio.com/api/extension-capabilities/overview#restrictions)). An extension can add CSS to the built-in **Markdown preview** ([`markdown.previewStyles`](https://code.visualstudio.com/api/extension-guides/markdown-extension#changing-the-look-of-the-markdown-preview-with-css)), scoped to the active theme with `body[data-vscode-theme-id="..."]` ([webview theming](https://code.visualstudio.com/api/extension-guides/webview#theming-webview-content)). The extension `icon` is a PNG of at least 128 px ([manifest](https://code.visualstudio.com/api/references/extension-manifest)). | Markdown preview: `hr` as the divider, as on the preview site. Extension icon: a diamond. | One CSS file and one `package.json` entry per variant. Shows only while an Inglenook theme is active. The preview's HTML is plain Markdown output, so upkeep is low. The icon needs the SVG-to-PNG step. |
| Visual Studio | Packaged (VSIX, built by the user) | Colors only inside the IDE. The VSIX manifest takes an `Icon` (32 px) and a `PreviewImage` (200 px), PNG ([schema](https://learn.microsoft.com/visualstudio/extensibility/vsix-extension-schema-2-0-reference)). | The extension's icon in **Manage Extensions**. Nowhere in the editor. | The SVG-to-PNG step. Seen once, at install. |
| Telegram Desktop | Hand today (`.tdesktop-palette`), but the app has a packaged form | A `.tdesktop-theme` can be a ZIP of `colors.tdesktop-theme` and `background` or `tiled` `.png`/`.jpg` ([Theme Reference](https://github.com/telegramdesktop/tdesktop/wiki/Theme-Reference)). One file, applied with the same **Choose from file**. | The chat background: `backdrop-damask.svg` tiled in oxblood on `base`. Bubbles stay solid, so message text never sits on the pattern. | The SVG-to-PNG step and a ZIP step in the build. The README loses its manual solid-wallpaper steps, so the install gets shorter. Date and service pills sit on the pattern, on their own solid fill. |

### Possible, but breaks ADR 0010 (not packaged today)

| Port | Install | What the app can draw | Where an ornament would go | Cost |
|---|---|---|---|---|
| Obsidian | Hand (two files per variant). Becomes packaged if submitted to the [Community directory](https://docs.obsidian.md/Themes/App+themes/Submit+your+theme): users then install it in one click | CSS, with images embedded as data URLs; community themes may not load anything remote ([Embed fonts and images](https://docs.obsidian.md/Themes/App+themes/Embed+fonts+and+images+in+your+theme), [guidelines](https://docs.obsidian.md/Themes/App+themes/Theme+guidelines#Keep+assets+local)) | `hr` in notes as the divider. Diamonds as list bullets. | No extra files: the data URLs live in `theme.css`. Publishing needs a GitHub release per version and a review. Obsidian's selectors move between releases. |
| Typora | Hand (one CSS file per variant) | CSS. A theme may bring images next to its CSS ([About Themes](https://support.typora.io/About-Themes/)), or embed them | `hr` as the divider. | No extra files with data URLs, so no extra step. Breaks the letter of ADR 0010 but not its reason. |
| Insomnia | Hand (a plugin folder). Becomes packaged if published to npm and the [Plugin Hub](https://developer.konghq.com/insomnia/plugins/): installed by name from Preferences | Theme plugins take `rawCss` ([plugin reference](https://developer.konghq.com/insomnia/plugins/plugin-reference/)); the port already uses it | Few good spots: the empty-request screen. | An npm package per variant. Few places to show it. |
| Web | Hand (two CSS files) | Any CSS | Opt-in classes like the preview's (`.ornate`, `.flourish`, `.gem`), drawn only where a site author adds them. | Data URLs keep it to the same two files. Nothing shows unless the author asks. |
| Heroic | Hand (CSS file) | CSS in Electron ([heroic-themes](https://github.com/Heroic-Games-Launcher/heroic-themes)) | Sidebar foot, settings section headings. | Selectors are Heroic's internals and change with releases. |
| Homepage | Hand (`custom.css`) | CSS ([custom CSS](https://gethomepage.dev/configs/custom-css-js/)) and a background image setting ([settings](https://gethomepage.dev/configs/settings/#background-image)) | Group headings as dividers. | `custom.css` is public even behind sign-in; harmless here. |
| Jellyfin | Hand (pasted CSS) | CSS ([CSS customization](https://jellyfin.org/docs/general/clients/css-customization/)) | Section headings on the home screen. | The paste grows by tens of KB. Selectors change between releases. |
| theme.park | Hand (CSS) | CSS over many self-hosted apps | None shared across the apps it themes. | Each app's markup differs. Not worth it. |
| Cinnamon | Folder | St CSS with `background-image` and `border-image` from files in the theme; the port already ships 28 SVGs in `assets/` | Corners on the menu and the calendar popup. | One more templated SVG in a folder already copied whole. No extra step. Breaks the letter of ADR 0010 only. |
| Mod Organizer 2 | Folder | QSS with `url()` to files beside the stylesheet; the port already ships `check.svg` | Little room: the window is lists and tool bars. | Templated SVG. Low value. |
| qBittorrent | Folder. A packaged `.qbtheme` exists, built with Qt's `rcc` ([Create custom themes](https://github.com/qbittorrent/qBittorrent/wiki/Create-custom-themes-for-qBittorrent)) | QSS with `url(:/uitheme/...)` images | Little room: lists and tool bars. | `rcc` as a build dependency for the packaged form. Low value. |
| GRUB | Folder (copied with `sudo`) | PNG, TGA or JPEG images: `desktop-image` and `image` components ([Theme file format](https://www.gnu.org/software/grub/manual/grub/html_node/Theme-file-format.html)) | Frame corners at the screen corners, around the menu. | SVG-to-PNG step, one image per corner per resolution. The menu fills the screen today (MAPPING.md), so the layout would change. |
| OBS Studio | Hand (one `.ovt` per variant) | QSS images through the `theme:` path prefix, searched in OBS's install and user config folders ([Theme System](https://github.com/obsproject/obs-studio/wiki/OBS-Studio-Theme-System)) | Little room: docks and controls. | A second folder to copy, so an extra step. |
| GTK and MATE | Folder | `background-image` and `border-image` in GTK CSS ([GTK 3 properties](https://docs.gtk.org/gtk3/css-properties.html)) | None that every app shares. | Every GTK app would get it. The port has no images by design. Not worth it. |
| Windows Terminal | Hand (fragments) | A profile `backgroundImage`, JPG, PNG or GIF ([profile appearance](https://learn.microsoft.com/windows/terminal/customize-settings/profile-appearance)); fragments can update only default and dynamic profiles ([fragments](https://learn.microsoft.com/windows/terminal/json-fragment-extensions)) | A corner bracket at `bottomRight`. | Drawn under terminal text, so it risks contrast. PNG step. Not worth it. |
| Windows | Hand (`.theme` and wallpapers) | Only a wallpaper ([Theme file format](https://learn.microsoft.com/windows/win32/controls/themesfileformat-overview)) | None in the UI. | Not worth it. |

### Not possible (the app draws no images a theme can supply)

| Port | Why |
|---|---|
| Bash, Zsh, PowerShell, PSReadLine, Starship, zsh-autosuggestions, zsh-history-substring-search, zsh-syntax-highlighting | Shell colors through escape codes. |
| bat, btop, carapace, Claude Code, Docker, eza, fzf, GitHub CLI, Git, hexyl, K9s, less, nano, ripgrep, GNU Screen, tmux | Terminal programs: text and colors only. |
| Helix, Neovim, Vim | Terminal editors: colors only. |
| GNOME Terminal | Profiles hold colors and fonts, no image ([schema](https://gitlab.gnome.org/GNOME/gnome-terminal/-/blob/master/src/org.gnome.Terminal.gschema.xml)). |
| Dopamine | A theme is colors and options ([theme.ts](https://github.com/digimezzo/dopamine/blob/v3.0.12/src/app/services/appearance/theme/theme.ts)). |
| Ghidra | Themes set colors, fonts and icons ([Theming](https://ghidradocs.com/12.1_PUBLIC/help/Docking/help/topics/Theming/ThemingUserDocs.html)). An icon carries meaning, so swapping one for a diamond is not decoration. |
| Halloy | TOML of colors ([configuration](https://halloy.chat/configuration)). |
| KiCad | JSON of colors ([colors](https://docs.kicad.org/7.0/en/pcbnew/pcbnew.html#colors)). |
| Notepad++ | Style XML: colors and font styles ([config files](https://npp-user-manual.org/docs/config-files/)). |
| Slack | Four colors in one line ([Change your theme](https://slack.com/help/articles/205166337-Change-your-Slack-theme)). |
| SumatraPDF | Color settings only ([Settings.h](https://github.com/sumatrapdfreader/sumatrapdf/blob/3.6.1rel/src/Settings.h)). |

## Best candidates, ranked

1. **VS Code, Markdown preview divider.** Within ADR 0010 as written. One CSS file per variant, drawn only while Inglenook is active, the same mask as the preview site. Lowest cost, and it shows somewhere people read.
2. **Telegram, a packaged theme with a tiled damask chat background.** Within ADR 0010 once the port switches to the ZIP form, and it removes the hand wallpaper steps. Needs the SVG-to-PNG step, which would also unlock the two extension icons.
3. **Obsidian, published to the Community directory.** Packaged once it is listed, so within ADR 0010. Dividers and diamond bullets in a writing app. Costs a release per version and a review.
4. **Typora, divider in a single CSS file.** Hand-installed, so it needs ADR 0010 changed. The data URL keeps it to the same file and the same steps, so the ADR's reason does not apply.
5. **Cinnamon, menu and calendar corners.** Hand-installed, so it needs ADR 0010 changed. The folder already carries SVGs, so no new step.

The extension icons for VS Code and Visual Studio are cheap once the SVG-to-PNG step exists, but they show only in extension lists.

## Worth changing ADR 0010 for

ADR 0010 rules out hand installs because an ornament adds files and steps. Two kinds of hand install avoid both:

- **A single CSS file with the ornament as a data URL** (Typora, Obsidian before it is listed, the web port). No new file, no new step.
- **A theme folder that is copied whole and already holds images** (Cinnamon, Mod Organizer 2, GRUB). One more file, no new step.

If the owner wants ornaments in Typora or Cinnamon, ADR 0010 could say "no new install step" instead of "packaged". That is the owner's call.
