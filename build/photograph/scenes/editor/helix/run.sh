#!/usr/bin/env bash
# Helix's part of the editor scene, started by ../run.sh in the host terminal after
# stage.sh. Opens build/lib/Contrast.psm1 on the line the selection starts at, and lets
# keys.py press x twice to select that line and the next, as a reader would. The gutter
# shows the working file's changes against the repo's last commit; diagnostic-server.py
# reports the error. Fixed content, never live, and no colors: the port's theme decides
# every color.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd ~/Inglenook
file=build/lib/Contrast.psm1
# The selection is the line that starts '$rgb = ' and the next, on lines the change leaves alone.
line=$(grep -n -F -m1 '$rgb = ' "$file" | cut -d: -f1)
[ -n "$line" ] || { echo "helix-scene: no selection line in $file" >&2; exec sleep infinity; }
exec python3 -I "$here/keys.py" xx hx "$file:$line"
