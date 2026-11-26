#!/usr/bin/env bash
# Inglenook for GNOME Terminal: adds the Inglenook Night profile.
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

uuid='c958d11f-8d00-457c-87bc-7ecb3eea82d3'
base='/org/gnome/terminal/legacy/profiles:'

# Write every profile key. Running the script again overwrites them.
dconf load "$base/:$uuid/" <<'EOF'
[/]
visible-name='Inglenook Night'
use-theme-colors=false
background-color='#1b1917'
foreground-color='#d1c9bc'
bold-color-same-as-fg=true
bold-is-bright=false
cursor-colors-set=true
cursor-background-color='#f3a958'
cursor-foreground-color='#12100e'
highlight-colors-set=true
highlight-background-color='#463624'
highlight-foreground-color='#d1c9bc'
palette=['#262321', '#d9897e', '#91bc88', '#bdb377', '#89b3d8', '#cb9cc6', '#72bdbd', '#b1aa9e', '#8f887f', '#ef958a', '#9ecd93', '#cec37f', '#94c4ed', '#dfa9d9', '#7acfce', '#d1c9bc']
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
  echo 'Inglenook Night is installed and is now the default profile.'
else
  echo 'Inglenook Night is installed. Pick it in Preferences or run again with --default.'
fi
