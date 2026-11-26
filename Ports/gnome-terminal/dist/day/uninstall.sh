#!/usr/bin/env bash
# Inglenook for GNOME Terminal: removes the Inglenook Day profile.
# Generated from https://github.com/mookeyj79/Inglenook (Ports/gnome-terminal). Do not edit by hand.
set -euo pipefail

uuid='1148f1bd-1a79-43a9-ac91-05e14932c4c3'
base='/org/gnome/terminal/legacy/profiles:'

# If it is the default profile, hand the default back to the first other profile.
list=$(gsettings get org.gnome.Terminal.ProfilesList list)
rest=$(printf '%s' "$list" | sed -e "s/'$uuid'//" -e 's/\[, */[/' -e 's/, *,/,/' -e 's/, *\]/]/')
if [ "$(gsettings get org.gnome.Terminal.ProfilesList default)" = "'$uuid'" ]; then
  first=$(printf '%s' "$rest" | grep -o "'[^']*'" | head -n 1 || true)
  if [ -z "$first" ]; then
    echo 'Inglenook Day is your only profile. Create another profile first, then run this again.' >&2
    exit 1
  fi
  gsettings set org.gnome.Terminal.ProfilesList default "$first"
fi

gsettings set org.gnome.Terminal.ProfilesList list "$rest"
dconf reset -f "$base/:$uuid/"
echo 'Inglenook Day is removed.'
