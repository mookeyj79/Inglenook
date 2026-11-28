# Inglenook for zsh-syntax-highlighting: Inglenook Day.
# Source this from ~/.zshrc, after the plugin loads. Zsh only.
# Palette 1.0.0, https://github.com/mookeyj79/Inglenook

typeset -gA ZSH_HIGHLIGHT_STYLES

# The main highlighter: commands and their words.
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#a04037'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#844b80'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#844b80'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[function]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[command]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#017272,underline'

# Separators, redirections and the delimiters around substitutions.
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#49545d'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#49545d'
ZSH_HIGHLIGHT_STYLES[command-substitution]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#49545d'
ZSH_HIGHLIGHT_STYLES[process-substitution]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#49545d'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#49545d'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#a04037'

# Options, globs and file descriptors.
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[assign]='none'

# Quoted text, the escapes in it, and the parameters it expands.
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#407135'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#407135'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#407135'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#a04037'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#a04037'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#a04037'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#915023'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#017272'

# Paths that exist, history expansion, comments.
ZSH_HIGHLIGHT_STYLES[path]='fg=#017272,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#017272,underline'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#017272'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#657178'

# The brackets highlighter, when it is turned on: one color per nesting level.
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#a04037'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#326893'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#844b80'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#017272'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#5e5a9a'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#905560'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bg=#e3dbc8'
