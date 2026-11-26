#!/usr/bin/env bash
# eza's part of the CLI/TUI scene, run from its recipe's stage steps. The terminal
# draws in the system monospace font, set here to BlexMono Nerd Font so eza's icons
# show, with its cursor still. The command run.sh starts is an interactive bash
# that plays session.sh: the reader's ~/.bashrc loads, so the theme loads as it does
# for them.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
gsettings set org.gnome.desktop.interface monospace-font-name 'BlexMono Nerd Font Mono 12'
profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
dconf write "/org/gnome/terminal/legacy/profiles:/:$profile/cursor-blink-mode" "'off'"
printf 'exec bash --rcfile %q -i\n' "$here/session.sh" > ~/.inglenook-cli
