#!/usr/bin/env bash
# Neovim's part of the editor scene, started by ../run.sh in the host terminal after
# repo.sh. Opens build/lib/Contrast.psm1 against its committed copy in diff mode, so the
# changed, added and removed lines show as Neovim marks them, and lets scene.lua put the
# error and the selection in place. Fixed content, never live, and no colors: the port's
# colorscheme, loaded from ~/.config/nvim/init.lua, decides every color.
# The recipe's stage writes it as the editor command:
#   printf 'bash %q\n' "$INGLENOOK_SCENE/neovim-scene/run.sh" > ~/.inglenook-editor
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd ~/Inglenook
exec nvim -i NONE -n -S "$here/scene.lua" build/lib/Contrast.psm1
