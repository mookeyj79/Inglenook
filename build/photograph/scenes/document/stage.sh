#!/usr/bin/env bash
# The document scene: two short Markdown notes, for writing apps and note apps.
# Copy them into a folder (a vault, a notes folder): bash "$INGLENOOK_SCENE/stage.sh" <dir>
#
# "Evening reading.md" is the one to open. It shows three heading levels, a link to the
# other note ([[Kindling]], so it resolves), a done and an open task, a tag, a note
# callout, and a Python code block with keywords, a function, types, a number, a
# string, punctuation and a comment. Fixed content and no colors: the port under
# test decides every color. Obsidian opens it in a vault (obsidian/stage.sh).
set -euo pipefail
dir=${1:?usage: stage.sh <dir>}
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$dir"
cp "$here/notes/"*.md "$dir/"
