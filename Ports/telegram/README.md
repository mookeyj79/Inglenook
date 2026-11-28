# Inglenook for Telegram Desktop

**Tier:** 1 Full\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

Each variant is one theme file that Telegram Desktop opens as a whole: the colors and a patterned chat wallpaper. There is nothing to unzip or build.

## Before you start

- Telegram Desktop for Windows, Linux or macOS, from [desktop.telegram.org](https://desktop.telegram.org). The separate Telegram app from the Mac App Store ("Telegram for macOS") uses a different theme format and is not covered.
- You are signed in.

## Install

Telegram keeps one theme for day mode and one for night mode. Install Day first, then Night, so the Night Mode switch moves between them.

1. Download or clone this repo.
2. In Telegram, open the main menu (the three lines at the top left). If **Night Mode** is on, turn it off.
3. Open **Settings** > **Chat Settings**.
4. Under **Chat wallpaper**, click **Choose from file**.
5. Pick `Ports/telegram/dist/day/inglenook-day.tdesktop-theme`. Telegram previews the theme and its chat wallpaper.
6. Click **Keep changes**.
7. Open the main menu and turn on **Night Mode**.
8. Do steps 3 to 6 again with `Ports/telegram/dist/night/inglenook-night.tdesktop-theme`.

Files to use:

- Inglenook Day: `dist/day/inglenook-day.tdesktop-theme`
- Inglenook Night: `dist/night/inglenook-night.tdesktop-theme`

You can also send a theme file to Saved Messages and click it in the chat to apply it.

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). Telegram shows no font icons, so IBM Plex Mono is the one to use. If it is not installed yet, follow [Font](../../README.md#font) in the main README.

1. Open **Settings** > **Chat Settings**.
2. Click **Font family** and pick **IBM Plex Mono**.

## Check that it worked

The chat list turns a soft neutral, the chat background shows a faint deep-red damask pattern, the open chat is marked in a warm amber, and links and the send button are the same amber.

## Switch between Day and Night

1. Open the main menu and click **Night Mode**.

To follow your system's light or dark setting, open **Settings** > **Chat Settings** and set **Auto-night mode** to **System**. Telegram then switches on its own, and the **Night Mode** switch is turned off while it does.

## Uninstall

1. Open **Settings** > **Chat Settings**.
2. Under the themes at the top, pick one of Telegram's own themes, such as **Classic** or **Night**.
3. Turn **Night Mode** on or off and pick a built-in theme for that mode too.

## Troubleshooting

- **Choose from file does not list the file**: set the file dialog to **Theme files**, or pick **All files**.
- **Only one variant changes**: Telegram keeps a theme per mode. Turn on **Night Mode** and apply the Night file while it is on.
- **The chat background is not the damask pattern**: another wallpaper was picked after the theme. Apply the theme file again with **Choose from file**.

## Known limits

- If you pick a different chat wallpaper, Telegram tints date pills, service messages and the chat scroll bar slightly toward it.
- The fade behind dialogs and menus is solid, so the window behind them is hidden while they are open.
- Buttons and icons that Telegram draws as gradients, such as Premium, are one solid color.
- On macOS, the unread counter in the menu bar keeps Telegram's own colors.

## Sources

- [Telegram Desktop source: theme file reading and applying](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/window/themes/window_theme.cpp)
- [Telegram Desktop source: Choose from file in Chat Settings](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/settings/sections/settings_chat.cpp)
- [Telegram's list of theme colors (`colors.palette`)](https://github.com/desktop-app/lib_ui/blob/master/ui/colors.palette)
- [Telegram Desktop Theme Reference](https://github.com/telegramdesktop/tdesktop/wiki/Theme-Reference)
