#!/usr/bin/env bash
# Inglenook for GNOME Terminal: adds the Inglenook Day profile.
# Generated from https://github.com/mookeyj79/Inglenook (Ports/gnome-terminal). Do not edit by hand.
#
# Usage: bash install.sh [--default]
#   --default  also make it the default profile
set -euo pipefail

default=false
for arg in "$@"; do
  case "$arg" in
    --default) default=true ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

uuid='1148f1bd-1a79-43a9-ac91-05e14932c4c3'
base='/org/gnome/terminal/legacy/profiles:'

# Write every profile key. Running the script again overwrites them.
dconf load "$base/:$uuid/" <<'EOF'
[/]
visible-name='Inglenook Day'
use-theme-colors=false
background-color='#f1f3ee'
foreground-color='#2d373f'
bold-color-same-as-fg=true
bold-is-bright=false
cursor-colors-set=true
cursor-background-color='#9b5a00'
cursor-foreground-color='#f9fbf8'
highlight-colors-set=true
highlight-background-color='#e3dbc8'
highlight-foreground-color='#2d373f'
palette=['#2d373f', '#a04037', '#407135', '#706416', '#326893', '#844b80', '#017272', '#cfd2cb', '#657178', '#942a23', '#2d6420', '#555555', '#195a88', '#783a73', '#555555', '#f9fbf8']
use-system-font=false
font='BlexMono Nerd Font Mono 12'
EOF

# Add the profile to the list GNOME Terminal shows, once.
list=$(gsettings get org.gnome.Terminal.ProfilesList list)
case "$list" in
  *"'$uuid'"*) ;;
  '@as []' | '[]') gsettings set org.gnome.Terminal.ProfilesList list "['$uuid']" ;;
  *) gsettings set org.gnome.Terminal.ProfilesList list "${list%]}, '$uuid']" ;;
esac

if [ "$default" = true ]; then
  gsettings set org.gnome.Terminal.ProfilesList default "$uuid"
  echo 'Inglenook Day is installed and is now the default profile.'
else
  echo 'Inglenook Day is installed. Pick it in Preferences or run again with --default.'
fi
