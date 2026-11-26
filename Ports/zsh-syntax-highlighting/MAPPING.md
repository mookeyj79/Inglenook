# zsh-syntax-highlighting: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

Every entry is a `ZSH_HIGHLIGHT_STYLES` key, written as `fg=#rrggbb` (Zsh draws it as a 24-bit escape). `none` leaves the word in the terminal's text color.

| App setting | Color | Why |
|---|---|---|
| `default`, `assign`, `named-fd`, `command-substitution`, `process-substitution`, `back-quoted-argument` | none (text) | Plain words. The inside of a substitution is highlighted word by word |
| `command`, `builtin`, `function`, `alias`, `suffix-alias`, `global-alias`, `hashed-command`, `arg0` | info (steel) | Syntax mapping: functions. Every kind of command word gets one color, as the plugin's own default does |
| `reserved-word`, `precommand` | keyword (heather) | `if`, `for`, `[[`; and `noglob`, `exec`, `sudo`, which modify the command after them like a keyword |
| `single-hyphen-option`, `double-hyphen-option` | literal (clay) | Syntax mapping: flags |
| `globbing` | literal (clay) | Glob operators are pattern literals, like a regex |
| `numeric-fd` | literal (clay) | A number |
| `back-double-quoted-argument`, `back-dollar-quoted-argument`, `rc-quote` | literal (clay) | Escapes inside a string, as in bat and eza |
| `single-quoted-argument`, `double-quoted-argument`, `dollar-quoted-argument` | success (moss) | Syntax mapping: strings |
| `dollar-double-quoted-argument` | reference (pine) | A `$name` inside a string refers to a parameter |
| `path`, `path_prefix`, `autodirectory` | reference (pine), underlined | Syntax mapping: paths. The underline is the plugin's own second signal that the file exists |
| `history-expansion` | reference (pine) | `!!` and `!foo` refer back to an earlier command |
| `commandseparator`, `redirection`, `command-substitution-delimiter`, `process-substitution-delimiter`, `back-quoted-argument-delimiter` | dim | Syntax mapping: punctuation |
| `comment` | faint | Syntax mapping: comments |
| `unknown-token`, `*-unclosed`, `bracket-error` | error (ember) | Syntax mapping: invalid. The plugin's default adds bold; the theme drops it |
| `bracket-level-1` to `bracket-level-5` | steel, heather, pine, dusk, rosewood | Named colors, not roles: the levels are about telling colors apart, and mean nothing else. Brass, moss, ember and clay stay out, since they would read as a state or a literal |
| `cursor-matchingbracket` | firelight wash, background | Marks where the bracket under the cursor closes, like a find match |

Parity: the token to palette name table matches the syntax mapping in PHILOSOPHY.md. PSReadLine (#24) is not built yet; check its MAPPING against this table when it lands (command steel, keyword heather, option and number clay, string moss, variable reference pine, operator dim, comment faint, error ember).

## Gaps and trade-offs

- Tier 1: every style of the `main` and `brackets` highlighters is set. The `cursor`, `line` and `root` highlighters keep the plugin's own styles (`standout` and none), which follow the terminal; `pattern` and `regexp` styles are the user's own.
- `path_pathseparator` and `path_prefix_pathseparator` are left unset, so separators take the path's color, as the plugin does by default.
- `command-substitution-quoted` and the other 0.8 split keys are left unset: they fall back to `command-substitution` and its delimiter.
- `arithmetic-expansion` is left unset: `$(( ))` stays plain text, since one color across a whole expression would hide its parts.
- Zsh only: Bash has no line editor hook for coloring the command line as it is typed.
- 0.7.1 has no `numeric-fd` highlighting; the rest works the same (checked against 0.7.1 and 0.8.0).
- The screenshots show commands, builtins, reserved words, options, globs, strings, an escape, a parameter in a string, paths, separators, a redirection, a comment and an unknown command. They do not show the brackets highlighter (off by default), unclosed quotes, history expansion or `precommand`.

## Research

- Catppuccin ([catppuccin/zsh-syntax-highlighting](https://github.com/catppuccin/zsh-syntax-highlighting), MIT) and Dracula ([dracula/zsh-syntax-highlighting](https://github.com/dracula/zsh-syntax-highlighting), MIT): one sourced file per flavor that declares `typeset -gA ZSH_HIGHLIGHT_STYLES` and sets each key. Both also set `ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)`; this port does not, since turning highlighters on is the user's choice, not a color. Both say to source the file before the plugin. It works before or after: the plugin sets its defaults with `: ${ZSH_HIGHLIGHT_STYLES[key]:=...}` (`highlighters/main/main-highlighter.zsh`, 0.8.0), so it keeps keys already set, and reads the array when it paints, so a later file wins too. The README says after, like the other shell ports.
- The keys are from the official docs: `docs/highlighters/main.md` and `docs/highlighters/brackets.md`. Values use the Zsh `zle_highlight` syntax (zshzle(1), Character Highlighting): `fg=#rrggbb` is 24-bit; on a 256 color terminal the user can load `zsh/nearcolor`.
- Checked with the real plugin (0.8.0 and 0.7.1, Zsh 5.9) by painting sample lines with the main and brackets highlighters and comparing each word's color with this table, in both variants.

## Screenshot recipe

- zsh-syntax-highlighting needs no login or license (BSD 3-clause, [COPYING.md](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/COPYING.md)).
- 0.8.0 comes from the GitHub tag archive, checked against its SHA-256, because Ubuntu 24.04 ships 0.7.1. Zsh comes from the pinned Ubuntu package date.
- The install step adds the plugin's `source` line to `/etc/zsh/zshrc`. It stands in for the reader loading the plugin before step 3 of the install. Not tested by hand.
- The scene (`build/photograph/scenes/cli/zsh-syntax-highlighting/`) starts an interactive zsh that loads `~/.zshrc`, then types each staged line into the real line editor from a `zle-line-init` widget and runs it. The last line is typed and left at the prompt. It turns on `interactive_comments` so the comment shows, and sets `EDITOR`; neither changes a color.
- The host is GNOME Terminal (Inglenook), so the background, prompt and command output are the terminal port's.
