#!/usr/bin/env bash
# The Bash line editor's part of the CLI/TUI scene, run from its recipe's stage steps.
# The command run.sh starts is an interactive bash whose rcfile is session.sh, run by
# drive.py, which types the keys a reader presses. Each command line but the last is
# left on screen with Ctrl+C, so Readline's highlight stays as drawn. Ctrl+Space is
# typed apart from the text before it: Readline takes text typed ahead as a string,
# and the byte Ctrl+Space sends would end it.
#   a selection: Ctrl+Space (set the mark), Alt+B three times, Ctrl+B, Ctrl+X Ctrl+X
#   a paste, sent as a terminal's bracketed paste
#   a history search: Ctrl+R and "moss"
#   the completion list after "ls ", then a live one after "ls p" with its shared prefix
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
keys="[b'git commit -am \"Darken day moss\"', b'\\x00\\x1bb\\x1bb\\x1bb\\x02\\x18\\x18', b'\\x03',"
keys+=" b'\\x1b[200~sed -i s/0.52/0.5/ palette/palette.json\\x1b[201~', b'\\x03',"
keys+=" b'\\x12moss', b'\\x03', b'ls \\t\\t', b'\\x03', b'ls p\\t\\t']"
printf 'exec python3 %q %q bash --rcfile %q -i\n' "$here/drive.py" "$keys" "$here/session.sh" > ~/.inglenook-cli
