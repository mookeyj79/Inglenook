# GRUB: color mapping

For maintainers. The install guide is [README.md](README.md).

A GRUB theme is a `theme.txt` (global properties and components, per the GRUB manual's [Theme file format](https://www.gnu.org/software/grub/manual/grub/html_node/Theme-file-format.html)) plus images. Colors in `theme.txt` are `#RRGGBB`. Every box that is filled (the selected entry, the scroll bar) is a *styled box*: nine image slices, `<name>_c.png` for the center, `_w`/`_e` for the sides, and so on. A missing slice is left empty. GRUB reads PNG, JPEG and TGA, not SVG.

So the images are made by the build, not committed as raw pixels: each `template/<name>.png.fill` holds one color placeholder and a size (`{{accent|wash}} 8x8`), and the build writes `dist/<variant>/<name>.png`, a solid image of that color. GRUB scales the center and side slices to fit, so one solid pixel block per slice is enough.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `desktop-color` | `base` | The whole screen. No `desktop-image`: the theme is solid |
| `title-text` | empty | As Catppuccin. Nothing to color |
| `boot_menu` `item_color` | `text` | Menu entries are content |
| `boot_menu` `selected_item_color` | `text` | Text on the selection wash, as every port does |
| `selected_item_pixmap_style` `select_c.png`, `select_w.png`, `select_e.png` | `accent` wash | The selection. The side slices (12 px) pad the text away from the band's edges, since `item_padding` does not reach past the box |
| `scrollbar_frame` `scrollbar_frame_c.png` | `deep` | A recessed track |
| `scrollbar_thumb` `scrollbar_thumb_c.png` | `faint` | Like a scroll thumb elsewhere; carries no meaning |
| `label` `__timeout__` color | `dim` | Supporting text |
| `label` `@KEYMAP_MIDDLE@` color | `faint` | Key help is metadata |
| `item_font`, `terminal-font`, label `font` | IBM Plex Mono Regular 20 | The name `grub-mkfont -s 20` writes for `IBMPlexMono-Regular.ttf` (checked) |

## Gaps and trade-offs

- The command line and the entry editor use the console colors `color_normal` and `color_highlight`, set in `grub.cfg` with the 16 VGA color names, not in the theme. GRUB draws their black background over any `terminal-box`, so a solid `terminal-box` was tried and dropped (it never showed). The console stays black, which the palette does not allow but the theme cannot reach.
- No menu frame (`menu_pixmap_style`): Catppuccin has none either, and a `raised` panel on `base` added nothing at boot. The scroll bar sits in the center slice (`scrollbar_slice = "center"`), since the default east slice needs a menu frame and is otherwise not drawn.
- No entry icons (`icon_width = 0`): the icons are images of distro logos, not colors, and distros ship different classes.
- One font size for every resolution; GRUB fonts are bitmaps at a fixed size.
- No firelight fill with `on_accent` text: GRUB has one selected-entry style, and a selection is a firelight wash.
- The font is not shipped. IBM Plex is under the SIL Open Font License, which allows redistribution, but its license names "Plex" as a Reserved Font Name, and a `.pf2` conversion is a Modified Version under the OFL: it could not be shipped under the name IBM Plex Mono, and the theme refers to the font by that name. The README has the reader make it with `grub-mkfont` instead, which also keeps binaries out of `dist/`.

## Research

- [Catppuccin for GRUB](https://github.com/catppuccin/grub) (MIT, Copyright 2021 Catppuccin): one folder per flavor with `theme.txt`, `font.pf2`, `background.png`, `logo.png` and `select_{c,e,w}.png`; a centered `boot_menu` and a `__timeout__` label. Kept: the layout, the `select_*.png` styled box with c, e and w slices, the label countdown, an empty title. Not kept: the logo (Catppuccin's), the background image (a solid color does the same through `desktop-color`), the shipped font (Unifont).
- Theme format from the GRUB manual's Theme file format section (GRUB 2.12 `docs/grub.texi`). `scrollbar_width` is not in the manual's list but is read by `gui_list.c` and is in GRUB's `docs/example_theme.txt`.
- `grub-mkconfig` (`/etc/grub.d/00_header`) writes a `loadfont` for every `*.pf2` in the theme's folder when `GRUB_THEME` is set, so the font only has to be in that folder.
- Checked by rendering both variants in real GRUB 2.12 (Debian `grub-pc-bin`), booted from a `grub-mkrescue` image in QEMU without KVM: the menu, the selection with padding, the countdown, the key help, the scroll bar with fifteen entries, and the command line (black, as above).

## Screenshot recipe

- GRUB needs no login or license (GPL-3.0). It is manual because the menu runs before an operating system, which the Photographer's desktop container cannot reach.
- A VM is the easy way to take the shots: install the theme in a Linux Mint VM (Install steps), set `GRUB_TIMEOUT_STYLE=menu` and `GRUB_TIMEOUT=30`, and capture the VM's screen at the menu. A cheaper way, used for the check above: build a `grub-mkrescue` ISO with the `dist/<variant>/` folder and the `.pf2` in `boot/grub/themes/`, a `grub.cfg` that sets `gfxmode=1280x800`, `terminal_output gfxterm`, `loadfont` and `theme`, and a few `menuentry` lines, then boot it with `qemu-system-x86_64 -cdrom grub.iso -display none -monitor stdio` and run `screendump` at the menu. This could become an automatic recipe later, if the Photographer learns to run QEMU.
- The menu fills the screen, so the wallpaper backdrop the Photographer names does not show.
