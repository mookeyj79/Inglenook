# GNOME Terminal: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `background-color` (Background) | base | |
| `foreground-color` (Text) | text | |
| `bold-color-same-as-fg` (Bold color same as text) | on, so bold uses text | |
| `bold-is-bright` (Show bold text in bright colors) | off | Bright slots are the same hue, slightly stronger, so bold-as-bright adds nothing |
| `cursor-background-color` (Cursor background) | accent | "You are here" |
| `cursor-foreground-color` (Cursor foreground) | on_accent | Text on an accent fill |
| `highlight-background-color` (Highlight background) | accent wash | Selections are a wash, so the selected text keeps reading |
| `highlight-foreground-color` (Highlight foreground) | text | GNOME Terminal sets both highlight colors together; text on a wash meets the floor |
| `palette` 0 to 15 (Palette) | `ansi.black` to `ansi.bright_white` | ADR 0005 |
| `use-theme-colors` (Use colors from system theme) | off | |
| `font`, `use-system-font` (Custom font) | BlexMono Nerd Font Mono 12 | Prompts and file listings in a terminal show icons (ADR 0006) |

Transparency keys (`use-transparent-background`, `background-transparency-percent`, `use-theme-transparency`) are not written: a new profile starts solid, and the README points to the setting as an optional extra.

Each variant has a fixed profile UUID, kept in `values.json`, so running the script again updates the profile instead of adding a copy.

## Gaps and trade-offs

- Tier 1: every color slot a profile has is set. The rest of the window (frame, tab bar, scrollbar, menus) is drawn by the GTK theme, not the profile. The README's **Theme variant** step picks its light or dark version.
- No automatic light and dark switching: a profile has one set of colors.
- Named colors with no ANSI slot (clay, oxblood, ivy, dusk, rosewood) appear only when a program prints them in 24-bit color. Firelight appears as the cursor.
- **Colors the screenshots cannot show:** the selection wash and its text (the scene selects nothing), on_accent (the cursor sits on an empty cell), `ansi.black` and `ansi.white` and the bright slots other than bright black (the scene prints none of them).

## Research

- [GNOME Terminal settings schema](https://gitlab.gnome.org/GNOME/gnome-terminal/-/blob/master/src/org.gnome.Terminal.gschema.xml): every profile key, its type, and the profiles list path. Checked against the schema in Mint 22.3's `3.52.0+mint2+xia` package: every key the script writes exists. In that version `org.gnome.Terminal.ProfilesList` defaults to the stock profile, so on a new account the script appends to a list of one and the stock profile stays.
- [GNOME Terminal help: Manage profiles](https://help.gnome.org/users/gnome-terminal/stable/pref-profiles.html): Preferences, **Set as default**, **Delete...**, and **Terminal** > **Change Profile**.
- [GNOME Terminal help: Change font and style](https://help.gnome.org/users/gnome-terminal/stable/app-fonts.html): the **Custom font** steps.
- Hyaline's GNOME Terminal port (the theme before Inglenook, `Hyaline/Ports/gnome-terminal` beside this repo): the install and uninstall scripts' method, with its glass look dropped.
- [Catppuccin for GNOME Terminal](https://github.com/catppuccin/gnome-terminal) (MIT): studied for the method of one fixed profile UUID per variant, added to `org.gnome.Terminal.ProfilesList`. No files or code were reused.
- The install scripts start with a shebang, so `check.ps1` parses them in bash and never sources them (`Test-ShellFile` in `build/lib/Shell.psm1`).

## Screenshot recipe

- GNOME Terminal needs no login or license (GPL-3.0, [license](https://gitlab.gnome.org/GNOME/gnome-terminal/-/blob/master/COPYING)).
- `screenshot.json` shoots the terminal scene in Mint 22.3's own GNOME Terminal package, `3.52.0+mint2+xia`.
- **apply** runs Install step 3 for the shot's variant, with `--default`.
- **stage** turns off the cursor blink on the default profile, so two grabs can match. No color changes.
- The install and uninstall scripts were also run in the base image on a fresh account: install, a second install (no duplicate entry), `--default`, and uninstall handing the default back to the stock profile.
- The window frame in the shots is the Photographer's, from `GTK_THEME`, not the README's **Theme variant** step, which is not tested by hand.
