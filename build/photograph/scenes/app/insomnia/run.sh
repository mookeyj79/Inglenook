#!/usr/bin/env bash
# Starts Insomnia for the app scene, after seed.sh: the window opens on the first-run
# Welcome page, and onboarded.mjs moves it on to the local Scratch Pad, as Continue does.
# The recipe's launch runs it: bash "$INGLENOOK_SCENE/insomnia/run.sh"
# api.github.com does not resolve for the app, so the toolbar's Star button never shows
# the live star count, which changes between takes. The button itself still shows.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
app=${INSOMNIA_BIN:-/opt/Insomnia/insomnia}
port=9222
"$app" --no-sandbox --disable-gpu --remote-debugging-port=$port --host-resolver-rules='MAP api.github.com ~NOTFOUND' &
ELECTRON_RUN_AS_NODE=1 "$app" "$here/onboarded.mjs" $port
wait
