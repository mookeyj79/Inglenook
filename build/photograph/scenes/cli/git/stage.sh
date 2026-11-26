#!/usr/bin/env bash
# Git's part of the CLI/TUI scene, run from its recipe's stage steps. Git has no
# window of its own, so the scene runs in a stock GNOME Terminal: this sets only its
# font, size and cursor blink, never a color. The terminal's own colors stay its
# defaults for the variant's mode. session.sh then plays a few real git commands.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
profile=org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/
gsettings set "$profile" use-system-font false
gsettings set "$profile" font 'BlexMono Nerd Font Mono 11'
gsettings set "$profile" cursor-blink-mode off
gsettings set "$profile" default-size-columns 96
gsettings set "$profile" default-size-rows 42
gsettings set "$profile" scrollbar-policy never
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
printf 'bash %q\n' "$here/session.sh" > ~/.inglenook-cli
