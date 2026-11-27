#!/usr/bin/env bash
# Docker's part of the CLI/TUI scene, run from its recipe's stage steps. A real
# docker build needs a BuildKit daemon, which needs privileges the Photographer's
# container does not have. So the scene replays build.tty: the terminal output of a
# real `docker build --no-cache --progress=tty .` of the Dockerfile here, recorded
# at 110 columns with the port's BUILDKIT_COLORS. Docker picks terminal slots by
# name, so the terminal draws the colors: the recipe's apply steps install the
# GNOME Terminal port in the variant and make it the default profile.
#
# To record build.tty again (Docker 23 or newer, and script from util-linux), in an
# empty folder holding this Dockerfile:
#   docker pull busybox
#   source <repo>/Ports/docker/dist/day/docker.sh && export BUILDKIT_COLORS
#   script -q -e -c "stty cols 110 rows 28; docker build --no-cache --progress=tty ." build.tty
# then delete the "Script started" line at the top and the "Script done" line at the end.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
profile=org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/
gsettings set "$profile" use-system-font false
gsettings set "$profile" font 'BlexMono Nerd Font Mono 11'
gsettings set "$profile" cursor-blink-mode off
gsettings set "$profile" default-size-columns 110
gsettings set "$profile" default-size-rows 30
gsettings set "$profile" scrollbar-policy never
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
printf 'bash %q\n' "$here/session.sh" > ~/.inglenook-cli
