# The second half of the startup file of zsh-history-substring-search's interactive zsh
# in the CLI/TUI scene (see stage.sh). The reader's ~/.zshrc has loaded by now. It runs
# two real git commands on the staged repo from run.sh and puts an older commit command
# in the history. Then it plays two searches the way a reader does, typing part of a
# command and pressing the key bound to history-substring-search-up: one that nothing
# matches, given up with Ctrl+C so it stays on screen, and one that finds the commit
# command. The prompt is plain text, so the two highlights are the only colors the
# port sets.
cd ~/Inglenook
PROMPT='~/Inglenook $ '
__scene_run() { print -r -- "$PROMPT$1"; print -s -- "$1"; eval "$1"; }
print -n '\e[H\e[2J'
print -s -- "git commit -am 'Darken moss in Day'"
__scene_run 'git status --short'
__scene_run 'git diff --stat'
unset -f __scene_run
typeset -gi __scene_search=0
__scene_type() {
    (( ++__scene_search ))
    if (( __scene_search == 1 )); then
        BUFFER='git stash pop'
        CURSOR=$#BUFFER
        zle history-substring-search-up
        zle -R
        zle send-break
    elif (( __scene_search == 2 )); then
        BUFFER='moss'
        CURSOR=$#BUFFER
        zle history-substring-search-up
    fi
}
zle -N zle-line-init __scene_type
