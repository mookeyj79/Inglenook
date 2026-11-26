#!/usr/bin/env bash
# The editor scene in a terminal: for an editor that runs inside a terminal port, its host.
# The host launches it with: bash "$INGLENOOK_SCENE/run.sh". The editor's stage steps
# build ~/Inglenook with repo.sh and write the command that starts the editor there to
# ~/.inglenook-editor. Runs with 24-bit color, as a user's terminal would.
set -euo pipefail
[ -s ~/.inglenook-editor ] || { echo 'photograph: the port''s stage steps did not write ~/.inglenook-editor' >&2; exec sleep infinity; }
cd ~/Inglenook
export COLORTERM=truecolor
exec bash ~/.inglenook-editor
