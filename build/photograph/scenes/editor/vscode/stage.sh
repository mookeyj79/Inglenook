#!/usr/bin/env bash
# VS Code's own part of the editor scene: a short Markdown note, shown in the Markdown
# preview beside the code, so the shot shows how a horizontal rule is drawn. Run it in
# the recipe's stage after prepare.sh: bash "$INGLENOOK_SCENE/vscode/stage.sh"
#
# The note sits outside ~/Inglenook, so the Explorer and its git marks stay as they are.
# preview-scene, a tiny extension, opens it beside Contrast.psm1 once that is the active
# editor, and keeps the focus there, so the window title still names Contrast.psm1.
# Fixed content and no colors: the port under test decides every color.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$HOME/Notes"
cp "$here/Hearth.md" "$HOME/Notes/Hearth.md"

mkdir -p "$HOME/preview-scene"
cp -r "$here/preview-scene/." "$HOME/preview-scene/"
(cd "$HOME/preview-scene" && npx @vscode/vsce package --skip-license --allow-missing-repository --out "$HOME/preview-scene.vsix" >/dev/null)
code --install-extension "$HOME/preview-scene.vsix" >/dev/null 2>&1
