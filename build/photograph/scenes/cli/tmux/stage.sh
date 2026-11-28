#!/usr/bin/env bash
# tmux's part of the CLI/TUI scene, run from its recipe's stage steps. It writes the
# command run.sh starts: a tmux session on the staged repo with three windows. The
# first is split in two: the left pane shows a short script and sits in copy mode
# after a search for "port", so every match and the current one show; the right pane
# shows the palette diff and sits in copy mode with two lines selected. The left pane
# is active. The third window prints once with activity monitoring on, so the window
# list flags it. The status line's clock is fixed text. Layout and content only,
# never a color: the port under test decides every tmux color.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cat > ~/.inglenook-cli <<SH
set -euo pipefail
cd ~/Inglenook
mkdir -p build
cp '$here/rebuild.sh' build/rebuild.sh
cols=\$(tput cols) lines=\$(tput lines)
tmux new-session -d -s repo -n build -x "\$cols" -y "\$((lines - 1))" 'sleep 1; cat build/rebuild.sh; exec cat'
tmux set -g status-right '"inglenook" 12:00 24-Nov-26'
tmux split-window -h -t repo:build 'sleep 1; git -c color.ui=always diff; exec cat'
tmux new-window -d -t repo:1 -n notes 'exec cat'
tmux new-window -d -t repo:2 -n watch 'sleep 2; echo rebuilt; exec cat'
tmux set -w -t repo:watch monitor-activity on
sleep 3
tmux copy-mode -t repo:build.1
tmux send -t repo:build.1 -X top-line
for _ in 1 2 3 4 5 6 7 8; do tmux send -t repo:build.1 -X cursor-down; done
tmux send -t repo:build.1 -X begin-selection
tmux send -t repo:build.1 -X cursor-down
tmux send -t repo:build.1 -X end-of-line
tmux select-pane -t repo:build.0
tmux copy-mode -t repo:build.0
tmux send -t repo:build.0 -X search-backward port
exec tmux attach -t repo
SH
