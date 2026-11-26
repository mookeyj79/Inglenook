#!/usr/bin/env bash
# Rebuild the ports after a palette change, then run every check.
set -euo pipefail

palette=palette/palette.json
ports=(bat eza git nano)

# moss l 0.52 to 0.5: rebuild before the drift check sees it.
if ! git diff --quiet -- "$palette"; then
  echo "palette changed, rebuilding ${#ports[@]} ports"
  for port in "${ports[@]}"; do
    pwsh build/build.ps1 -Port "$port"
  done
fi

pwsh build/check.ps1 || exit 1
echo "all checks pass"
