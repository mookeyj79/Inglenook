# Inglenook for zsh-syntax-highlighting: Inglenook Night.
# Source this from ~/.zshrc, after the plugin loads. Zsh only.
# Palette 0.1.0, https://github.com/mookeyj79/Inglenook

typeset -gA ZSH_HIGHLIGHT_STYLES

# The main highlighter: commands and their words.
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#d9897e'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cb9cc6'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#cb9cc6'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[function]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[command]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#72bdbd,underline'

# Separators, redirections and the delimiters around substitutions.
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#b1aa9e'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#b1aa9e'
ZSH_HIGHLIGHT_STYLES[command-substitution]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#b1aa9e'
ZSH_HIGHLIGHT_STYLES[process-substitution]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#b1aa9e'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#b1aa9e'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#d9897e'

# Options, globs and file descriptors.
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[assign]='none'

# Quoted text, the escapes in it, and the parameters it expands.
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#91bc88'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#91bc88'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#91bc88'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#d9897e'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#d9897e'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#d9897e'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#da9f7c'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#72bdbd'

# Paths that exist, history expansion, comments.
ZSH_HIGHLIGHT_STYLES[path]='fg=#72bdbd,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#72bdbd,underline'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#72bdbd'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#8f887f'

# The brackets highlighter, when it is turned on: one color per nesting level.
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#d9897e'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#89b3d8'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#cb9cc6'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#72bdbd'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#a5a5d9'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#d4a2aa'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bg=#463624'
