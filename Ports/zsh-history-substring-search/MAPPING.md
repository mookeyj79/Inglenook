# zsh-history-substring-search: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Two shell variables, set in `template/zsh-history-substring-search.zsh`. Each takes a Zsh highlight spec (`fg=`, `bg=`, `bold`; see zshzle, Character Highlighting). The plugin applies it to the query inside `BUFFER` through `region_highlight`.

| Variable | Color | Why |
|---|---|---|
| `HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND` | `on_accent` on the accent fill, bold | The one match, at the cursor, per Search and matches in PHILOSOPHY.md |
| `HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND` | text on the error wash, bold | A search that failed. Ember means failure; the wash keeps it calm next to the plugin's solid red default |

Both keep the plugin's own shape (a background, a foreground and `bold`), so the two read as a pair and bold stays as a second signal besides color. `fg` is set because the plugin's default `fg=white` would otherwise be gone, and `on_accent` on firelight and `text` on a wash are measured floors (4.5).

## Gaps and trade-offs

- The error wash is mixed into `base`, so it is exact only on an Inglenook terminal. Elsewhere it still reads, as the Git grep match does.
- Hex triplets need Zsh 5.7 (NEWS, 5.7). On an 88 or 256 color terminal, Zsh can match them to the nearest color with its `zsh/nearcolor` module, so the README says approximate.
- Bash is not supported: the plugin is a ZLE script, and Bash's readline `history-search-backward` draws no highlight. PowerShell's PSReadLine history search draws none either, so the PSReadLine port has no matching token.
- `HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_TIMEOUT` is not a color and is left to the reader. It is in the README on master but not in 1.1.0.
- Both colors show in the scene.

## Research

- No theme project ports this plugin: a GitHub code search for `HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND` finds only the plugin, frameworks that wrap it, and dotfiles. The dotfiles set the two variables in `.zshrc`, which is the method here.
- The plugin sets both variables with `: ${VAR=default}`, so a value set before or after it is kept. Prezto's module (`modules/history-substring-search/init.zsh`) sets them from its own `zstyle` when it loads, and unsets them unless its `color` style is on, so the README says to source the file after the plugin loads.
- Oh My Zsh's plugin only sources the script, so the same line after `source $ZSH/oh-my-zsh.sh` works.

## Screenshot recipe

- The plugin and Zsh need no login or license (the plugin is BSD 3-Clause, Zsh has its own permissive license).
- `version` pins the plugin's v1.1.0 commit. The recipe downloads that tarball, checks its SHA-256, and loads it from `/etc/zsh/zshrc`, standing in for the reader's own install. Zsh 5.9 comes from the pinned Ubuntu snapshot. The host is the GNOME Terminal port.
- The scene (`build/photograph/scenes/cli/zsh-history-substring-search/`) runs an interactive zsh that reads the reader's `~/.zshrc`. In `zle-line-init` it types `git stash pop`, calls `history-substring-search-up` (nothing matches) and `send-break`, standing in for Ctrl+C, so that line stays on screen with the not-found highlight. On the next line it types `moss` and calls the widget again, which brings up the staged commit command with the found highlight. Widget calls stand in for pressing Up: not tested by hand.
