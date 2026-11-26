# Starship: color mapping

For maintainers. The install guide is [README.md](README.md).

The port is Nowhere's `shared/starship.toml` (the layout, modules, symbols and formats, unchanged) with its colors moved onto a Starship palette. Nowhere's file uses the terminal's color names, with `black` text on every segment. In Day, `black` is `text`, which measures about 1.3 to 2.2 on the colored fills, so the port could not keep the terminal names and stay readable. It names palette colors instead, chosen by meaning.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `os`, `username`, `hostname` segment (Nowhere: red) | `oxblood` | Identity carries no meaning, so a detail color. `ember` would read as an error on every prompt |
| `directory` segment (blue) | `reference` | A path |
| `git_branch`, `git_status` segment (yellow) | `info` | Information. `warning` would stay lit on a clean repo too |
| Tool segments: `kubernetes`, `helm`, `docker_context`, `terraform`, `aws`, languages (green, docker cyan) | `ivy` | No meaning, a detail color. One fill for the whole block, so it reads as one segment |
| `time` segment (purple) | `line` fill, `dim` text | Metadata, so a neutral. dim on line: Day 5.07, Night 5.44 |
| Text on every colored segment (black) | `on_accent` | The neutral at the far end from the fills: raised in Day, deeper in Night. Day 5.2 to 8.6, Night 5.0 to 8.8 on these fills |
| Segment edges (``, ``) | the two fills they join | As Nowhere |
| `character` success, error | `success`, `error` | |
| `character` vim normal | `info` | A mode, not an outcome |
| `character` vim replace, replace one | `warning` | Caution: typing changes text |
| `character` vim visual | `accent` | Selection |
| `cmd_duration` | no color | Nowhere's format does not use its style. The style is set to `bg:line` to match `time` |
| Palette `black` to `bright-white` | `ansi.<slot>` | For modules a user adds, so they match the terminal ports |
| Palette `text`, `faint` | the same | For user styles |

## Gaps and trade-offs

- The background is the terminal's. Starship draws no surface of its own.
- **Colors the scene does not show:** the tool segment's fill (only its edge, between Git and the time, since the scene repo has no language files), `warning` and `accent` (vim modes, Bash has none; the accent shows as the host's cursor), the hostname (SSH only), and the extra palette names for user styles.

## Research

- Port studied: [Catppuccin for Starship](https://github.com/catppuccin/starship), MIT. Method only: one palette table per flavor, chosen with the `palette` line. No files or colors reused.
- Hyaline's Starship port (archive): same palette method, and its measurement that Starship's default `white` styles break in light schemes. Nothing glass-related taken.
- [Starship source, `src/config.rs`](https://github.com/starship/starship/blob/master/src/config.rs): palette names are checked before built-in color names and style words are lowercased, so palette keys are lowercase. Overriding `red` and the rest in the palette is supported.
- `STARSHIP_CONFIG`: the [config docs](https://starship.rs/config/) show it set in Bash, Zsh and PowerShell. The `.sh` and `.ps1` are written by hand, not from a `.env`, because the path needs `$HOME` expanded and `.env` values are single-quoted.
- Nowhere sets `STARSHIP_CONFIG` to its own file, then loads `theme.zsh` and `theme.ps1` last, so the Inglenook source line wins there.

## Screenshot recipe

- Starship needs no login or license (ISC, [LICENSE](https://github.com/starship/starship/blob/master/LICENSE)).
- `screenshot.json` shoots the prompt scene with Starship 1.27.0 (the official musl release, checked against its sha256, the version Nowhere pins) inside the GNOME Terminal port in the same variant.
- **apply** follows the README's Zsh or Bash install. Not tested by hand:
  - "Starship already set up in your shell" is the `eval "$(starship init bash)"` line in `~/.bashrc`, from the [Starship install guide](https://starship.rs/guide/).
  - Saving the files is `mkdir -p` and `cp`; opening a new terminal is the host launching it.
- **stage** pins the clock: it sets `time_format` to a fixed `10:30` (Day) or `21:30` (Night) in the copied file, so takes match pixel for pixel. It changes no color.
