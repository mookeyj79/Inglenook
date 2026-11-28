#!/usr/bin/env bash
# The web port's part of the web scene: a demo article on a small site, a slice of
# working on the Inglenook repo. Its own stylesheet (site.css) reads only the port's
# custom properties, the way the port README shows: map them once, pick the set with
# data-theme. No color is written in the scene: the port under test decides every one.
# Usage: stage.sh <site dir>, after the port's files are in <site dir>/css as
# inglenook-day.css and inglenook-night.css. Open <site dir>/index.html#<variant>.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dir=${1:?usage: stage.sh <site dir>}
mkdir -p "$dir/css"
cp "$here/index.html" "$dir/index.html"
cp "$here/site.css" "$dir/css/site.css"
