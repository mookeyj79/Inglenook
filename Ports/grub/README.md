# Inglenook for GRUB

**Tier:** 2 Partial\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

Themes the GRUB boot menu: the background, the menu entries, the selected entry, the scroll bar, the countdown, and the key help line.

## Before you start

- GRUB 2 with its graphical menu (`gfxterm`). Most Linux installs use it. Check the version with `grub-install --version`.
- `grub-mkfont`, to make the font. On Debian, Ubuntu, and Linux Mint it comes with GRUB (`grub-common`). On Fedora it is `grub2-mkfont`, in the `grub2-tools-extra` package.
- Root access (`sudo`). A mistake in the GRUB settings can stop your computer from starting, so keep a live USB stick at hand.

These steps use the Debian, Ubuntu, and Linux Mint paths. On Fedora and openSUSE, use `/boot/grub2/` instead of `/boot/grub/`, and `grub2-mkfont` and `grub2-mkconfig` instead of `grub-mkfont` and `update-grub`.

## Install

1. Download or clone this repo.
2. Open a terminal in the repo folder.
3. Make the theme folder (this is Inglenook Night; for Day, use `inglenook-day` and `dist/day` in every step):

   ```
   sudo mkdir -p /boot/grub/themes/inglenook-night
   ```

4. Copy the theme into it:

   ```
   sudo cp Ports/grub/dist/night/* /boot/grub/themes/inglenook-night/
   ```

5. Make the font, as described in [Set the font](#set-the-font). The theme works without it, but GRUB then uses its own font.
6. Open the GRUB settings:

   ```
   sudo nano /etc/default/grub
   ```

7. Add this line, or change it if `GRUB_THEME` is already there:

   ```
   GRUB_THEME="/boot/grub/themes/inglenook-night/theme.txt"
   ```

8. If the file has a line `GRUB_TERMINAL=console` or `GRUB_TERMINAL_OUTPUT=console`, put a `#` in front of it. The theme needs the graphical menu.
9. If your computer starts without showing the menu, also set `GRUB_TIMEOUT_STYLE=menu` and `GRUB_TIMEOUT=5`.
10. Save the file (in nano: **Ctrl+O**, **Enter**, **Ctrl+X**).
11. Rebuild the GRUB menu:

    ```
    sudo update-grub
    ```

    The output includes `Found theme: /boot/grub/themes/inglenook-night/theme.txt`.
12. Restart the computer.

Files to use:

- Inglenook Day: `dist/day/` (`theme.txt` and the `.png` files)
- Inglenook Night: `dist/night/` (`theme.txt` and the `.png` files)

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). GRUB cannot read normal font files, so you convert the font once with `grub-mkfont`. The theme asks for IBM Plex Mono Regular at size 20.

1. Download `ibm-plex-mono.zip` from the [IBM Plex Mono release](https://github.com/IBM/plex/releases?q=plex-mono) and unzip it.
2. Convert the regular weight into the theme folder:

   ```
   sudo grub-mkfont -s 20 -o /boot/grub/themes/inglenook-night/ibm-plex-mono-regular-20.pf2 ibm-plex-mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf
   ```

   It may print many lines starting with `WARNING: unsupported font feature`. They are harmless.
3. Run `sudo update-grub` again. GRUB loads every `.pf2` file in the theme folder.

Keep the size at 20: the theme names the font by its size, and a different size is not picked up. On a very large screen you can make the menu bigger by changing `20` in both the command and every `IBM Plex Mono Regular 20` in `theme.txt`.

## Check that it worked

When the computer starts, the boot menu has a plain background in the theme's colors, the entries are in IBM Plex Mono, and the selected entry sits on a soft amber band.

## Switch between Day and Night

GRUB shows one theme and cannot follow a light or dark setting.

1. Install the other variant's folder (steps 3 to 5 of Install, with `day` in place of `night`).
2. Change `GRUB_THEME` in `/etc/default/grub` to the other folder's `theme.txt`.
3. Run `sudo update-grub` and restart.

## Uninstall

1. Remove the `GRUB_THEME` line from `/etc/default/grub`.
2. Run `sudo update-grub`.
3. Delete the theme folders: `sudo rm -r /boot/grub/themes/inglenook-day /boot/grub/themes/inglenook-night`.

## Troubleshooting

- **The menu still looks the same**: check that `update-grub` printed `Found theme`. If it did not, check the path in `GRUB_THEME`. Some systems (Fedora, openSUSE) also need `GRUB_TERMINAL_OUTPUT="gfxterm"` in `/etc/default/grub`.
- **The text is in a different font**: the `.pf2` file is missing from the theme folder, or was made at another size. Redo [Set the font](#set-the-font) and run `sudo update-grub`.
- **The menu does not show at all**: set `GRUB_TIMEOUT_STYLE=menu` and `GRUB_TIMEOUT=5`, then run `sudo update-grub`. Holding **Shift** (BIOS) or tapping **Esc** (UEFI) while starting also opens it.
- **Ventoy**: this theme is for GRUB itself. Ventoy uses its own theme setup.

## Known limits

- The command line (**c**) and the entry editor (**e**) keep GRUB's own 16 console colors on black. A theme cannot change them.
- Entries have no icons.
- The theme sets one font size for every screen, so the menu looks smaller on very high resolution screens.
- Secure Boot setups that sign or lock down GRUB may ignore themes.

## Sources

- [GRUB manual: Theme file format](https://www.gnu.org/software/grub/manual/grub/html_node/Theme-file-format.html)
- [GRUB manual: Simple configuration (`GRUB_THEME`, `GRUB_TERMINAL_OUTPUT`)](https://www.gnu.org/software/grub/manual/grub/html_node/Simple-configuration.html)
- [grub-mkfont manual page](https://manpages.debian.org/trixie/grub-common/grub-mkfont.1.en.html)
- Layout adapted from [Catppuccin for GRUB](https://github.com/catppuccin/grub) ([MIT License](https://github.com/catppuccin/grub/blob/main/LICENSE), Copyright (c) 2021 Catppuccin). Its license notice is at the top of `theme.txt`.
- [IBM Plex Mono](https://github.com/IBM/plex), SIL Open Font License 1.1
