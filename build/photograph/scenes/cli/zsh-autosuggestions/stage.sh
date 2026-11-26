#!/usr/bin/env bash
# zsh-autosuggestions' part of the CLI/TUI scene, run from its recipe's stage steps.
# The command run.sh starts is an interactive zsh. Its startup file loads the
# reader's ~/.zshrc, so the plugin and the theme load as they do for them, then
# plays session.zsh.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.inglenook-zsh
printf 'source ~/.zshrc\nsource %q\n' "$here/session.zsh" > ~/.inglenook-zsh/.zshrc
printf 'ZDOTDIR=~/.inglenook-zsh exec zsh -i\n' > ~/.inglenook-cli
