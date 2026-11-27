#!/usr/bin/env bash
# Starts qBittorrent on a fixed clock, adds the scene's torrents, and gives the window a fixed size.
# Two torrents run (one seeding, one part done), two are added stopped (one done, one empty),
# and a magnet link with no trackers waits for its metadata.
set -uo pipefail
d="$HOME/qbittorrent-scene"
t="$d/torrents"
export TZ=UTC
qbt() { faketime -f '@2026-06-01 09:00:00' qbittorrent "$@"; }

qbt >/tmp/qbittorrent.log 2>&1 &
until wid=$(xdotool search --onlyvisible --class qBittorrent 2>/dev/null | tail -1) && [ -n "$wid" ]; do sleep 0.2; done
sleep 2
magnet="magnet:?xt=urn:btih:$(printf 'Wood Stove Manual' | sha1sum | cut -c1-40)&dn=Wood%20Stove%20Manual"
qbt --skip-dialog=true --save-path="$d/data" "$t/Fireside Reading List.torrent" "$t/Cabin Field Recordings.torrent" "$magnet"
sleep 1
qbt --skip-dialog=true --add-stopped=true --seed-mode --save-path="$d/data" "$t/Pine Forest Photos.torrent"
sleep 1
qbt --skip-dialog=true --add-stopped=true --save-path="$d/data" "$t/Library Catalog Scans.torrent"
xdotool windowsize "$wid" 1240 720
xdotool windowmove "$wid" 180 140
wait
