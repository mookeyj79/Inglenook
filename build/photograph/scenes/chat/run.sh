#!/usr/bin/env bash
# The chat scene: a chat client connected to irc.py, a scripted IRC server on
# 127.0.0.1:6667 that sends a fixed conversation with fixed times. No network.
# The port's stage steps point the client at that server and turn off its update
# checks. Launch it with: bash "$INGLENOOK_SCENE/run.sh" <client command...>
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
python3 "$here/irc.py" >/tmp/irc.log 2>&1 &
until (exec 3<>/dev/tcp/127.0.0.1/6667) 2>/dev/null; do sleep 0.1; done
exec "$@"
