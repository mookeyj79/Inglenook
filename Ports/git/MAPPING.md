# Git: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Every value is quoted in the template: Git reads an unquoted `#` as the start of a comment, which leaves the slot empty.

| App setting | Color | Why |
|---|---|---|
| `color.diff.meta` | text, bold | The file header block, as Git's default bold |
| `color.diff.frag` | reference | Hunk positions are anchors into the file |
| `color.diff.func` | dim | Supporting text after the hunk header |
| `color.diff.old`, `new` | error, success | Removal and addition |
| `color.diff.commit` | literal | A hash is a number |
| `color.diff.whitespace` | error, reversed | A whitespace error |
| `color.diff.oldMoved`, `newMoved` | heather, pine | Moved blocks are about telling blocks apart, not meaning: named colors, as Git's magenta and cyan defaults |
| `color.diff.oldMovedAlternative`, `newMovedAlternative` | steel, dusk | As above. Not brass, which would read as a warning |
| `color.diff.*MovedDimmed`, `*MovedAlternativeDimmed` | the same colors, dim | Git's own dimmed style |
| `color.diff.contextDimmed` | faint | range-diff context |
| `color.diff.oldDimmed`, `newDimmed` | error, success, dim | range-diff |
| `color.diff.contextBold` | bold only | range-diff; context has no color |
| `color.diff.oldBold`, `newBold` | error, success, bold | range-diff |
| `color.diff.context` | not set | Plain text stays the terminal's text |
| `color.decorate.HEAD` | accent, bold | "You are here" |
| `color.decorate.branch` | reference | |
| `color.decorate.remoteBranch` | info | Told apart from local branches |
| `color.decorate.tag` | tag | |
| `color.decorate.stash` | heather | No role fits; Git's default magenta |
| `color.decorate.grafted` | warning | A shallow history is a caution |
| `color.branch.current` | accent, bold | |
| `color.branch.local` | reference | Same as decorate |
| `color.branch.remote`, `upstream` | info | Same as decorate |
| `color.branch.plain` | dim | |
| `color.status.header` | faint | The "(use git ...)" hints are supporting text |
| `color.status.added` (and `updated`) | success | |
| `color.status.changed` | warning | Brass means change |
| `color.status.untracked` | info | New to Git, not a failure: Git's default red would misuse ember |
| `color.status.branch` | accent, bold | |
| `color.status.nobranch` | warning, bold | A detached HEAD is a caution |
| `color.status.localBranch`, `remoteBranch` | reference, info | Same as decorate |
| `color.status.unmerged` | error, bold | A conflict |
| `color.grep.filename` | reference | Paths |
| `color.grep.lineNumber`, `column` | literal | Numbers |
| `color.grep.function` | dim | |
| `color.grep.match` | text on the accent wash, bold | A find match (PHILOSOPHY.md, Washes) |
| `color.grep.separator` | dim | Punctuation |
| `color.grep.context`, `selected` | not set | Plain text |
| `color.interactive.prompt` | accent, bold | Where you type |
| `color.interactive.header` | bold only | |
| `color.interactive.help` | dim | |
| `color.interactive.error` | error | |
| `color.remote.hint`, `color.advice.hint` | info | Information |
| `color.remote.warning`, `success`, `error` | warning, success, error | |
| `color.push.error`, `color.transport.rejected` | error | |
| `color.blame.repeatedLines` | faint | Repeated metadata |
| `color.blame.highlightRecent` | faint, dim, text by age | Older lines recede; no role is misused for "recent" |

## Gaps and trade-offs

- Tier 1: Git takes 24-bit colors and every slot it has gets one. Git has no surfaces: the background, plain text and cursor come from the terminal and its own port.
- The grep match is the one background Git sets. The wash is mixed into `base`, so it is exact only on an Inglenook terminal.
- The screenshots show Git in a stock GNOME Terminal in the variant's mode, not on an Inglenook terminal: there is no terminal port to host it yet. The scene's prompt is ANSI, so its colors are the stock terminal's. When a GNOME Terminal port exists, make it the host (`"host": "gnome-terminal"`, drop `launch` and `window`).
- Not in the scene: moved lines, range-diff, whitespace errors, interactive add, remote and push messages, blame, stash and grafted decorations, a detached HEAD, unmerged files, tags in `git branch`. Their colors follow the same roles as the slots the scene shows.

## Research

- Dracula's Git theme (github.com/dracula/git): a `.gitconfig` with `[color "..."]` sections, loaded through `[include]`. It uses ANSI names only, so it follows the terminal palette. This port uses 24-bit values instead, so it looks the same on any terminal with 24-bit color. Method only.
- Catppuccin, Nord, Gruvbox and Rose Pine theme Git through delta rather than Git's own color slots.
- The slot list is from `Documentation/config/color.adoc` in git.git. 24-bit `#rrggbb` values work since Git 2.12.
- `color.decorate.symbol` (newer Git) is not in the current docs, so it is not set.

## Screenshot recipe

- Git needs no login or license.
- Git has no window: the recipe installs GNOME Terminal and launches the CLI scene in it. `scenes/cli/git/stage.sh` sets only the terminal's font, size, cursor blink and menu bar, never a color; `session.sh` adds fixed history and runs real git commands.
- The apply steps run `git config` from `~`: the repo is mounted at `/inglenook` and may be a worktree whose `.git` points outside the container, which makes any git command fail there. A reader runs it from any folder.
- Git and GNOME Terminal come from the Ubuntu package date in `build/photograph/pins.json` (Git 2.43.0, GNOME Terminal 3.52.0), so the recipe has no `version`.
