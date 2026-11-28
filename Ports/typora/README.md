# Inglenook for Typora

**Tier:** 1 Full\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

## Before you start

- Typora 1.0 or later, on Windows, macOS, or Linux
- IBM Plex Mono installed, for code (see [Set the font](#set-the-font))

## Install

1. Download both theme files, listed under **Files to use** below.
2. Open Typora's preferences: **File > Preferences** on Windows and Linux, **Typora > Settings** (Cmd+,) on macOS.
3. Go to **Appearance** and click **Open Theme Folder**. A file manager window opens on Typora's `themes` folder.
4. Copy `inglenook-day.css` and `inglenook-night.css` into that folder. Keep the file names as they are: Typora ignores theme files with capital letters or spaces in their names.
5. Quit Typora and open it again.
6. Open the **Themes** menu and pick **Inglenook Day** or **Inglenook Night**.

On macOS the theme folder is usually `~/Library/Application Support/abnerworks.Typora/themes/`.

Files to use:

- Inglenook Day: `dist/day/inglenook-day.css`
- Inglenook Night: `dist/night/inglenook-night.css`

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). If it is not installed yet, follow [Font](../../README.md#font) in the main README.

The theme sets IBM Plex Mono for inline code, code blocks, and source code mode. Typora has no font setting of its own, so there is nothing to change: once the font is installed, restart Typora and code uses it.

Body text keeps Typora's own default font. To use another one, such as IBM Plex Mono for everything:

1. In the theme folder (step 3 of Install), create a file named `inglenook-day.user.css`, and another named `inglenook-night.user.css`.
2. Put this line in each: `#write { font-family: "IBM Plex Mono", monospace; }`
3. Restart Typora.

Typora loads a `<theme>.user.css` file after its theme, so your font survives updates to the theme file.

## Check that it worked

The page is a soft off-white in Day or a warm dark brown in Night. Links and the text cursor are amber, and code blocks are colored with keywords, strings, and numbers each in their own color.

## Switch between Day and Night

1. Open the **Themes** menu.
2. Pick **Inglenook Day** or **Inglenook Night**.

On macOS and Windows, Typora can follow the system's light and dark setting with a theme for each:

1. Open preferences and go to **Appearance**.
2. Set the theme for light mode to **Inglenook Day** and the theme for dark mode to **Inglenook Night**.

## Uninstall

1. Open the **Themes** menu and pick another theme, such as **Github**.
2. Open preferences, go to **Appearance**, and click **Open Theme Folder**.
3. Delete `inglenook-day.css` and `inglenook-night.css`, and any `inglenook-day.user.css` or `inglenook-night.user.css` you made.
4. Restart Typora.

## Troubleshooting

- **The theme is not in the Themes menu**: check that the files sit directly in the theme folder, not in a subfolder, and that their names are all lowercase. Then restart Typora.
- **Code is not in IBM Plex Mono**: the font is not installed, or Typora was open while you installed it. Install it and restart Typora.

## Known limits

- Diagrams (Mermaid, flowcharts, sequence diagrams) keep Typora's own colors.
- Math formulas are drawn in the text color only.
- Some window parts drawn by the system, such as the macOS title bar and native menus, keep the system's colors.

## Sources

- [Write Custom Theme for Typora](https://theme.typora.io/doc/Write-Custom-Theme/) (Typora)
- [Install Theme](https://theme.typora.io/doc/Install-Theme/) (Typora)
- [Code Block Styles](https://support.typora.io/Code-Block-Styles/) (Typora)
- [Dark Mode](https://support.typora.io/Dark-Mode/) (Typora)
- Structure informed by the [Rosé Pine theme for Typora](https://github.com/rose-pine/typora) (MIT License, Copyright (c) Rosé Pine)
