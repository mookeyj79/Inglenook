#!/usr/bin/env bash
# GitHub CLI's part of the CLI/TUI scene, run from its recipe's stage steps. gh shows
# Markdown when it views a repository, an issue or a pull request, all fetched from
# GitHub. Here gh's own http_unix_socket setting sends every request to server.py on
# a local socket, which answers with a fixed repository and README.md, so the shot
# needs no network and no login. The token is a stand-in that server.py never checks.
# The command run.sh starts is an interactive bash, so ~/.bashrc loads the theme the
# way it does for a user, then plays session.sh.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.config/gh ~/.inglenook-gh
printf 'http_unix_socket: %s\n' "$HOME/.inglenook-gh/api.sock" > ~/.config/gh/config.yml
printf 'exec bash -ic %q\n' "bash $here/session.sh" > ~/.inglenook-cli
