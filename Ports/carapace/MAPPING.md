# carapace: color mapping

For maintainers. The install guide is [README.md](README.md).

The port is `styles.json`, the file `carapace --style key=value` writes to (`internal/config/config.go` in carapace): one object per registered style group, one string per field. A value is a space separated list of elvish style words, so each one is a 24-bit `#rrggbb` foreground, with `bold` or `underlined` where carapace's default has them. Unknown groups and fields are ignored, so the file sets every group carapace-bin 1.8.5 registers (`pkg/style/config.go` in carapace, `pkg/styles/` in carapace-bin). No field sets a background.

## Color mapping

### carapace (core)

| Field | Color | Why |
|---|---|---|
| `Value` | `text` | carapace's default is the terminal's text |
| `Description` | `dim` | supporting text; carapace's default is dim |
| `Usage` | `faint` | the usage line above a list is metadata |
| `Error` | `error`, bold | |
| `KeywordPositive`, `KeywordNegative`, `KeywordAmbiguous`, `KeywordUnknown` | `success`, `error`, `warning`, `faint` | yes and no words (`true`, `never`, `auto`) keep their state meaning |
| `LogLevelTrace`, `Debug` | `faint`, `dim` | quiet levels |
| `LogLevelInfo`, `Warning`, `Error` | `info`, `warning`, `error` | |
| `LogLevelCritical`, `Fatal` | `error` bold, `error` bold and underlined | carapace's defaults are red and cyan; Fatal is a failure, so it stays ember and is told apart by weight |
| `Highlight1` to `Highlight5` | `steel`, `clay`, `heather`, `pine`, `ivy` | levels of a nested value only need telling apart: named colors, in the order of carapace's blue, yellow, magenta, cyan, green. Not brass or moss, which would read as warning and success |
| `Highlight6` to `Highlight8` | `dusk`, `rosewood`, `oxblood` | carapace dims 1 to 5 for 6 to 10; the theme uses further named colors instead of the dim attribute |
| `Highlight9`, `Highlight10` | `dim`, `faint` | the last levels recede |
| `Highlight11`, `Highlight12` | `text` bold, `dim` bold | carapace's bold and dim bold |
| `FlagNoArg` | `text` | the common case stays plain |
| `FlagArg` | `steel` | a flag that takes a value is a key; carapace's blue |
| `FlagMultiArg` | `heather` | carapace's magenta |
| `FlagOptArg` | `literal` | flags are literals (PHILOSOPHY.md); carapace's yellow would read as a warning |

### carapace-bin

| Field | Color | Why |
|---|---|---|
| `HttpStatusInformational`, `Successful` | `info`, `success` | |
| `HttpStatusRedirection` | `reference` | a redirect points elsewhere; carapace's yellow is not a caution here |
| `HttpStatusClientError`, `ServerError` | `error`, `error` bold | both are failures |
| `HttpMethodGET` | `info` | |
| `HttpMethodPOST` | `success` | addition |
| `HttpMethodPUT`, `PATCH` | `warning` | change |
| `HttpMethodDELETE` | `error` | removal |
| `HttpMethodHEAD` | `heather` | carapace's magenta |
| `HttpMethodOPTIONS` | `dim` | |
| `HttpMethodCONNECT`, `TRACE` | `text` | carapace's default |
| `KillSignalTerm`, `Core` | `error`, `error` bold | the process ends |
| `KillSignalStop`, `Cont` | `warning`, `success` | |
| `KillSignalIgn` | `dim` | nothing happens |

### Tools

