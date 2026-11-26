#!/usr/bin/env bash
# GitHub CLI's scene, started by the CLI scene's run.sh from an interactive bash that
# loaded the theme. Starts the stand-in API (server.py), then runs gh repo view under
# a staged prompt, so the README is drawn by gh itself.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
sock=~/.inglenook-gh/api.sock
rm -f "$sock"
python3 -I "$here/server.py" "$sock" "$here/README.md" &
for _ in $(seq 100); do [ -S "$sock" ] && break; sleep 0.1; done
export GH_TOKEN=inglenook-scene GH_NO_UPDATE_NOTIFIER=1 GH_TELEMETRY=0 GH_PAGER=cat GH_PROMPT_DISABLED=1

e=$'\e'
r="$e[0m" blue="$e[34m"
printf '\e[H\e[2J'
printf '%s~/Inglenook%s $ gh repo view inglenook/inglenook\n' "$blue" "$r"
gh repo view inglenook/inglenook
exec sleep infinity
