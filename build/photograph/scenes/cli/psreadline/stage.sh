#!/usr/bin/env bash
# PSReadLine's part of the CLI/TUI scene, run from its recipe's stage steps. It seeds
# the PSReadLine history the list view suggests from, and writes the command run.sh
# starts: session.sh, which plays each staged command line in a real PowerShell.
# PowerShell's update check is turned off, so no notice is printed. No color changes.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.local/share/powershell/PSReadLine
cp "$here/history.txt" ~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt
printf 'export POWERSHELL_UPDATECHECK=Off POWERSHELL_TELEMETRY_OPTOUT=1\nexec bash %q\n' "$here/session.sh" > ~/.inglenook-cli
