#!/usr/bin/env bash
# nano's part of the CLI/TUI scene, run from its recipe's stage steps. It writes the
# command run.sh starts: put a short script in the staged repo and open it in nano
# with line numbers, the scroll indicator and a guide stripe. drive.py then sets the
# mark (^6) and moves down three lines (^N), so the shot shows a selection and the
# status bar's "Mark Set". Fixed content and no colors: the port under test decides
# every interface color. The syntax colors are nano's own.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cat > ~/.inglenook-cli <<SH
set -euo pipefail
cd ~/Inglenook
mkdir -p build
cp '$here/rebuild.sh' build/rebuild.sh
exec python3 '$here/drive.py' "b'\\x1e\\x0e\\x0e\\x0e'" nano --linenumbers --indicator --guidestripe=80 +9 build/rebuild.sh
SH
