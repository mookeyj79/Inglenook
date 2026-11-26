# Inglenook for zsh-history-substring-search: Inglenook Night.
# Source this from ~/.zshrc after the plugin loads. Zsh only.

# The part of a found command that matches what you typed: a find match.
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#d1c9bc,bg=#463624,bold'

# What you typed, when no command in the history matches it: a failed search.
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=#d1c9bc,bg=#412f2c,bold'
