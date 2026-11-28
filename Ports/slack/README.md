# Inglenook for Slack

**Tier:** 3 Minimal\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

Slack's custom themes are four colors pasted as one line. Each variant is a file holding that line.

## Before you start

- The current Slack design, in the desktop app on Windows, macOS, or Linux. Theme settings are made from the desktop app, and the theme then shows in the browser too.
- Nothing to install.

## Install

1. Open the file for the variant you want and copy its one line:
   - Inglenook Day: `dist/day/slack-theme.txt`
   - Inglenook Night: `dist/night/slack-theme.txt`
2. In the Slack desktop app, click your profile picture in the sidebar.
3. Select **Preferences**.
4. Click **Appearance**.
5. Under **Color Mode**, pick **Light** for Inglenook Day or **Dark** for Inglenook Night.
6. Select **Custom theme**.
7. Next to **Theme Colors**, click **Import theme**.
8. Paste the line you copied and click **Apply**. The four color swatches change to the theme's colors.
9. Untick **Window gradient**, so the window is one solid color.
10. For Inglenook Day, untick **Darker sidebars**. For Inglenook Night, leave it as it is.
11. Click **Save changes**.

Slack keeps a theme per workspace. Repeat these steps in each workspace you want themed.

Files to use:

- Inglenook Day: `dist/day/slack-theme.txt`
- Inglenook Night: `dist/night/slack-theme.txt`

## Set the font

Slack does not let you change its font.

## Check that it worked

The sidebar and window frame take the theme's warm, quiet background, and the channel you are in is highlighted in the theme's accent instead of Slack's default.

## Switch between Day and Night

1. Open **Preferences** > **Appearance**.
2. Change **Color Mode** to **Light** or **Dark** to match the variant.
3. Under **Custom theme**, click **Import theme** and paste the other variant's line, then click **Apply** and **Save changes**.

Slack's **System** color mode follows your OS, but a custom theme does not switch with it. Pick the color mode that matches the variant you pasted.

## Uninstall

1. Open **Preferences** > **Appearance**.
2. Under **Slack themes**, pick any built-in theme, such as **Aubergine**.

## Troubleshooting

- **"Invalid theme string"**: paste only the one line from the file, with nothing before or after it. The line has four colors, each starting with `#`.
- **The colors look a little different from the file**: Slack adjusts imported colors to keep text readable. This is expected.
- **The background looks blended**: untick **Window gradient** and save.

## Known limits

- Slack themes only the window frame, the selected item, the presence dot, and the mention badge. Messages, text, and buttons keep Slack's own light or dark colors.
- Slack may shift the imported colors slightly.
- The theme does not follow your OS light or dark setting on its own.

## Sources

- [Change your Slack theme](https://slack.com/help/articles/205166337-Change-your-Slack-theme) (Slack Help Center)
- [Use dark mode in Slack](https://slack.com/help/articles/360019434914-Use-dark-mode-in-Slack) (Slack Help Center)
- Install steps adapted from [Catppuccin for Slack](https://github.com/catppuccin/slack), MIT License, Copyright (c) 2021 Catppuccin
