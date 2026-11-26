# shellcheck shell=bash
# The rcfile of the prompt scene's interactive shell (see run.sh). It loads ~/.bashrc,
# then plays each staged command the way bash does: run PROMPT_COMMAND with the last
# command's exit status, print PS1, the command, then PS0 and the staged output. Any
# prompt that hooks into bash this way is drawn for real. Colors in the staged output
# are ANSI slots only, so the ports under test decide every color.
# shellcheck source=/dev/null
source ~/.bashrc
: "${COLUMNS:=$(tput cols)}"

__scene_status() { return "$1"; }
__scene_expand() { local s=$1; s=${s//$'\001'/}; printf '%s' "${s//$'\002'/}"; }
__scene_command() {  # exit status of the command before, the command line
    local pc
    for pc in "${PROMPT_COMMAND[@]}"; do __scene_status "$1"; eval "$pc"; done
    __scene_expand "${PS1@P}"
    printf '%s\n' "$2"
    __scene_expand "${PS0@P}"
}

e=$'\e'
r="$e[0m" b="$e[1m" red="$e[31m" green="$e[32m" yellow="$e[33m" blue="$e[34m" cyan="$e[36m" muted="$e[90m"

printf '\e[H\e[2J'
__scene_command 0 'git log --oneline -3'
printf '%s\n' "${yellow}b60388e${r} ${cyan}(${b}HEAD -> ${green}main${r}${cyan})${r} Add Pin to the glossary ${muted}2 days ago${r}"
printf '%s\n' "${yellow}f4960df${r} Add the screenshot terms to the glossary ${muted}3 days ago${r}"
printf '%s\n' "${yellow}1e7c435${r} Drop the Layout section from the VS Code install guide ${muted}4 days ago${r}"
__scene_command 0 'git diff palette/palette.json'
printf '%s\n' "${b}diff --git a/palette/palette.json b/palette/palette.json${r}"
printf '%s\n' "${cyan}@@ -85,7 +85,7 @@${r}"
printf '%s\n' '         "moss": {'
printf '%s\n' "${red}-          \"l\": 0.52,${r}"
printf '%s\n' "${green}+          \"l\": 0.5,${r}"
__scene_command 0 'pwsh build/check.ps1'
printf '%s\n' "Palette      ${green}ok${r}"
printf '%s\n' "Contrast     ${green}ok${r}"
printf '%s\n' "Drift        ${red}${b}FAIL${r}"
printf '%s\n' "${red}FAIL: Drift: Ports/gnome-terminal/dist/day/install.sh is out of date. Run build/build.ps1.${r}"
__scene_command 1 'pwsh build/build.ps1'
printf '%s\n' "${blue}Building 9 ports for palette 0.1.1${r}"
printf '%s\n' "gnome-terminal     ${yellow}changed${r}"
printf '%s\n' "windows-terminal   ${muted}version stamp only${r}"
unset e r b red green yellow blue cyan muted
unset -f __scene_status __scene_expand __scene_command
# The last command succeeded: the shell now draws its own prompt and waits.
true
