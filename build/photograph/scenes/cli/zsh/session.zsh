# The startup file of the Zsh line editor's scene (see stage.sh). Completion is set
# up the way many readers have it (compinit and a selection menu), then
# ~/.zshrc loads, and the theme with it. The staged repo from run.sh grows a few
# files of each kind. Four command lines follow, played with the line editor's own
# widgets in place of keys: selected text, then a paste, then special characters,
# each left on screen with Ctrl+C (send-break), and last a live selection menu after
# "ls ", moved down to the first folder, whose slash is a completion suffix. The prompt is ANSI blue, so
# every other color on screen is the theme's.
autoload -Uz compinit && compinit -u -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
source ~/.zshrc

cd ~/Inglenook
mkdir -p Ports build docs wallpapers
touch AGENTS.md LICENSE PHILOSOPHY.md README.md inglenook-night.tar.gz palette.json.bak preview.png
print '#!/bin/sh' > install.sh && chmod 755 install.sh
ln -sf AGENTS.md CLAUDE.md
PS1='%F{blue}%~%f %# '

typeset -gi __scene_step=0
# A paste, flagged as one so its highlight stays when the line is left.
__scene_paste() { zle bracketed-paste; zle -f yank; zle -R; zle send-break }
zle -N __scene_paste
bindkey '^X^P' __scene_paste
__scene_line() {
  (( ++__scene_step ))
  case $__scene_step in
    1) BUFFER='git commit -am "Darken day moss"'; MARK=16; CURSOR=$(( ${#BUFFER} - 1 )); REGION_ACTIVE=1
       zle send-break ;;
    2) zle -U $'\C-x\C-psed -i s/0.52/0.5/ palette/palette.json\e[201~' ;;
    3) BUFFER=$'printf \'\e[1mok\e[0m\\n\''; CURSOR=${#BUFFER}
       zle send-break ;;
    4) BUFFER='ls '; CURSOR=3; zle -U $'\t\t\t\t\t\t' ;;
  esac
}
zle -N zle-line-init __scene_line
print -n '\e[H\e[2J'
