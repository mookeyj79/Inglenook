#!/usr/bin/env bash
# The terminal scene: a staged slice of working on the Inglenook repo. Fixed text, never
# live output, so every take prints the same. Colors are ANSI slots only, so the port
# under test decides every color. It shows the six ANSI colors, text and bright black
# (muted), and leaves the cursor (accent) on the last prompt. A terminal has no orange
# slot and no wash: ports list those as skipped in MAPPING.md.
# Launch it with: bash "$INGLENOOK_SCENE/run.sh"
e=$'\e'
r="$e[0m" b="$e[1m" red="$e[31m" green="$e[32m" yellow="$e[33m" blue="$e[34m" magenta="$e[35m" cyan="$e[36m" muted="$e[90m"
prompt() { printf '%s~/Inglenook%s on %smain%s $ %s\n' "$blue" "$r" "$magenta" "$r" "$1"; }

printf '\e[H\e[2J'
prompt 'git log --oneline -3'
printf '%s\n' "${yellow}b60388e${r} ${cyan}(${b}HEAD -> ${green}main${r}${cyan})${r} Add Pin to the glossary ${muted}2 days ago${r}"
printf '%s\n' "${yellow}f4960df${r} Add the screenshot terms to the glossary ${muted}3 days ago${r}"
printf '%s\n' "${yellow}1e7c435${r} Drop the Layout section from the VS Code install guide ${muted}4 days ago${r}"
prompt 'git diff palette/palette.json'
printf '%s\n' "${b}diff --git a/palette/palette.json b/palette/palette.json${r}"
printf '%s\n' "${cyan}@@ -2,7 +2,7 @@${r}"
printf '%s\n' '   "meta": {'
printf '%s\n' "${red}-    \"version\": \"0.1.0\",${r}"
printf '%s\n' "${green}+    \"version\": \"0.1.1\",${r}"
printf '%s\n' "${cyan}@@ -85,7 +85,7 @@${r}"
printf '%s\n' '         "moss": {'
printf '%s\n' "${red}-          \"l\": 0.52,${r}"
printf '%s\n' "${green}+          \"l\": 0.5,${r}"
prompt 'pwsh build/check.ps1'
printf '%s\n' "Palette      ${green}ok${r}"
printf '%s\n' "Contrast     ${green}ok${r}"
printf '%s\n' "Drift        ${red}${b}FAIL${r}"
printf '%s\n' "${red}FAIL: Drift: Ports/gnome-terminal/dist/day/install.sh is out of date. Run build/build.ps1.${r}"
prompt 'pwsh build/build.ps1'
printf '%s\n' "gnome-terminal     ${yellow}changed${r}"
printf '%s\n' "preview            ${yellow}changed${r}"
printf '%s\n' "windows-terminal   ${muted}version stamp only${r}"
printf '%s\n' "${yellow}warning: screenshots of gnome-terminal and preview are now stale${r}"
printf '%s~/Inglenook%s on %smain%s $ ' "$blue" "$r" "$magenta" "$r"
exec sleep infinity
