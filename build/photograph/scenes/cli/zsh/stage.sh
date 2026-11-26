#!/usr/bin/env bash
# The Zsh line editor's part of the CLI/TUI scene, run from its recipe's stage steps.
# The command run.sh starts is an interactive Zsh whose startup file is session.zsh:
# it loads the reader's ~/.zshrc, so the theme loads as it does for them, then plays
# the scene's command lines.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.inglenook-zsh
printf 'source %q\n' "$here/session.zsh" > ~/.inglenook-zsh/.zshrc
printf 'export ZDOTDIR=~/.inglenook-zsh\nexec zsh -i\n' > ~/.inglenook-cli
