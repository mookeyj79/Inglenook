#!/usr/bin/env bash
# Homepage's part of the web scene: a small dashboard of made-up services and bookmarks.
# Nothing in it calls the network: every link, site monitor and widget points at this
# machine (Homepage itself on port 3000, a closed port for one service that is down, and
# a fixed JSON file on port 8130 for the widget). The settings are layout, status style
# and font only, never a color: the port's custom.css decides every one.
# Usage: stage.sh <config dir>, after the port's install steps put custom.css there and
# added its theme line to settings.yaml. Then serve.sh starts the servers.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dir=${1:?usage: stage.sh <config dir>}
mkdir -p "$dir"
cat "$here/config/settings.yaml" >> "$dir/settings.yaml"
cp "$here/config/services.yaml" "$here/config/bookmarks.yaml" "$here/config/widgets.yaml" "$dir/"
# The skeleton files Homepage would otherwise write on its first start, left empty.
for f in docker.yaml kubernetes.yaml proxmox.yaml custom.js; do : > "$dir/$f"; done
mkdir -p ~/homepage-data
cp "$here/shelves.json" ~/homepage-data/
