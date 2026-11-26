#!/usr/bin/env bash
# The editor scene: a staged slice of working on the Inglenook repo, as a VS Code window.
# Run it in a recipe's stage, then open ~/Inglenook: bash "$INGLENOOK_SCENE/prepare.sh"
#
# It builds ~/Inglenook, a small git repo shaped like this one: everything committed at a
# fixed date, then build/lib/Contrast.psm1 and Catalog.psm1 changed and Wallpaper.psm1
# added, so the Explorer and the gutter show added, changed and removed lines. It also
# installs vscode-scene, a tiny extension that opens Contrast.psm1, selects two lines and
# puts one error under a misspelled call. Fixed content, never live, and no colors: the
# port under test decides every color.
#
# What it shows: all eight roles, from the syntax (keywords, functions, types, numbers, a
# string), the gutter and Explorer git marks (added, changed, removed) and the error; the
# three text strengths (code, punctuation, comments); the accent (cursor, focus, badge) and
# a wash (the selection). The window title names Contrast.psm1 once all of it is there.
#
# Needs code and @vscode/vsce (the VS Code recipe installs both). Material Icon Theme, a
# guest of VS Code, is shot in this same scene.
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

# The scene extension, packaged and installed like any other.
mkdir -p "$HOME/scene-extension"
cp -r "$here/vscode-scene/." "$HOME/scene-extension/"
(cd "$HOME/scene-extension" && npx @vscode/vsce package --skip-license --allow-missing-repository --out "$HOME/scene-extension.vsix" >/dev/null)
code --install-extension "$HOME/scene-extension.vsix" >/dev/null 2>&1

# The window's place and size: about 1200x760 in the middle of the 1600x1000 screen.
# VS Code opens a folder at the size it last had, so the scene writes that state.
mkdir -p "$HOME/.config/Code/User/globalStorage"
cat > "$HOME/.config/Code/User/globalStorage/storage.json" <<JSON
{ "windowsState": { "lastActiveWindow": { "folder": "file://$ws", "uiState": { "mode": 1, "x": 200, "y": 120, "width": 1200, "height": 760 } }, "openedWindows": [] } }
JSON
