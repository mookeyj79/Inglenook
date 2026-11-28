# shellcheck shell=bash
# The rcfile of the Bash line editor's interactive shell in the CLI/TUI scene (see
# stage.sh). It loads the reader's ~/.bashrc, so the theme loads as it does for them,
# grows the staged repo from run.sh by a few files of each kind, and puts one commit
# command in the history. Ctrl+C is not echoed as ^C, so it does not cover the line
# it leaves. drive.py then types the keys. The prompt is ANSI blue, so
# every other color on screen is the theme's or the reader's LS_COLORS.
# shellcheck source=/dev/null
source ~/.bashrc
cd ~/Inglenook
mkdir -p Ports build docs wallpapers
touch AGENTS.md LICENSE PHILOSOPHY.md README.md inglenook-night.tar.gz palette.json.bak preview.png
printf '#!/bin/sh\n' > install.sh && chmod 755 install.sh
ln -sf AGENTS.md CLAUDE.md
history -c
history -s 'git commit -am "Darken day moss"'
stty -echoctl
PS1='\[\e[34m\]\w\[\e[0m\] \$ '
printf '\e[H\e[2J'
