# Windows: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `[VisualStyles] ColorizationColor` (the accent color) | accent | Windows uses the accent for focus, selection, switches that are on, links, and primary buttons: "you are here". Written as `0XAARRGGBB` with alpha `FF`, so the theme sets no transparency |
| `[VisualStyles] AutoColorization` | `0` | Keeps Windows from picking an accent from the wallpaper |
| `[VisualStyles] SystemMode`, `AppMode` | `Light` (Day), `Dark` (Night), from `values.json` | Windows' own light and dark surfaces, the closest it allows to the neutrals |
| `[VisualStyles] Transparency` | `0` | Solid first. Documented for Windows 7; whether Windows 10 and 11 still read it is not tested |
| `[Control Panel\Desktop] Wallpaper` | Cabin Seating (Day), Mission Fireplace (Night) | The screenshot pair. A wallpaper is an image, not a color (ADR 0007) |

Not set:

- `[Control Panel\Colors]` (the classic system colors). Microsoft's format page says to avoid them with the Aero visual style, and they are only read by the Classic, Basic, and High Contrast themes.
- "Show accent color on Start and taskbar" and "on title bars" (`ColorPrevalence` in the registry). They are not theme file keys, and a firelight title bar on every window would be decoration, not "you are here".

## Gaps and trade-offs

- Tier 3, and thinner than most Tier 3 ports: only the accent and the mode. Every surface and text color is Windows' own, and there are no status colors. Changing surfaces needs a patched `uxtheme.dll` and a custom `.msstyles`, which patches system files; out of scope unless the owner asks.
- Windows derives its own accent shades (the `AccentPalette` registry value) from `ColorizationColor`. In dark mode it draws links and switches with a lighter shade, so firelight on screen is a Windows-made tint of the palette value, not the value itself.
- `SystemMode`, `AppMode`, `AutoColorization`, and `VisualStyleVersion` are not on Microsoft's Theme File Format page. They are what Windows 10 and 11 write when you save a theme from Settings, and the theme files Windows ships use them. The README tells the reader how to set the mode by hand if a build ignores them.
- `MTSM=DABJDKT` is the value Microsoft's format page gives. Theme files Windows 10 and 11 write themselves carry `MTSM=RJSPBS`; both are expected to be accepted. Not tested by hand.
- The files are written with LF line endings (the repo's `.gitattributes`). Windows reads `.theme` files as INI; not tested by hand with LF.
- The wallpaper path uses `%LOCALAPPDATA%`, like the `%WinDir%` and `%ProgramFiles%` paths in Microsoft's examples. Not tested by hand.
- No theme pack (`.deskthemepack`): it is a `.cab`, which the build does not make. The reader copies the wallpaper next to the `.theme` file instead.

## Research

- Catppuccin has no port for Windows 10 or 11. Its closest is [catppuccin/windows9x](https://github.com/catppuccin/windows9x) (MIT): registry entries for the classic Windows 95 and 98 appearance, which it warns not to apply on any other Windows. It confirms the classic color slots are the wrong tool for modern Windows. [catppuccin/windows-files](https://github.com/catppuccin/windows-files) is for the Files app, not Windows. Nord, Dracula, Rosé Pine, and Gruvbox have no Windows OS port either (only Windows Terminal and app ports).
- Community themes for Windows 11 that recolor the taskbar and Explorer (Rectify11 and the uxtheme-patching `.msstyles` themes) all patch system files.
- [Atlas-OS/Atlas](https://github.com/Atlas-OS/Atlas) (GPL-3.0) ships plain `.theme` files for Windows 11 (`package/Executables/Themes/`), confirming the `[VisualStyles]` keys Windows writes when it saves a theme: `AutoColorization`, `ColorizationColor`, `SystemMode`, `AppMode`, `VisualStyleVersion`. Only the key names were taken, no file.
- [Theme File Format](https://learn.microsoft.com/windows/win32/controls/themesfileformat-overview): required sections (`[Control Panel\Desktop]`, `[VisualStyles]`, `[MasterThemeSelector]`), `ColorizationColor` as ARGB, `WallpaperStyle=10` (fill and crop), and where user themes live (`%LOCALAPPDATA%\Microsoft\Windows\Themes`).

## Screenshot recipe

- Windows needs no login or license to reach its themed screens, but it does need a Windows desktop. The Windows Photographer (`build/photograph/windows/shoot.ps1`) waits for an app window and crops around it, and a `desktop` recipe has no window, so it cannot shoot this port yet. Manual recipe until a Windows desktop scene exists.
- A hand-taken shot should show the desktop with the wallpaper, the taskbar, and Settings open on **Personalization** > **Colors**, so the mode and the accent show.
