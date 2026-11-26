# Windows Terminal: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Color scheme (`schemes-<variant>.json`, a fragment):

| App setting | Color | Why |
|---|---|---|
| `background` | base | |
| `foreground` | text | |
| `cursorColor` | accent | |
| `selectionBackground` | accent wash | Selections use a wash, so selected text keeps its own color and stays readable (Windows Terminal has no selection text color) |
| `black` .. `white`, `bright*` | `ansi.<slot>` | The sixteen slots per ADR 0005. Windows Terminal calls magenta `purple` |

Theme (`themes-<variant>.json`, pasted into `settings.json`):

| App setting | Color | Why |
|---|---|---|
| `window.applicationTheme` | the variant's mode | Light or dark menus and chrome text; also picks the matching half of the `colorScheme` pair |
| `window.frame` | accent | The active window is "you are here" |
| `window.unfocusedFrame` | line | A border that carries no meaning |
| `tabRow.background`, `tabRow.unfocusedBackground` | deeper | The title bar |
| `tab.background` (active tab) | base | Joins the active tab to the terminal below it |
| `tab.unfocusedBackground` | not set (`null`) | Inactive tabs show the tab row |

Profile defaults (in the README, not a file): `colorScheme` and `theme` as dark and light pairs, `intenseTextStyle: bold`, `font.face: BlexMono Nerd Font Mono`.

## Gaps and trade-offs

- **Bold text is not brightened.** By default Windows Terminal draws bold text in the default color as the bright version of the ANSI slot it matches ([`TextColor::GetColor`](https://github.com/microsoft/terminal/blob/v1.25.3131.0/src/buffer/out/TextColor.cpp#L163)). Day's `foreground` equals its `black` (text), so bold text would come out `brightBlack` (faint). `"intenseTextStyle": "bold"` keeps it bold in text.
- **Tab and menu text color** comes from `applicationTheme`, so chrome text is not a palette color.
- **Selected text** keeps its own color on the accent wash. The wash keeps text above 4.5:1 by the palette's own floor.
- **Window frame colors** need Windows 11. The docs list `frame` and `unfocusedFrame` as Preview-only, but `frame` drew in stable 1.25.3131.0 for the earlier Hyaline port. `unfocusedFrame` has not been checked.
- **Scrollbar, command palette, and settings screen** follow `applicationTheme`.
- **No transparency.** `opacity`, `useAcrylic` and `useMica` are never set; the README points to them as the user's own option.
- **Colors the scene does not show:** a wash (no selection is staged), white and bright white, the bright hue slots, and `unfocusedFrame`. The accent shows as the cursor and the window frame; deeper as the tab row; base as the active tab and the terminal.

## Research

- Ports studied: [Catppuccin for Windows Terminal](https://github.com/catppuccin/windows-terminal) and [Rosé Pine for Windows Terminal](https://github.com/rose-pine/windows-terminal), both MIT. Method only: one scheme and one theme per variant, and leaving `tab.unfocusedBackground` unset. No files or colors reused. The install steps follow the earlier Hyaline port of this repo, without its glass settings.
- Themes hold `window`, `tabRow` and `tab` colors, and `theme` can be a light/dark pair ([Themes](https://learn.microsoft.com/windows/terminal/customize-settings/themes)). `colorScheme` can be a light/dark pair, which follows the selected theme's `applicationTheme` ([Appearance profile settings](https://learn.microsoft.com/windows/terminal/customize-settings/profile-appearance)). Fragments hold profiles and schemes, not themes, and must be UTF-8 ([JSON fragment extensions](https://learn.microsoft.com/windows/terminal/json-fragment-extensions)).

## Screenshot recipe

- Windows Terminal needs no login or license (MIT, [license](https://github.com/microsoft/terminal/blob/main/LICENSE)).
- `screenshot.json` shoots the terminal scene (`build/photograph/scenes/terminal/run.ps1`, the same text as `run.sh`) in the portable Windows Terminal 1.25.3131.0 ZIP, checked against its sha256, on a hosted `windows-2025` runner, one job per take. The Photographer sets the Windows mode per variant, and the installed `theme` and `colorScheme` pairs follow it, so both variants use the same apply steps.
- **apply** first removes `%LOCALAPPDATA%\Microsoft\Windows Terminal`, so every take starts from a Terminal that has never run: in the Hyaline port, a second take in one job ignored `settings.json`. Then it follows Install steps 2 to 13: the two scheme files into `Fragments\Inglenook`, both themes into `settings.json`, and the `theme` and profile defaults. Names come from `dist/`.
- **Scripted stand-ins, not tested by hand:** the README's copy, paste and edit steps are PowerShell lines that write the same files. The plain ZIP (no `.portable` file) reads `%LOCALAPPDATA%\Microsoft\Windows Terminal`, as an installed Terminal does.
- **stage** sets `showAdminShield` to false (the runner runs elevated, which adds a shield to the tab row) and the scene's 110 x 30 cells. No color changes.
- **launch** opens a tab titled `Terminal` that runs the scene in `pwsh`.
