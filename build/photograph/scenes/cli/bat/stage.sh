#!/usr/bin/env bash
# bat's part of the CLI/TUI scene, run from its recipe's stage steps. It writes the
# command run.sh starts: commit the editor scene's Contrast.psm1 as it was, put the
# changed one in its place, then print it with bat. The gutter shows the changed,
# added and removed lines, and the line with the misspelled call is highlighted.
# Fixed content and no colors: the port under test decides every color it can.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
content=$(cd "$here/../../editor/content" && pwd)

cat > ~/.inglenook-cli <<SH
set -euo pipefail
cd ~/Inglenook
mkdir -p build/lib
cp '$content/Contrast.committed.psm1' build/lib/Contrast.psm1
export GIT_AUTHOR_NAME=Inglenook GIT_AUTHOR_EMAIL=inglenook@example.invalid GIT_AUTHOR_DATE='2026-11-24T12:30:00Z'
export GIT_COMMITTER_NAME=Inglenook GIT_COMMITTER_EMAIL=inglenook@example.invalid GIT_COMMITTER_DATE='2026-11-24T12:30:00Z'
git add -A && git commit -q -m 'Add the contrast module'
cp '$content/Contrast.psm1' build/lib/Contrast.psm1
printf '\\e[H\\e[2J'
bat --paging=never --style=numbers,changes,header-filename,grid --line-range=1:26 --highlight-line=23 build/lib/Contrast.psm1
exec sleep infinity
SH
