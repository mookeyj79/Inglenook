#!/usr/bin/env bash
# Starts the File Browser that stage.sh set up, waits for it, then opens it in the
# web scene's browser. Run it as the recipe's one launch step.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
home=$HOME/filebrowser
filebrowser -d "$home/filebrowser.db" -r "$home/files" -a 127.0.0.1 -p 8080 >"$home/server.log" 2>&1 &
for _ in $(seq 1 100); do
  curl -fs -o /dev/null http://127.0.0.1:8080/health && break
  sleep 0.2
done
exec bash "$here/../browser.sh" "http://127.0.0.1:8080/files/"
