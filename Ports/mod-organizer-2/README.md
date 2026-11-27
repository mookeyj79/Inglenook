# Inglenook for Mod Organizer 2

**Tier:** 2 Partial\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

## Before you start

- Mod Organizer 2, version 2.5 or later.
- Close Mod Organizer 2 before you copy the files.

## Install

1. Open the folder Mod Organizer 2 is installed in, the one with `ModOrganizer.exe`. It has a folder named `stylesheets`. In Mod Organizer 2 you can also open it from **Settings**, the **Theme** tab, **Explore...**.
2. Copy everything inside `dist/day/stylesheets/` into that `stylesheets` folder: the file `Inglenook Day.qss` and the folder `inglenook-day`.
3. Copy everything inside `dist/night/stylesheets/` into the same folder: `Inglenook Night.qss` and the folder `inglenook-night`.
4. Start Mod Organizer 2 and open **Settings** (the wrench button on the tool bar).
5. Open the **Theme** tab.
6. In **Style**, pick **Inglenook Day** or **Inglenook Night**.
7. Click **OK**. The window changes at once.

Then set the mod list colors, which Mod Organizer 2 keeps apart from the style:

8. Open `dist/day/mod-list-colors.txt` for Day, or `dist/night/mod-list-colors.txt` for Night. It lists one value for each row of the color table.
9. Open **Settings**, the **Theme** tab. Under **Colors**, double-click **Is overwritten (loose files)**.
10. In the color window, type that row's value from the file into the **HTML** box.
11. Set **Alpha channel** to 255, so the color is solid.
12. Click **OK**.
13. Repeat steps 9 to 12 for every row in the file, then click **OK** in **Settings**.

Files to use:

- Inglenook Day: `dist/day/stylesheets/` and `dist/day/mod-list-colors.txt`
- Inglenook Night: `dist/night/stylesheets/` and `dist/night/mod-list-colors.txt`

Keep each `.qss` file next to its folder: the check marks are in the folder.

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). Where the app shows icons, use [BlexMono Nerd Font](https://www.nerdfonts.com/font-downloads) instead, the same font with icons added. If it is not installed yet, follow [Font](../../README.md#font) in the main README.

Mod Organizer 2 has no font setting, so the theme sets **IBM Plex Mono** itself. Install the font and restart Mod Organizer 2. Without it, Mod Organizer 2 uses its usual font.

## Check that it worked

The window turns soft green-gray in Day or warm dark brown in Night. The selected mod has a soft amber band, and the **Run** button is amber. Select a mod that has conflicts: the mods it overwrites turn faintly green, and the mods that overwrite it turn faintly red.

## Switch between Day and Night

1. Open **Settings**, the **Theme** tab.
2. In **Style**, pick the other variant and click **OK**.
3. Set the mod list colors again from the other variant's `mod-list-colors.txt`, as in the install steps.

Mod Organizer 2 does not follow the Windows light or dark setting.

## Uninstall

1. Open **Settings**, the **Theme** tab.
2. In **Style**, pick **None** or the style you used before.
3. Under **Colors**, click **Reset Colors**.
4. Click **OK**.
5. Close Mod Organizer 2 and delete `Inglenook Day.qss`, `Inglenook Night.qss`, and the folders `inglenook-day` and `inglenook-night` from the `stylesheets` folder.

## Troubleshooting

- **Inglenook is not in the Style list**: the `.qss` files must sit directly in the `stylesheets` folder next to `ModOrganizer.exe`, not in a folder below it. Restart Mod Organizer 2 after copying.
- **Checked boxes are amber squares with no check mark**: the `inglenook-day` or `inglenook-night` folder is missing or has a different name. Copy it again next to its `.qss` file.
- **Conflict highlights look see-through or too strong**: set **Alpha channel** to 255 for every row under **Colors**.

## Known limits

- The mod list colors are not part of the style. Set them by hand for each variant, as in the install steps, and again after **Reset Colors**.
- Separator colors are your own. Mod Organizer 2 picks black or white text for them.
- The flag icons in the mod list (conflicts, notes, endorsements), the tool bar icons, and the game's icon keep their own colors.
- The line that shows where a dragged mod will land is drawn by Mod Organizer 2 itself, as a see-through band.
- Placeholder text in empty filter boxes uses a faded text color Mod Organizer 2 picks.
- Links in mod descriptions and in some dialogs keep the usual blue.
- Plugins that bring their own windows may not follow the theme in every part.

## Sources

- [Mod Organizer 2 wiki: Settings window, Theme tab](https://github.com/ModOrganizer2/modorganizer/wiki/Settings-window)
- [Mod Organizer 2 source: how styles are found and loaded](https://github.com/ModOrganizer2/modorganizer/blob/master/src/moapplication.cpp)
- [Qt: Style Sheets reference](https://doc.qt.io/qt-6/stylesheet-reference.html)
