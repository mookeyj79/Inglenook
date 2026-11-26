# PowerShell: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

One PowerShell-only shell file, `template/psstyle.ps1`, built into `psstyle.ps1` per variant. It sets the escape strings in `$PSStyle.Formatting`, `.Progress` and `.FileInfo` with `$PSStyle.Foreground.FromRgb()` (24-bit), inside a script block so dot-sourcing leaves no variables behind. Every slot is a foreground: PowerShell keeps the terminal's background. PowerShell's defaults are bold; the theme drops bold except where `ls` and eza bold too.

| `$PSStyle` setting | Color | Why |
|---|---|---|
| `Formatting.Error` | `error` | The `Get-Item:` prefix, the message, and the squiggle under the failing code |
| `Formatting.ErrorAccent` | `dim` | The `Line \|` gutter and the code excerpt of an error: supporting text around the message |
| `Formatting.Warning` | `warning` | |
| `Formatting.Verbose` | `info` | Information. PowerShell's default draws verbose, debug and warning all the same yellow |
| `Formatting.Debug` | `dim` | Supporting text. Kept apart from verbose and warning |
| `Formatting.FormatAccent` (list labels) | `info` | Property names, per the syntax mapping (keys and properties) |
| `Formatting.TableHeader` | `info` | Property names too, so table and list labels match. Steel headers are the owner's decision (2026-11-26), although eza's header is `text`, underlined |
| `Formatting.CustomTableHeaderLabel` | `info`, italic | PowerShell's default keeps italic as the sign of a label that is not a property |
| `Formatting.FeedbackName` | `dim` | The provider name above a suggestion |
| `Formatting.FeedbackText` | `text` | |
| `Formatting.FeedbackAction` | `info` | Suggested commands, per the syntax mapping (functions) |
| `Progress.Style` | `info` | In progress. The minimal bar draws its filled part reversed, so the bar is this color with the terminal background as text |
| `FileInfo.Directory` | `ansi.blue` (steel), bold | eza's and `ls`'s folders. PowerShell's default is a blue background block |
| `FileInfo.SymbolicLink` | `reference` | A link is a reference. eza does the same |
| `FileInfo.Executable` | `ansi.green` (moss), bold | eza's and `ls`'s executables, not a success state |
| `FileInfo.Extension`: `.zip .tgz .gz .tar .nupkg .cab .7z` | `oxblood` | eza's archive color. These are PowerShell's own archive keys |
| `FileInfo.Extension`: `.ps1 .psd1 .psm1 .ps1xml` | `rosewood` | eza's source-file color. These are PowerShell's own script keys |

## Gaps and trade-offs

- `accent` is not used: `$PSStyle` has no focus, cursor or selection. The command line is PSReadLine's port.
- `Formatting.TableHeader` also colors the dashes under a header. In `Get-ChildItem`, headers and folder names are both steel; folders stay apart by bold.
- Only the extension keys PowerShell predefines are set, so nothing is added to a user's dictionary that PowerShell did not have. Other extensions keep the text color, where eza colors images, audio and documents.
- `$PSStyle.Foreground` and `.Background` (the sixteen ANSI names) are left alone: scripts use them to mean the terminal's own colors, which the terminal port sets.
- `Select-String` uses `$PSStyle.Reverse`, no color. `Show-Markdown` reads `Set-MarkdownOption`, which is not part of `$PSStyle`.
- The file needs 7.4 or later (`Feedback*` came in 7.4) and returns early on anything older, including Windows PowerShell 5.1. 7.2 and 7.3 are out of support.
- Not in the screenshots: `CustomTableHeaderLabel` (in a test on 7.7, `Format-Table` with a calculated column still drew the label as `TableHeader`), the `Feedback*` slots (only shown interactively after a command that is not found), and the `.ps1xml`, `.psd1` and `.psm1` keys (the same color as `.ps1`).

## Research

- [Catppuccin for PowerShell](https://github.com/catppuccin/powershell): a module with flavor objects; its README sets seven `$PSStyle.Formatting` slots in the profile and leaves `FileInfo` and `Progress` alone. Learned: setting `$PSStyle` lines from the profile is the whole install. Inglenook ships the lines as a file the profile dot-sources, as every shell port does, and covers `FileInfo` and `Progress` too.
- [about_ANSI_Terminals](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_ansi_terminals) lists the members; `$PSStyle.Formatting`, `.Progress` and `.FileInfo` were checked against `Get-Member` on PowerShell 7.7.0. PowerShell's defaults: `FormatAccent` and `TableHeader` green bold, `ErrorAccent` cyan bold, `Error` red bold, `Warning`, `Verbose`, `Debug` and `Progress.Style` yellow bold, `Directory` a blue background.
- `FileInfo.Extension` is a dictionary type with an indexer, `Add`, `Remove` and `ContainsKey`, no enumerator.
- `$Host.PrivateData` colors are not connected to `$PSStyle.Formatting` (about_ANSI_Terminals), so the port does not set them.

## Screenshot recipe

- PowerShell needs no login or license ([MIT](https://github.com/PowerShell/PowerShell/blob/master/LICENSE.txt)).
- The recipe installs PowerShell 7.6.10 (the current LTS) from its GitHub release `.deb`, checked by sha256, and runs as a guest in the GNOME Terminal port.
- The apply steps add the README's `.` line to `~/.config/powershell/Microsoft.PowerShell_profile.ps1`, which is `$PROFILE` on Linux, so pwsh loads the theme as it does for a reader.
- The scene (`build/photograph/scenes/cli/powershell/`) runs `session.ps1` with `pwsh -File`, which loads the profile, and plays each command with `Invoke-Expression` after a plain prompt, standing in for typing: not tested by hand. It ends on a staged `build.ps1` that writes verbose, debug, a warning, a real error and a progress bar, then waits. Times are UTC, update checks and telemetry are off.
