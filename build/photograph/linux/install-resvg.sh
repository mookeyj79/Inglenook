#!/usr/bin/env bash
# Installs the resvg release pinned in build/photograph/pins.json (resvg) into
# a bin folder, checked against its hash and its version. CI and the
# Photographer's base image both install it with this script.
#   install-resvg.sh <url> <sha256> <version> [bin folder, /usr/local/bin]
set -euo pipefail
url=$1 sha256=$2 version=$3 bin=${4:-/usr/local/bin}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/resvg.tar.gz" "$url"
echo "$sha256  $tmp/resvg.tar.gz" | sha256sum -c -
tar -xzf "$tmp/resvg.tar.gz" -C "$tmp" resvg
install -m 0755 "$tmp/resvg" "$bin/resvg"
have=$("$bin/resvg" --version)
if [ "$have" != "$version" ]; then
    echo "install-resvg.sh: $url is resvg $have, not the pinned $version." >&2
    exit 1
fi
