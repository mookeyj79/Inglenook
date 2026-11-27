#!/usr/bin/env bash
# Docker's scene, started by the CLI scene's run.sh: a staged prompt, then the
# recorded build (see stage.sh), drawn by the terminal as Docker drew it.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
e=$'\e'
r="$e[0m" blue="$e[34m" magenta="$e[35m"
prompt() { printf '%s~/Inglenook%s on %smain%s $ %s' "$blue" "$r" "$magenta" "$r" "$1"; }
printf '\e[H\e[2J'
prompt 'docker build --no-cache --progress=tty .'
printf '\n'
cat "$here/build.tty"
prompt ''
exec sleep infinity
