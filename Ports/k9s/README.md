# Inglenook for K9s

**Tier:** 1 Full\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

## Before you start

- K9s 0.50 or newer, on Windows, macOS, or Linux.
- A terminal that shows 24-bit color. Most do: Windows Terminal, GNOME Terminal, iTerm2, and others.

## Install

1. Find K9s's folders: run `k9s info` and note the **Config** and **Skins dir** lines. By default they are:
   - Windows: `%LOCALAPPDATA%\k9s\config.yaml` and `%LOCALAPPDATA%\k9s\skins\`
   - macOS: `~/Library/Application Support/k9s/config.yaml` and `~/Library/Application Support/k9s/skins/`
   - Linux: `~/.config/k9s/config.yaml` and `~/.config/k9s/skins/`
2. Save `inglenook-day.yaml` or `inglenook-night.yaml` (or both) into the skins folder. Make the folder if it does not exist.
3. Open `config.yaml` and set the skin under `k9s`, `ui`, using the file name without `.yaml`:

   ```yaml
   k9s:
     ui:
       skin: inglenook-night
   ```

   If `config.yaml` already has a `k9s:` and a `ui:` section, add only the `skin:` line inside `ui:`.
4. Restart K9s.

Files to use:

- Inglenook Day: `dist/day/inglenook-day.yaml`
- Inglenook Night: `dist/night/inglenook-night.yaml`

To try a skin without editing `config.yaml`, start K9s with the `K9S_SKIN` environment variable, such as `K9S_SKIN=inglenook-day k9s`.

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). Where the app shows icons, use [BlexMono Nerd Font](https://www.nerdfonts.com/font-downloads) instead, the same font with icons added. If it is not installed yet, follow [Font](../../README.md#font) in the main README.

K9s draws in your terminal's font.

1. Open your terminal's font setting (Windows Terminal: **Settings**, your profile, **Appearance**, **Font face**; GNOME Terminal: **Preferences**, your profile, **Custom font**).
2. Pick **IBM Plex Mono**.

## Check that it worked

The background turns the theme's soft neutral, the selected row has a warm amber tint, and the border of the focused view is amber. Pods that fail show in a muted red, and finished jobs fade to gray.

## Switch between Day and Night

1. Save both skin files in the skins folder.
2. Change `skin:` in `config.yaml` to `inglenook-day` or `inglenook-night`.
3. Restart K9s.

K9s cannot follow the system's light or dark setting by itself.

## Use a skin per cluster (optional)

Each context can have its own skin, so production and test clusters look different. Set `skin:` under `k9s` in that context's own `config.yaml`, at `<cluster>/<context>/config.yaml` in the folder `k9s info` lists as **Contexts dir**:

```yaml
k9s:
  skin: inglenook-day
```

## Make it see-through (optional)

The theme draws its own background. To let your terminal's background show through, edit your copy of the skin file and set each `bgColor` you want see-through to `default`.

## Uninstall

1. Remove the `skin:` line from `config.yaml`.
2. Delete the Inglenook files from the skins folder.
3. Restart K9s.

## Troubleshooting

- **Nothing changed**: the skin name must match the file name without `.yaml`, and the file must be in the folder `k9s info` lists as **Skins dir**. A `K9S_SKIN` variable set in your shell wins over `config.yaml`.
- **Colors look wrong or blocky**: your terminal may not show 24-bit color. Try another terminal, or check that `COLORTERM` is set to `truecolor`.

## Known limits

- Healthy rows of every resource, including running pods, are plain text. K9s uses one color for every ordinary row, so running pods are not green.
- Values in the YAML view are one color: K9s does not tell strings from numbers there.
- Pods that are deleting and pods that fail share a color, as both mean something is going away.

## Sources

- [K9s Skins](https://k9scli.io/topics/skins/)
- [K9s README: Configuration and Skins](https://github.com/derailed/k9s#k9s-configuration)
- [K9s skin keys (internal/config/styles.go)](https://github.com/derailed/k9s/blob/v0.51.0/internal/config/styles.go)
- The file layout follows [Catppuccin for k9s](https://github.com/catppuccin/k9s) (MIT License, Copyright (c) 2021 Catppuccin).
