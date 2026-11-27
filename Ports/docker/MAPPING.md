# Docker build output: color mapping

For maintainers. The install guide is [README.md](README.md).

`BUILDKIT_COLORS` sets four colors for BuildKit's live progress display (`--progress=tty`), the one `docker build`, `docker buildx build` and `docker compose build` draw in a terminal. Each takes one of the terminal's 16 slots by name (`green`, `light-green`, ...) or a decimal `r,g,b`. This port uses the slot names, so the colors are exact in a terminal set to Inglenook and follow the terminal's palette elsewhere. An `r,g,b` value is not drawn as given: BuildKit rounds it down into the 256-color cube (see Research), which would need colors the palette does not have.

The slot names are the same in both variants (ADR 0005), so `dist/day` and `dist/night` differ only in their header comment.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `run` | success (green) | Docker draws a step in this color only once it has finished without error. Docker's default is blue (cyan on Windows), which in an Inglenook terminal is info |
| `cancel` | warning (yellow) | A step stopped because another one failed. Same as Docker's default |
| `warning` | warning (yellow) | Same as Docker's default. Read but unused by BuildKit 0.35 |
| `error` | error (red) | The step that failed. Same as Docker's default |

## Gaps and trade-offs

- Tier 3: four status colors, nothing else. The header line, the error report after a failed build, and the end-of-build warnings are plain text. A running step's log lines use the terminal's faint attribute (SGR 2), not a color.
- No accent, no surfaces: BuildKit draws on the terminal's background.
- `--progress=plain` and `rawjson` have no colors at all.
- `cancel` and `warning` match Docker's defaults, so in an Inglenook terminal the only visible change is `run`. The file still sets all four, so a user's own value does not leave the others mixed.

## Research

- No other theme ports Docker build output (Catppuccin, Nord, Dracula, Gruvbox and Rose Pine have none, as of 2026-11-26).
- BuildKit v0.35.1 `util/progress/progressui/colors.go`: `BUILDKIT_COLORS` is `key=value` pairs split by `:`. Keys are `run`, `cancel`, `error`, `warning`. A value is a name from `termColorMap` (`default`, the eight ANSI names and `light-<name>`) or three comma-separated decimals. The Docker docs say "any valid RGB hex code", but a hex value has no comma and is not a name, so BuildKit logs a warning and ignores it.
- An `r,g,b` value goes through `aec.NewRGB8Bit` (`16 + 36*(r/43) + 6*(g/43) + b/43`), a 256-color index rounded down, written as `38;5;n`. Not 24-bit.
- `init.go`: defaults are run blue (cyan on Windows), cancel yellow, warning yellow, error red. `NO_COLOR` set to anything turns colors off.
- `display.go`: the color is applied only to finished steps (`isCompleted`): canceled, else error, else warning, else run. The warning branch is marked "currently unused".

## Screenshot recipe

- Docker Engine and the Docker CLI need no login or license (Apache 2.0). Docker Desktop has a paid license for larger companies, but the shot does not use it.
- A real `docker build` needs a BuildKit daemon, which needs mount and namespace privileges the Photographer's unprivileged container does not have. So the scene replays a recording instead, as the Claude Code scene replays a saved session: `build/photograph/scenes/cli/docker/build.tty` is the terminal output of a real `docker build --no-cache --progress=tty .` (Docker 29.10.1, buildx 0.39.1), recorded at 110 columns with this port's `BUILDKIT_COLORS`. Docker names terminal slots, so the colors in the shot are drawn by GNOME Terminal with the GNOME Terminal port installed in the variant.
- The scene's `Dockerfile` has one step fail while another is still running, so the shot shows finished, failed and canceled steps. `stage.sh` says how to record `build.tty` again.
