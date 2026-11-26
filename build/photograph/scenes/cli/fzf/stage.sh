#!/usr/bin/env bash
# fzf's part of the CLI/TUI scene, run from its recipe's stage steps. fzf picks from a
# fixed list of Inglenook files with a query typed, two picks marked and a preview of
# the file under the pointer. The list is fixed text, so every take shows the same.
# An interactive shell runs it, so the colors come from ~/.bashrc as they do for a user.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cp "$here/files.txt" ~/.inglenook-fzf-files
cat > ~/.inglenook-cli <<'SH'
exec bash -ic 'fzf --multi --layout=reverse --border --border-label=" Inglenook " --query=pa --preview="cat {}" --preview-label=" preview " --bind="start:toggle+down+down+toggle+up+up" < ~/.inglenook-fzf-files'
SH
