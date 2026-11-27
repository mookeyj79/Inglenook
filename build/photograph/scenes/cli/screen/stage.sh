#!/usr/bin/env bash
# GNU Screen's part of the CLI/TUI scene, run from its recipe's stage steps. It writes
# the command run.sh starts: a Screen session with three windows in the staged repo,
# split in two, the shell on top and git diff below. drive.py then types C-a " to open
# the window list in the top region and C-a Tab to move the focus to the bottom one,
# so the shot shows the status line with its current window, both kinds of region
# caption (focused and not) and the window list's cursor line. Fixed content and no
# colors: the port under test, read from ~/.screenrc, decides every Screen color. The
# diff colors are git's, in the terminal's slots.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cat > ~/.inglenook-cli <<SH
set -euo pipefail
cd ~/Inglenook
exec python3 '$here/../nano/drive.py' "b'\\x01\"\\x01\\t'" screen -S inglenook -c '$here/scene.screenrc'
SH
