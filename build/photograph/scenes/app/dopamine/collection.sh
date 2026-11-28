#!/usr/bin/env bash
# Dopamine's part of the app scene: the library from library.sh as its collection,
# with one track paused part way through, as if the reader had added the folder and
# played a song. Run it in the recipe's stage, after config.json is written.
# Usage: collection.sh <music dir>. Needs dopamine and sqlite3.
#
# Dopamine keeps its folders and its queue in its database, which it creates itself on
# first start. So this starts it once to make the database, adds the folder, starts it
# again to index the folder, then queues the tracks with one marked as playing. The shot
# starts it a third time, with automatic refresh off, so nothing moves. No colors.
set -euo pipefail
music=$1
data=$HOME/.config/Dopamine
db=$data/Dopamine.db
flags=(--no-sandbox --disable-gpu --password-store=basic)

# Start Dopamine in the background, wait until a query on its database answers
# what it should, then close it and wait for it to exit.
run_until() {
  local query=$1 want=$2 start=$SECONDS
  dopamine "${flags[@]}" >/tmp/dopamine-stage.log 2>&1 &
  local pid=$!
  until [ "$(sqlite3 "$db" "$query" 2>/dev/null || true)" = "$want" ]; do
    if (( SECONDS - start >= 120 )); then
      tail -n 20 /tmp/dopamine-stage.log >&2
      echo "collection.sh: no '$want' from '$query' after 120s." >&2
      kill "$pid" 2>/dev/null || true
      exit 1
    fi
    sleep 1
  done
  sleep 3
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

count=$(find "$music" -name '*.flac' | wc -l)

# 1. The database, made by Dopamine's own migrations (14 in Dopamine 3.0.12).
run_until "PRAGMA user_version;" 14

# 2. The folder, as Settings > Collection > Add folder stores it.
sqlite3 "$db" "INSERT INTO Folder (Path, SafePath, ShowInCollection) VALUES ('$music', lower('$music'), 1);"

# 3. Index it: Dopamine refreshes an outdated collection on start.
run_until "SELECT COUNT(*) FROM Track WHERE NeedsIndexing = 0;" "$count"

# 4. The queue: every track of the selected album, the second one paused at 1:10.
sqlite3 "$db" "DELETE FROM QueuedTrack;
  INSERT INTO QueuedTrack (Path, SafePath, IsPlaying, ProgressSeconds, OrderID)
  SELECT Path, SafePath, CASE WHEN TrackTitle = 'Morning Kettle' THEN 1 ELSE 0 END,
         CASE WHEN TrackTitle = 'Morning Kettle' THEN 70 ELSE 0 END, TrackNumber - 1
  FROM Track WHERE AlbumTitle = 'Window Light' ORDER BY TrackNumber;"
