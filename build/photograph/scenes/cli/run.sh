#!/usr/bin/env bash
# The CLI/TUI scene: a full-screen terminal app at work on the Inglenook repo. run.sh
# stages a small Inglenook repo on main with palette.json changed and not committed,
# then starts the app in it. The port's stage steps write the command that starts
# the app to ~/.inglenook-cli, and stage the app's own content (a saved session that
# changes palette.json) from this folder. Never a live model or network call.
# Runs outside tmux with 24-bit color, as a user's terminal would.
# Launch it with: bash "$INGLENOOK_SCENE/run.sh"
set -euo pipefail

repo=~/Inglenook
rm -rf "$repo" && mkdir -p "$repo/palette"
cd "$repo"
export GIT_AUTHOR_NAME=Inglenook GIT_AUTHOR_EMAIL=inglenook@example.invalid GIT_AUTHOR_DATE='2026-11-24T12:00:00Z'
export GIT_COMMITTER_NAME=Inglenook GIT_COMMITTER_EMAIL=inglenook@example.invalid GIT_COMMITTER_DATE='2026-11-24T12:00:00Z'
git init -q -b main
printf '{\n  "moss": {\n    "l": 0.52\n  }\n}\n' > palette/palette.json
git add -A && git commit -q -m 'Add Pin to the glossary'
sed -i 's/0.52/0.5/' palette/palette.json
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE

[ -s ~/.inglenook-cli ] || { echo 'photograph: the port''s stage steps did not write ~/.inglenook-cli' >&2; exec sleep infinity; }
unset TMUX
export COLORTERM=truecolor
exec bash ~/.inglenook-cli
