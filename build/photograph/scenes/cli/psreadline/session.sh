# shellcheck shell=bash
# The CLI/TUI scene's PowerShell session for PSReadLine (see stage.sh). Each staged
# command line is typed into a real PowerShell that loads the reader's profile, so
# PSReadLine draws it in the theme's colors; then that PowerShell exits and the
# command's fixed output is printed. The last PowerShell stays open, its list view
# showing the history that matches what is typed, the first suggestion picked.
# Output is plain text, so every color on screen is PSReadLine's.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd ~/Inglenook
line() { INGLENOOK_LINE=$1 pwsh -NoLogo -NoExit -File "$here/line.ps1"; printf '\n'; }

printf '\e[H\e[2J'
line '$palette = Get-Content -Raw ./palette/palette.json | ConvertFrom-Json'
line 'if ($palette.moss.l -lt 0.52) { "moss is now $($palette.moss.l)" }  # was 0.52'
printf '%s\n' 'moss is now 0.5'
line '[math]::Round($palette.moss.l * 100)'
printf '%s\n' '50'
line $'foreach ($variant in \'day\', \'night\') {\n    "Ports/psreadline/dist/$variant"\n}'
printf '%s\n' 'Ports/psreadline/dist/day' 'Ports/psreadline/dist/night'
INGLENOOK_LINE=palette INGLENOOK_LAST=1 exec pwsh -NoLogo -NoExit -File "$here/line.ps1"
