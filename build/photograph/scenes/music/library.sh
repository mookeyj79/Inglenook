#!/usr/bin/env bash
# The music scene: a small library of silent tracks, for a music player to show.
# Usage: library.sh <dir>. Needs ffmpeg (the recipe installs it).
#
# Every track is generated silence in FLAC with plain tags: made up artists, albums
# and titles, so there is nothing to license. Two artists, three albums, eleven tracks,
# with lengths that differ so the duration column reads like a real collection. No
# cover art, so a player shows its own placeholder. Fixed content and times, never live.
set -euo pipefail
dir=$1
mkdir -p "$dir"

# artist|album|year|genre|track number|title|seconds
tracks='The Hearth Trio|Evening Sessions|2019|Jazz|1|Kindling|212
The Hearth Trio|Evening Sessions|2019|Jazz|2|Slow Burn|287
The Hearth Trio|Evening Sessions|2019|Jazz|3|Bellows|194
The Hearth Trio|Evening Sessions|2019|Jazz|4|Last Log|326
Wren Calloway|Window Light|2021|Folk|1|Sill and Fern|203
Wren Calloway|Window Light|2021|Folk|2|Morning Kettle|178
Wren Calloway|Window Light|2021|Folk|3|Cabin Rain|241
Wren Calloway|Window Light|2021|Folk|4|Woodsmoke|265
Wren Calloway|Low Fire|2023|Folk|1|Banked Coals|232
Wren Calloway|Low Fire|2023|Folk|2|Reading Lamp|199
Wren Calloway|Low Fire|2023|Folk|3|Brass Handle|254'

while IFS='|' read -r artist album year genre n title secs; do
  out="$dir/$artist/$album/$(printf '%02d' "$n") $title.flac"
  mkdir -p "$(dirname "$out")"
  ffmpeg -nostdin -loglevel error -f lavfi -i "anullsrc=r=44100:cl=stereo" -t "$secs" -c:a flac \
    -metadata artist="$artist" -metadata album_artist="$artist" -metadata album="$album" \
    -metadata date="$year" -metadata genre="$genre" -metadata track="$n" -metadata title="$title" \
    -y "$out"
done <<< "$tracks"
find "$dir" -exec touch -d '2026-06-01 09:00' {} +
