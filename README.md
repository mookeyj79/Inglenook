# Inglenook

![Inglenook: a sunlit cabin room on the left and a firelit library on the right, with a cat asleep on the desk between them](assets/splash.png)

[![check](https://github.com/mookeyj79/Inglenook/actions/workflows/check.yml/badge.svg)](https://github.com/mookeyj79/Inglenook/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

*inglenook: the warm corner beside a big open fireplace.*

A cozy, soothing color theme for the tools you use every day. Technology meets simple life charm. Two equal variants, ported to every app, so your whole machine feels like one calm room.

- **Inglenook Day**: a cabin room in natural light, with plants on the sill. A soft neutral background that leans faintly green.
- **Inglenook Night**: a Victorian library by the fire. A warm smoked-walnut background.

**[Open the live preview](https://mookeyj79.github.io/Inglenook/)** to see both variants side by side, or **[browse the ports](https://mookeyj79.github.io/Inglenook/ports/)**.

## Status

The palette is at version 0.1.0. Ports are coming: the ports page lists the planned ones.

## What you get

- **Easy on the eyes.** Text is clear without glaring, there is no pure black or white, and the colors are muted and evenly matched. Errors are a calm ember, not alarm red.
- **One warm accent.** Firelight amber marks where you are: the cursor, focus, selection, and links. Nothing else uses it.
- **Colors with one job each.** Ember is failure, moss is success, brass is a warning, steel is information, in every app. See [PHILOSOPHY.md](PHILOSOPHY.md).
- **Solid colors.** The theme never depends on transparency. If your app has its own see-through setting, you can still turn it on.
- **One font everywhere:** IBM Plex Mono.

## Ports

**[Browse every port](https://mookeyj79.github.io/Inglenook/ports/)**: search by app, filter by category, and see each port's tier, platforms, and install guide. The list is generated from the ports in this repo, so it is always current.

Each port says how far it gets:

- **Tier 1, Full**: the complete palette
- **Tier 2, Partial**: most of the palette, with some gaps
- **Tier 3, Minimal**: background, accent, and status colors only

### Install a port

1. Open the port's folder, `Ports/<app_name>/`, and read its `README.md`. It is a step-by-step install guide.
2. Take the theme file from `dist/day/` or `dist/night/`. Generated files are committed, so there is nothing to build.
3. Follow the guide, including **Set the font**.

## Font

Inglenook recommends **[IBM Plex Mono](https://github.com/IBM/plex)**. Where an app shows icons (shell prompts, file trees), use **BlexMono Nerd Font**, the same font with icons added.

1. Download [IBMPlexMono.zip](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IBMPlexMono.zip) from the Nerd Fonts release. It contains BlexMono Nerd Font. For plain IBM Plex Mono, use the [IBM Plex release](https://github.com/IBM/plex/releases).
2. Unzip it and install the fonts:
   - **Windows**: select the `.ttf` files, right-click, and choose **Install for all users**.
   - **macOS**: double-click each `.ttf` and choose **Install Font**.
   - **Linux**: copy the `.ttf` files to `~/.local/share/fonts/` and run `fc-cache -f`.
3. In each app, pick **IBM Plex Mono**, or **BlexMono Nerd Font Mono** where you want icons.

Free under the SIL Open Font License.

## Wallpapers

Optional wallpapers that go with each variant will live in [`wallpapers/`](wallpapers/). The theme looks complete without them.

## How it works

- **One palette for every app.** Each port says what a color is for (background, text, error), never a specific value. Change a color once and every port updates.
- **Generated files are committed.** You can grab a theme from `dist/` without building anything.

## Add a port

This repo is set up for [Claude Code](https://claude.com/claude-code). Open it there and ask:

> Can you make a theme for Typora?

or run `/new-port typora`. Doing it by hand works too: see [CONTRIBUTING.md](CONTRIBUTING.md), which also covers the repo layout and the build.

## Contributing

Ports, fixes, and wallpaper suggestions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) for the rules every port follows and how to propose a palette change.

## License

[MIT](LICENSE), except for third-party assets, which keep their own licenses: wallpapers are listed per image in [`wallpapers/README.md`](wallpapers/README.md).
