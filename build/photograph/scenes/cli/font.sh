#!/usr/bin/env bash
# The CLI/TUI scene's font, the same for every port of the kind: BlexMono Nerd Font
# Mono 12, as the GNOME Terminal port sets it. A port hosted by that port already has
# it. A recipe that opens its own terminal runs this first in its stage steps: it sets
# the system monospace font and the default GNOME Terminal profile's font, never a color.
set -euo pipefail
font='BlexMono Nerd Font Mono 12'
gsettings set org.gnome.desktop.interface monospace-font-name "$font"
p=/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/
dconf write "${p}use-system-font" false
dconf write "${p}font" "'$font'"
