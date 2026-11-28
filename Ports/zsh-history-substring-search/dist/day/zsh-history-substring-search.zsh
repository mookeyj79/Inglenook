# Inglenook for zsh-history-substring-search: Inglenook Day.
# Source this from ~/.zshrc after the plugin loads. Zsh only.
# Palette 0.1.1, https://github.com/mookeyj79/Inglenook

# The part of a found command that matches what you typed: the match at the cursor.
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#f9fbf8,bg=#9b5a00,bold'

# What you typed, when no command in the history matches it: a failed search.
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=#2d373f,bg=#e4d6d1,bold'
