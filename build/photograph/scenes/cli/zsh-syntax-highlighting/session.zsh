# The rcfile of zsh-syntax-highlighting's interactive shell in the CLI/TUI scene
# (see stage.sh). It loads ~/.zshrc, then types each staged line into the real line
# editor and runs it, so the plugin highlights every line as a user would see it.
# The last line is typed and left on the prompt, not run. The prompt is plain
# text, so every color on the command lines is the plugin's.
source ~/.zshrc
setopt interactive_comments
export EDITOR=nano
PROMPT='%~ %# '
__scene_lines=(
  'cd ~/Inglenook && ls palette/*.json'
  "grep -n '\"l\"' palette/palette.json  # the moss lightness"
  'if [[ -n $EDITOR ]]; then echo "editor: $EDITOR"; fi'
  'for f in palette/*.json; do wc -l < $f; done'
  'echo "branch: \"$(git branch --show-current)\""'
  'pallete --check > /dev/null'
)
__scene_last='git commit -m "Darken moss in Day" palette/palette.json'
__scene_play() {
  if (( $#__scene_lines )); then
    BUFFER=$__scene_lines[1] CURSOR=${#__scene_lines[1]}
    shift __scene_lines
    zle .redisplay
    zle .accept-line
  elif [[ -n $__scene_last ]]; then
    BUFFER=$__scene_last CURSOR=${#__scene_last}
    __scene_last=
  fi
}
zle -N zle-line-init __scene_play
printf '\e[H\e[2J'
