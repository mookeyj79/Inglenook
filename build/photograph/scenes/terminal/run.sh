#!/usr/bin/env bash
# The terminal scene: a staged slice of working on the Inglenook repo. Fixed text, never
# live output, so every take prints the same. Colors are ANSI slots only, so the port
# under test decides every color. It shows the six ANSI colors, text and bright black
# (muted), and leaves the cursor (accent) on the last prompt. A terminal has no orange
# slot and no wash: ports list those as skipped in MAPPING.md. The lines are in
# transcript.txt, which run.ps1 reads too.
# Launch it with: bash "$INGLENOOK_SCENE/run.sh"
e=$'\e'
declare -A slot=([r]="$e[0m" [b]="$e[1m" [red]="$e[31m" [green]="$e[32m" [yellow]="$e[33m" [blue]="$e[34m" [magenta]="$e[35m" [cyan]="$e[36m" [muted]="$e[90m")
prompt() { printf '%s~/Inglenook%s on %smain%s $ %s' "${slot[blue]}" "${slot[r]}" "${slot[magenta]}" "${slot[r]}" "$1"; }

printf '\e[H\e[2J'
while IFS= read -r line; do
    case $line in
        '#'*) continue ;;
        '$ '*) prompt "${line#\$ }"; printf '\n' ;;
        *) for name in "${!slot[@]}"; do line=${line//\{$name\}/${slot[$name]}}; done; printf '%s\n' "$line" ;;
    esac
done < "$(dirname "$0")/transcript.txt"
prompt ''
exec sleep infinity
