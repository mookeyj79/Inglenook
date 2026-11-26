# fzf: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

One `--color` option in `FZF_DEFAULT_OPTS`, built from `template/fzf.env` into `fzf.sh` and `fzf.ps1`. It starts with the base scheme `light` (Day) or `dark` (Night), from `variant.mode`, so any element a newer fzf adds falls back to a scheme of the right brightness.

| fzf color | Color | Why |
|---|---|---|
| `bg`, `preview-bg`, `gutter` | base | Solid surface. The gutter matches the list, so only the current line stands out |
| `fg`, `fg+`, `query`, `preview-fg` | text | |
| `bg+` (current line) | accent wash | The selection band |
| `pointer`, `marker`, `prompt` | accent | "You are here": the cursor line, picked lines, and the input |
| `hl`, `hl+` (matched characters) | info | No role means "match". Steel reads as information without competing with the accent on the current line. Owner to confirm |
| `spinner` | info | In progress |
| `info` (match count), `disabled` | faint | Metadata, and the query when search is off |
| `header`, `label`, `preview-label` | dim | Supporting text |
| `border`, `separator`, `preview-border` | line | |
| `scrollbar`, `preview-scrollbar` | faint | A line-colored bar is too hard to see |

## Gaps and trade-offs

- Only names fzf 0.41 knows (`preview-border` and `preview-scrollbar` came in 0.41). An unknown name stops fzf with "invalid color specification", so the newer names (`selected-*` 0.52, `list-*`, `input-*`, `header-bg` 0.58, `alt-bg` 0.62, `footer-*` 0.63, `ghost`, `nomatch` 0.66, `alt-gutter` 0.68) are left out. They fall back to the elements above or to the base scheme. Debian 12 ships 0.38 and is below the floor; Ubuntu 24.04 ships 0.44.
- `FZF_DEFAULT_OPTS` replaces a value set before it. A file built from `.env` cannot append, so the README tells users to add their own options after it.
- The query cursor is the terminal's. The screenshots use xterm without a terminal port, so it is xterm's default block (black). Not an fzf color.
- `spinner` and `header` do not show in the scene: the list loads at once and there is no `--header`.
- zoxide's picker runs fzf with `FZF_DEFAULT_OPTS` unless `_ZO_FZF_OPTS` is set (zoxide `src/cmd/query.rs`), so it needs nothing of its own. Its preview is `ls --color`, in the terminal's colors.

## Research

- Catppuccin, Dracula, Rose Pine, and Tokyo Night all ship one `--color` line in `FZF_DEFAULT_OPTS`. Catppuccin and Tokyo Night replace the variable, Dracula and Rose Pine append to it. Inglenook replaces it, as the `.env` shell file does for every env-var tool.
- Most set `bg` and `bg+`; some leave `bg` to the terminal. Setting it keeps fzf solid in a terminal without an Inglenook port.
- Color names and the versions that added them: fzf `CHANGELOG.md` and the man page. `FZF_DEFAULT_OPTS_FILE` (0.47) would let the theme sit beside a user's own options, but it is newer than Ubuntu 24.04's fzf.

## Screenshot recipe

- fzf and zoxide need no login or license (MIT).
- fzf 0.44.1 and xterm come from the pinned Ubuntu snapshot, so the recipe has no `version`.
- The scene (`build/photograph/scenes/cli/fzf/stage.sh`) runs fzf from an interactive bash, so `~/.bashrc` loads the theme as the README says. The query, two marked lines, and the preview are set by fzf options and a `start` binding, standing in for typing: not tested by hand.
- xterm draws box characters itself (`forceBoxChars`); with font glyphs the borders showed gaps between rows.
- Two takes sometimes differ and a third decides. Cause not found yet.