| Field | Color | Why |
|---|---|---|
| `git.Branch`, `hg.Branch`, `hg.Bookmark`, `lore.Branch` | `reference` | as the Git port |
| `git.Head`, `lore.CurrentBranch` | `accent`, bold | "you are here", as the Git port's HEAD and current branch |
| `git.Commit`, `lore.Revision` | `literal` | a hash is a number, as the Git port |
| `git.Tag`, `hg.Tag` | `tag` | |
| `git.Stash`, `hg.Stash` | `heather` | as the Git port's stash |
| `git.Note` | `dim` | |
| `lore.Identity` | `text` | |
| `gh.StateOpen`, `StateClosed`, `tea.*` the same | `success`, `error` | |
| `gh.StateMerged`, `tea.StateMerged` | `heather` | carapace's magenta |
| `gh.JobSuccess`, `JobFailed`, `JobInProgress` | `success`, `error`, `info` | info means in progress |
| `gh.Draft`, `RepoArchived` | `faint` | |
| `gh.RepoFork` | `dim` | |
| `gh.OwnerOrganization`, `RepoMirror` | `reference` | |
| `gh.OwnerUser`, `RepoPublic` | `text` | |
| `gh.RepoLocked` | `text`, bold | |
| `gh.RepoPrivate` | `oxblood` | a badge; carapace's red would read as an error |
| `gh.RepoTemplate` | `tag` | |
| `golang.Function`, `Field` | `info` | syntax mapping: functions and properties |
| `golang.Type`, `Constant`, `Variable` | `type`, `keyword`, `text` | |
| `docker.Container`, `Image`, `Network`, `Node`, `Service` | `steel`, `clay`, `heather`, `pine`, `ivy` | kinds only need telling apart: named colors, in the order of carapace's blue, yellow, magenta, cyan, green |
| `docker.Secret`, `Volume` | `text` underlined, `text` bold | carapace's defaults are style only |
| `zfs.Pool` | `text`, bold | |
| `zfs.Filesystem`, `Volume`, `Snapshot`, `Bookmark` | `steel`, `clay`, `heather`, `reference` | folders as `ls` blue, a volume as a device (the eza port's clay), carapace's magenta, a bookmark is a reference |

## Gaps and trade-offs

- Tier 1: carapace takes 24-bit colors and every field it has gets one. It has no surfaces: the background, the menu selection and the cursor come from the terminal and the shell.
- File and folder names are colored by `LS_COLORS` (`pkg/style/path.go`), not by `styles.json`. The eza port already ships an Inglenook `LS_COLORS` (`eza.sh`, `eza.ps1`), so this port points to it as an optional extra instead of shipping a second copy that could drift.
- carapace draws styles only in Elvish, Nushell, PowerShell, Xonsh and Zsh. Bash and Fish get plain completions.
- In Zsh, carapace drops value styles from lists longer than `CARAPACE_ZSH_STYLE_LIMIT` entries (`internal/shell/zsh/zstyle.go`).
- Not in the shots: the carapace-bin, docker, gh, git, golang, hg, lore, tea and zfs groups, and file names. The scene lists the core group only, which fits one screen.

## Research

- No theme project ports carapace: Catppuccin, Nord, Dracula, Gruvbox and Rose Pine have none. A code search finds only personal dotfiles that write a few `styles.json` fields by hand. carapace's docs point to `vivid` for `LS_COLORS` only.
- carapace source, v1.18.2 (the version carapace-bin 1.8.5 uses): `pkg/style/config.go` (core fields and defaults), `internal/config/config.go` (`styles.json` in `<config dir>/carapace/`, `map[string]map[string]string`, unknown keys ignored), `pkg/xdg/xdg.go` (`XDG_CONFIG_HOME` first on every system, then `os.UserConfigDir`), `third_party/.../elvish/pkg/ui` (style words, `#rrggbb` foregrounds).
- carapace-bin 1.8.5 `pkg/styles/`: the tool groups. `carapace --style` turns commas into spaces before it saves, so the file uses spaces.

## Screenshot recipe

- carapace needs no login or license (MIT, [repository](https://github.com/carapace-sh/carapace-bin)).
- A guest of the GNOME Terminal port. The recipe installs carapace 1.8.5 from its GitHub release, checked by sha256, and Zsh from the package date.
- Stage writes `~/.zshrc` from `build/photograph/scenes/cli/carapace/zshrc`: carapace's Zsh setup from its docs, a plain prompt, and a `zle-line-init` hook that types `carapace --style carapace.` and Ctrl+D once. It also makes the window 35 rows tall (an escape code), so the whole list fits. None of this sets a color.
- The listing is carapace's own style keys, each drawn in its style, so the shot shows every core field. Not tested by hand on Windows or macOS.
