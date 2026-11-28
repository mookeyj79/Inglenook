#!/usr/bin/env bash
# The qBittorrent scene: local torrents with no trackers, no network, no first-run dialogs.
# Changes no color: the theme was applied by the recipe's apply steps.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
python3 "$here/torrents.py" "$HOME/qbittorrent-scene"

ini="$HOME/.config/qBittorrent/qBittorrent.conf"
mkdir -p "$(dirname "$ini")"
touch "$ini"
# Settings under [Preferences] join the section apply wrote; the rest are sections of their own.
pref='General\\ExitConfirm=false\nGeneral\\SystrayEnabled=false\nGeneral\\NoSplashScreen=true\nAdvanced\\updateCheck=false\nAdvanced\\confirmTorrentDeletion=false'
if grep -q '^\[Preferences\]$' "$ini"; then sed -i "s/^\[Preferences\]$/[Preferences]\n$pref/" "$ini"
else printf '[Preferences]\n%b\n' "$pref" >> "$ini"; fi
cat >> "$ini" <<'EOF'

[LegalNotice]
Accepted=true

[BitTorrent]
Session\DHTEnabled=false
Session\LSDEnabled=false
Session\PeXEnabled=false
Session\Port=6881
Session\AnonymousModeEnabled=true

[Network]
PortForwardingEnabled=false
EOF
