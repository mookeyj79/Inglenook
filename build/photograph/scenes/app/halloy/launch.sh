#!/usr/bin/env bash
# Starts the IRC server (irc.sh), then Halloy with libfaketime loaded but the clock running
# as normal. open.sh stops Halloy's clock once the channel is open, so the cursor
# in the message box stops blinking and the screen can settle. The messages carry
# their own fixed times, so nothing on screen reads this clock.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
echo '+0' > /tmp/inglenook-faketime
exec bash "$here/irc.sh" env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1 \
  FAKETIME_TIMESTAMP_FILE=/tmp/inglenook-faketime FAKETIME_CACHE_DURATION=1 halloy
