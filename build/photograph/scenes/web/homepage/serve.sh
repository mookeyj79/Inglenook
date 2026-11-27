#!/usr/bin/env bash
# Starts the Homepage scene's servers and waits until the dashboard answers:
# Homepage (installed in /opt/homepage by the recipe) on 127.0.0.1:3000, reading
# <config dir>, and the widget's fixed JSON on 127.0.0.1:8130.
# Usage: serve.sh <config dir>
set -euo pipefail
dir=${1:?usage: serve.sh <config dir>}
(cd ~/homepage-data && nohup python3 -m http.server 8130 --bind 127.0.0.1 >/dev/null 2>&1 &)
(cd /opt/homepage && HOMEPAGE_CONFIG_DIR="$dir" NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 \
  HOSTNAME=127.0.0.1 PORT=3000 nohup node server.js >/dev/null 2>&1 &)
for _ in $(seq 1 120); do
  if curl -fs -o /dev/null http://127.0.0.1:3000/ && curl -fs -o /dev/null http://127.0.0.1:8130/shelves.json; then exit 0; fi
  sleep 0.5
done
echo "Homepage did not start on 127.0.0.1:3000" >&2
exit 1
