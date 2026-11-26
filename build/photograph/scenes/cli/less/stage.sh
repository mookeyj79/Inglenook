#!/usr/bin/env bash
# less's part of the CLI/TUI scene, run from its recipe's stage steps. A short page in
# the shape of a man page, with bold and underline made by overstriking, the way man
# hands a page to less. less opens it with line numbers and the long prompt, at a search
# for "moss" with the match on screen line 12, its own line, so the page shows from its top, so the prompt, the line numbers, bold, underline and the search show.
set -euo pipefail
page="$HOME/inglenook-check.1"

b() { local s=$1 o='' i; for ((i = 0; i < ${#s}; i++)); do o+="${s:i:1}"$'\b'"${s:i:1}"; done; printf '%s' "$o"; }
u() { local s=$1 o='' i; for ((i = 0; i < ${#s}; i++)); do o+="_"$'\b'"${s:i:1}"; done; printf '%s' "$o"; }

{
  printf '%s\n' "INGLENOOK-CHECK(1)            Inglenook Manual            INGLENOOK-CHECK(1)" ''
  printf '%s\n' "$(b NAME)"
  printf '%s\n' "       check.ps1 - run every check on the palette and the ports" ''
  printf '%s\n' "$(b SYNOPSIS)"
  printf '%s\n' "       $(b pwsh) $(b build/check.ps1) [$(b -Port) $(u name)]" ''
  printf '%s\n' "$(b DESCRIPTION)"
  printf '%s\n' "       Checks the palette, the contrast floor, and every port. A port whose"
  printf '%s\n' "       $(u dist) folder is out of date fails the drift check. After a change"
  printf '%s\n' "       to moss, such as moss l 0.52 to 0.5, run $(b build/build.ps1) first." ''
  printf '%s\n' "$(b OPTIONS)"
  printf '%s\n' "       $(b -Port) $(u name)"
  printf '%s\n' "              Check one port only. The palette checks always run." ''
  printf '%s\n' "$(b "EXIT STATUS")"
  printf '%s\n' "       0 when every check passes, 1 when one fails." ''
  printf '%s\n' "$(b "SEE ALSO")"
  printf '%s\n' "       $(b build.ps1)(1), $(b photograph.ps1)(1)"
} > "$page"

# An interactive shell, so ~/.bashrc loads the theme the way it does for a user.
printf 'exec bash -ic %q\n' "less -N -M -j12 +/moss $page" > ~/.inglenook-cli
