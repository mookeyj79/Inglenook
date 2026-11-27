#!/usr/bin/env bash
# Vim's part of the editor scene, started by ../run.sh in the host terminal after
# repo.sh. Opens build/lib/Contrast.psm1 against its committed copy in diff mode, so the
# changed, added and removed lines show as Vim marks them, and lets scene.vim put the
# search matches and the selection in place. Fixed content, never live, and no colors:
# the port's colorscheme, loaded from ~/.vimrc, decides every color.
# The recipe's stage writes it as the editor command:
#   printf 'bash %q\n' "$INGLENOOK_SCENE/vim-scene/run.sh" > ~/.inglenook-editor
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd ~/Inglenook
exec vim -i NONE -n -S "$here/scene.vim" build/lib/Contrast.psm1
