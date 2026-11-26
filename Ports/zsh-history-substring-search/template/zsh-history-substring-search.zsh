# {{meta.name}} for zsh-history-substring-search: {{variant.name}}.
# Source this from ~/.zshrc after the plugin loads. Zsh only.

# The part of a found command that matches what you typed: the match at the cursor.
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg={{on_accent}},bg={{accent}},bold'

# What you typed, when no command in the history matches it: a failed search.
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg={{text}},bg={{error|wash}},bold'
