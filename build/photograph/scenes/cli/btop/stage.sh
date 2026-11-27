#!/usr/bin/env bash
# btop's part of the CLI/TUI scene, run from its recipe's stage steps. btop watches a
# small fixed machine (machine.py) instead of the container: proot lays its /proc and
# /sys over the real ones, loadavg.c gives its load average, libfaketime sets the clock,
# taskset holds btop to one real CPU so the machine's four decide the count, and
# btop.conf hides what the machine cannot fix (disks, battery). After the last sample btop's screen holds still.
# The settings here are layout and update rate only, never a color. One key press
# selects the top process.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.config/btop
cat >> ~/.config/btop/btop.conf <<'CONF'
update_ms = 150
clock_format = "%H:%M"
show_disks = False
show_battery = False
net_iface = "lo"
proc_sorting = "cpu lazy"
CONF

machine="$HOME/btop-machine"
mkdir -p "$machine"
tcc -shared -o "$machine/loadavg.so" "$here/loadavg.c"
cat > ~/.inglenook-cli <<SH
python3 -I '$here/machine.py' '$machine' &
until [ -e '$machine/ready' ]; do sleep 0.05; done
# Select the top process, as a reader would with the Down key, long before the last sample.
(sleep 4; xdotool key Down) &
exec proot -b '$machine/proc:/proc' -b '$machine/sys:/sys' -b '$machine/passwd:/etc/passwd' taskset -c 0 \\
  env LD_PRELOAD='$machine/loadavg.so:/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1' \\
  FAKETIME='@2026-11-24 12:00:00' FAKETIME_DONT_FAKE_MONOTONIC=1 btop 2>/dev/null
SH
