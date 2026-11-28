# Inglenook for Windows

**Tier:** 3 Minimal\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

This port is a Windows theme file. It sets three things that Windows itself lets a theme set: the accent color, light or dark mode, and the wallpaper. Windows draws everything else (the taskbar, Start, Settings, File Explorer) in its own light and dark grays. See [Known limits](#known-limits).

For the terminal, use the [Windows Terminal](../windows-terminal/README.md) port as well.

## Before you start

- Windows 11, or Windows 10 version 1903 or later.
- Nothing to install. The theme does not change any system files.

## Install

1. Download or clone this repo.
2. Open File Explorer, click the address bar, type `%LOCALAPPDATA%\Microsoft\Windows\Themes`, and press **Enter**.
3. Create a folder named `Inglenook` and open it.
4. Copy the two wallpapers into it:
   - `wallpapers/cabin-seating.jpg`
   - `wallpapers/mission-fireplace.jpg`
5. Copy the two theme files into the same folder:
   - `Ports/windows/dist/day/inglenook-day.theme`
   - `Ports/windows/dist/night/inglenook-night.theme`

   The folder now holds four files, and the first theme is at `%LOCALAPPDATA%\Microsoft\Windows\Themes\Inglenook\inglenook-day.theme`.
6. Double-click `inglenook-night.theme` (or `inglenook-day.theme`). Windows applies it and opens **Settings** > **Personalization** > **Themes**.

The wallpaper must stay in this folder: the theme files point to it there.

Files to use:

- Inglenook Day: `dist/day/inglenook-day.theme`, with `wallpapers/cabin-seating.jpg`
- Inglenook Night: `dist/night/inglenook-night.theme`, with `wallpapers/mission-fireplace.jpg`

## Set the font

Windows has no setting for the font of its own menus and windows, so the theme cannot set it. Set IBM Plex Mono in each app instead, as each port's guide describes.

## Check that it worked

The wallpaper is a sunlit cabin (Day) or a fireplace (Night). In **Settings** > **Personalization** > **Colors**, the mode is Light (Day) or Dark (Night), and the accent color is a warm amber. Switches that are on in Settings are amber too.

## Switch between Day and Night

1. Open **Settings** > **Personalization** > **Themes**.
2. Click **Inglenook Day** or **Inglenook Night**.

You can also double-click the other `.theme` file in `%LOCALAPPDATA%\Microsoft\Windows\Themes\Inglenook`. Windows does not switch themes on a schedule by itself.

## Make it see-through (optional)

The theme is solid. Windows has its own **Transparency effects** switch in **Settings** > **Personalization** > **Colors**, which blurs the taskbar and Start. It is up to you.

## Uninstall

1. Open **Settings** > **Personalization** > **Themes**.
2. Click **Windows (light)** or **Windows (dark)** to go back to a Windows theme.
3. Right-click **Inglenook Day** and click **Delete**. Do the same for **Inglenook Night**.
4. Delete the folder `%LOCALAPPDATA%\Microsoft\Windows\Themes\Inglenook`.

## Troubleshooting

- **The desktop is black or a plain color after applying**: the wallpaper is not where the theme looks for it. Check that both `.jpg` files are in `%LOCALAPPDATA%\Microsoft\Windows\Themes\Inglenook` (step 4), then apply the theme again.
- **The mode stays light (or dark)**: set it by hand in **Settings** > **Personalization** > **Colors** > **Choose your mode**: **Light** for Day, **Dark** for Night.
- **The accent color is not amber**: in **Settings** > **Personalization** > **Colors** > **Accent color**, choose **Manual**, then apply the theme again.
- **Nothing changes**: on a work or school PC, an administrator may lock the personalization settings.

## Known limits

- **Only the accent, the mode, and the wallpaper change.** The taskbar, Start, Settings, File Explorer, and menus keep Windows' own light or dark grays. Changing those needs a tool that patches Windows system files, which this theme does not do.
- **The accent color shifts a little.** Windows makes its own lighter and darker shades of the accent: in dark mode, links and switches use a lighter shade.
- **Old Control Panel windows and dialogs** stay light in dark mode. That is how Windows draws them.
- **No warning or error colors.** Windows keeps its own colors for those.

## Sources

- [Theme File Format](https://learn.microsoft.com/windows/win32/controls/themesfileformat-overview)
- [Personalize your Colors in Windows](https://support.microsoft.com/windows/change-colors-in-windows-d26ef4d6-819a-581c-1581-493cfcc005fe)
