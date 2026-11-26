# The second half of the startup file of zsh-autosuggestions' interactive zsh in the
# CLI/TUI scene (see stage.sh). The reader's ~/.zshrc has loaded by now. It runs two
# real git commands on the staged repo from run.sh, puts an older commit command in
# the history, then types the start of it on the last prompt, so the plugin draws
# the rest as its suggestion. The prompt is plain text, so the suggestion is the
# only color the port sets.
cd ~/Inglenook
PROMPT='~/Inglenook $ '
__scene_run() { print -r -- "$PROMPT$1"; print -s -- "$1"; eval "$1"; }
print -n '\e[H\e[2J'
print -s -- "git commit -am 'Darken moss in Day'"
__scene_run 'git status --short'
__scene_run 'git diff --stat'
__scene_type() {
    BUFFER='git c'
    CURSOR=$#BUFFER
    zle autosuggest-fetch
}
zle -N zle-line-init __scene_type
unset -f __scene_run
