#!/usr/bin/env bash
# zsh-syntax-highlighting's part of the CLI/TUI scene, run from its recipe's stage
# steps. The command run.sh starts is an interactive zsh whose rcfile is
# session.zsh: the reader's ~/.zshrc loads, so the plugin and the theme load as
# they do for them. The rcfile is copied to a folder of its own, since zsh may
# write next to it.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.inglenook-zsh
cp "$here/session.zsh" ~/.inglenook-zsh/.zshrc
printf 'ZDOTDIR=%q exec zsh -i\n' "$HOME/.inglenook-zsh" > ~/.inglenook-cli
