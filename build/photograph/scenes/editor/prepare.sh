#!/usr/bin/env bash
# The editor scene: a staged slice of working on the Inglenook repo, as a VS Code window.
# Run it in a recipe's stage, then open ~/Inglenook: bash "$INGLENOOK_SCENE/prepare.sh"
#
# It builds ~/Inglenook with repo.sh: a small git repo shaped like this one, with
# build/lib/Contrast.psm1 and Catalog.psm1 changed and Wallpaper.psm1 added, so the
# Explorer and the gutter show added, changed and removed lines. It also installs
# vscode-scene, a tiny extension that opens Contrast.psm1, selects two lines and puts one
# error under a misspelled call. Fixed content, never live, and no colors: the port under
# test decides every color. Neovim shows the same file and marks (neovim-scene/).
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
bash "$here/repo.sh"

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
