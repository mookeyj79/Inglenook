#!/usr/bin/env bash
# The prompt scene: the terminal scene's staged slice of working on the Inglenook repo,
# with the shell prompt under test drawn between the staged lines. The prompt is real:
# whatever the port's apply steps put in ~/.bashrc draws it, in a real git repo with a
# changed file. The rest is fixed text, never live output, so every take prints the same.
# Launch it with: bash "$INGLENOOK_SCENE/run.sh"
set -euo pipefail
scene=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# A small Inglenook repo on main, with palette.json changed and not committed.
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

# An interactive shell, so ~/.bashrc sets the prompt up the way it does for a user.
# session.sh prints the staged lines, then the shell draws its own last prompt.
exec bash --rcfile "$scene/session.sh" -i
