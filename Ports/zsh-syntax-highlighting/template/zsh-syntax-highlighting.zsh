# {{meta.name}} for zsh-syntax-highlighting: {{variant.name}}.
# Source this from ~/.zshrc, after the plugin loads. Zsh only.
# Palette {{meta.version}}, {{meta.repository}}

typeset -gA ZSH_HIGHLIGHT_STYLES

# The main highlighter: commands and their words.
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg={{error}}'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg={{keyword}}'
ZSH_HIGHLIGHT_STYLES[precommand]='fg={{keyword}}'
ZSH_HIGHLIGHT_STYLES[alias]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[builtin]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[function]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[command]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[arg0]='fg={{info}}'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg={{reference}},underline'

# Separators, redirections and the delimiters around substitutions.
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg={{dim}}'
ZSH_HIGHLIGHT_STYLES[redirection]='fg={{dim}}'
ZSH_HIGHLIGHT_STYLES[command-substitution]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg={{dim}}'
ZSH_HIGHLIGHT_STYLES[process-substitution]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg={{dim}}'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg={{dim}}'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg={{error}}'

# Options, globs and file descriptors.
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[globbing]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[assign]='none'

# Quoted text, the escapes in it, and the parameters it expands.
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg={{success}}'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg={{success}}'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg={{success}}'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg={{error}}'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg={{error}}'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg={{error}}'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg={{literal}}'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg={{reference}}'

# Paths that exist, history expansion, comments.
ZSH_HIGHLIGHT_STYLES[path]='fg={{reference}},underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg={{reference}},underline'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg={{reference}}'
ZSH_HIGHLIGHT_STYLES[comment]='fg={{faint}}'

# The brackets highlighter, when it is turned on: one color per nesting level.
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg={{error}}'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg={{steel}}'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg={{heather}}'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg={{pine}}'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg={{dusk}}'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg={{rosewood}}'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bg={{accent|wash}}'
