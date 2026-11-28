#!/usr/bin/env bash
# The theme.park port's part of the web scene: File Browser, one of the apps
# theme.park themes, serving a small home-server folder. No color is written here:
# theme.park's File Browser base CSS and the port's theme option decide every one.
# Usage: stage.sh <custom.css>, where custom.css is the base CSS followed by the
# theme option. Then run serve.sh.
set -euo pipefail
css=${1:?usage: stage.sh <custom.css>}
home=$HOME/filebrowser
files=$home/files
mkdir -p "$home/branding" "$files"
cp "$css" "$home/branding/custom.css"

# The folder. Fixed dates, shown as dates, so the listing never changes.
mkdir -p "$files/Backups" "$files/Books" "$files/Documents" "$files/Music" "$files/Photos" "$files/Recipes"
printf 'Split the hostas by the porch in spring.\nOil the hinges on the woodshed door.\n' > "$files/garden-notes.txt"
printf '# Cabin\n\nThe key is under the second step.\n' > "$files/README.md"
printf 'date,cords,stacked\n2026-10-04,2,yes\n2026-10-18,1,no\n' > "$files/firewood.csv"
head -c 48000 /dev/zero > "$files/kettle-photo.jpg"
head -c 2300000 /dev/zero > "$files/library-scan.pdf"
find "$files" -exec touch -d '2026-10-18 19:30:00' {} +

# File Browser's database: no login, absolute dates, no disk-usage meter or
# external links (both would change between takes), the branding folder, and
# File Browser's own mode matching the variant, as a reader would set it under
# Settings, Global Settings: theme.park's base CSS leaves a few parts to it.
mode=light
[ "${INGLENOOK_VARIANT:-day}" = night ] && mode=dark
db=$home/filebrowser.db
rm -f "$db"
filebrowser config init -d "$db" --auth.method=noauth --dateFormat --branding.theme "$mode" \
  --branding.name "File Browser" --branding.files "$home/branding" \
  --branding.disableUsedPercentage --branding.disableExternal >/dev/null
filebrowser users add admin inglenook-scene -d "$db" --perm.admin >/dev/null
