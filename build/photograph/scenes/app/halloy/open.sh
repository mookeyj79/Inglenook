#!/usr/bin/env bash
# Opens #inglenook in Halloy's empty pane, as a reader does: one click on it in the
# sidebar once the channels have joined, then the pointer back to the corner so no
# row shows a hover. Halloy has no setting to open a channel at launch.
# Run as a launch step after launch.sh.
set -euo pipefail
wid=
until [ -n "$wid" ]; do sleep 0.5; wid=$(xdotool search --onlyvisible --classname halloy 2>/dev/null | tail -1 || true); done
sleep 4
# Stop Halloy's clock first (launch.sh loaded libfaketime). The click then focuses
# the message box at a moment that never moves on, so its cursor shows and never
# blinks. libfaketime reads the file again within a second.
echo '@2026-06-01 09:41:00 x0.000001' > /tmp/inglenook-faketime
sleep 2
# #inglenook is the second channel in the sidebar (they sort by name).
xdotool mousemove --window "$wid" 80 78 click 1
sleep 0.5
xdotool mousemove 0 0
