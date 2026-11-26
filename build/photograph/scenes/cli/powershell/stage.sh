#!/usr/bin/env bash
# PowerShell's part of the CLI/TUI scene, run from its recipe's stage steps. pwsh starts
# with the reader's profile, so the theme loads as it does for them, and plays
# session.ps1: real commands on a fixed slice of the Inglenook repo. No update check
# and no telemetry. Times show in UTC so every take prints the same.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cat > ~/.inglenook-cli <<SH
export TZ=UTC POWERSHELL_UPDATECHECK=Off POWERSHELL_TELEMETRY_OPTOUT=1
exec pwsh -NoLogo -File $(printf '%q' "$here/session.ps1")
SH
