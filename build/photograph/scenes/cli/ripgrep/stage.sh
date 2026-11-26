#!/usr/bin/env bash
# ripgrep's part of the CLI/TUI scene, run from its recipe's stage steps. ripgrep
# is not a full-screen app, so the scene types one search and leaves its output on
# screen. The search runs in an interactive bash, so it reads RIPGREP_CONFIG_PATH
# from ~/.bashrc the way the reader's shell does. --sort path keeps the output in
# the same order on every take; the cursor is hidden so nothing blinks.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cat > ~/.inglenook-rg <<SCENE
cp -r "$here/content/." .
search='rg --column --sort path moss'
printf '%s\n' "~/Inglenook on main \$ \$search"
\$search
printf '%s' "~/Inglenook on main \$ "
printf '\\e[?25l'
exec sleep infinity
SCENE
printf 'exec bash -ic %q\n' 'source ~/.inglenook-rg' > ~/.inglenook-cli
