#!/usr/bin/env bash
# Helix's part of the editor scene, run from the recipe's stage after repo.sh and after the
# port's apply step wrote theme = "..." to ~/.config/helix/config.toml. Appends display
# options only, never a color, points PowerShell at diagnostic-server.py (a stand-in for a
# language server that reports one error), and writes the editor command for ../run.sh.
#   bash "$INGLENOOK_SCENE/helix/stage.sh"
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cfg=$HOME/.config/helix
mkdir -p "$cfg"
grep -q '^theme = ' "$cfg/config.toml" || { echo 'helix-scene: config.toml sets no theme' >&2; exit 1; }

cat >> "$cfg/config.toml" <<'TOML'

[editor]
bufferline = "always"
color-modes = true
true-color = true
end-of-line-diagnostics = "hint"
auto-info = false

[editor.inline-diagnostics]
cursor-line = "disable"
other-lines = "disable"
TOML

cat > "$cfg/languages.toml" <<TOML
[language-server.scene]
command = "python3"
args = ["-I", "$here/diagnostic-server.py"]

[[language]]
name = "powershell"
language-servers = ["scene"]
TOML

printf 'bash %q\n' "$here/run.sh" > ~/.inglenook-editor
