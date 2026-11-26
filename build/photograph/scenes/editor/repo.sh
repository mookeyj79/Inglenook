#!/usr/bin/env bash
# The editor scene's repo: ~/Inglenook, a small git repo shaped like this one. Everything
# is committed at a fixed date, then build/lib/Contrast.psm1 and Catalog.psm1 change and
# Wallpaper.psm1 is added, so an editor shows added, changed and removed lines.
# prepare.sh (VS Code) runs it; an editor with its own scene folder here runs it from its
# recipe's stage: bash "$INGLENOOK_SCENE/repo.sh"
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ws=$HOME/Inglenook

rm -rf "$ws" && mkdir -p "$ws/build/lib" "$ws/palette" "$ws/Ports/vscode"
cd "$ws"
note() { printf '%s\n' "$2" > "$1"; }
note README.md '# Inglenook'
note PHILOSOPHY.md '# Inglenook: Design Philosophy'
note GLOSSARY.md '# Glossary'
note palette/palette.json '{ "meta": { "name": "Inglenook" } }'
note Ports/vscode/port.json '{ "name": "VS Code" }'
note build/build.ps1 '# Palette plus templates make dist.'
note build/check.ps1 '# Runs every rule.'
note build/lib/Palette.psm1 '# Loads and validates the palette.'
note build/lib/Catalog.psm1 '# Finds ports and validates port.json.'
cp "$here/content/Contrast.committed.psm1" build/lib/Contrast.psm1

export GIT_AUTHOR_NAME=Inglenook GIT_AUTHOR_EMAIL=inglenook@example.invalid GIT_AUTHOR_DATE='2026-11-20T12:00:00Z'
export GIT_COMMITTER_NAME=Inglenook GIT_COMMITTER_EMAIL=inglenook@example.invalid GIT_COMMITTER_DATE='2026-11-20T12:00:00Z'
git init -q -b main
git add -A && git commit -q -m 'Add the contrast module'

cp "$here/content/Contrast.psm1" build/lib/Contrast.psm1
note build/lib/Catalog.psm1 '# Finds ports and validates port.json and screenshot.json.'
note build/lib/Wallpaper.psm1 '# Wallpaper rules: grades, variant marks and pairs, license.'
