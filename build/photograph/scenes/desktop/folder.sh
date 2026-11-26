#!/usr/bin/env bash
# The desktop scene's folder: the top of the Inglenook repo, shown in the file manager.
# Fixed names, contents and times, never the live repo, so every take shows the same.
# Usage: folder.sh <dir>, an empty folder on a fixed-size disk.
set -euo pipefail
dir=$1
for d in build docs palette Ports wallpapers; do mkdir -p "$dir/$d"; done
for f in README.md PHILOSOPHY.md CONTRIBUTING.md GLOSSARY.md; do printf '# %s\n' "${f%.md}" > "$dir/$f"; done
printf 'MIT License\n' > "$dir/LICENSE"
touch -d '2026-06-01 09:00' "$dir"/*
