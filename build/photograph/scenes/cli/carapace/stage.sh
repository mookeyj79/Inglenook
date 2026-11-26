#!/usr/bin/env bash
# carapace's part of the CLI/TUI scene, run from its recipe's stage steps. carapace
# draws its completions in Zsh, so the command run.sh starts is an interactive Zsh
# whose ~/.zshrc is this folder's zshrc: carapace's own Zsh setup, a plain prompt,
# and one listing. No color is set here; the colors on screen are styles.json's.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cp "$here/zshrc" ~/.zshrc
printf 'exec zsh -i\n' > ~/.inglenook-cli
