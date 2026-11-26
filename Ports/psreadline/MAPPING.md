# PSReadLine: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

One `Set-PSReadLineOption -Colors` call in `template/psreadline.ps1`, a PowerShell-only shell file. This table is the token to palette name table the Zsh line editor ports match (zsh-syntax-highlighting and the others in #20 to #23).

| PSReadLine color | Color | Why |
|---|---|---|
| `Default` | text | Plain words, file names, and every bracket, brace, pipe and dot |
| `Command` | info | Functions row of the syntax mapping |
| `Member` | info | Properties and methods: keys and functions |
| `Parameter` | literal | Flags |
| `Number` | literal | |
| `String` | success | |
| `Variable` | reference | Names that point at a value. zsh-syntax-highlighting gives `$var` in a string the same |
| `Keyword` | keyword | |
| `Type` | type | `[math]`, `[string]` |
| `Operator` | dim | Punctuation: `=`, `-lt`, `*`, `,` |
| `Comment` | faint | |
| `ContinuationPrompt` | dim | The `>>` of a multi-line command: supporting text |
| `Error` | error | Parse errors, and the prompt text PSReadLine marks on one |
| `Emphasis` | `on_accent` on the accent fill | The matched text in history search (Ctrl+R) and in the suggestion list. The owner's decision (2026-11-26): firelight, as the match at the cursor in Search and matches in PHILOSOPHY.md, not steel, which here is the command color. In the list view the match is marked on every row, not only the picked one |
| `Selection` | text on the accent wash | Selected text |
| `InlinePrediction` | faint | A suggestion is a placeholder until accepted. zsh-autosuggestions uses the same |
| `ListPrediction` | faint | The `>` markers, the `[History]` source names and the `<1/3>` counter: metadata |
| `ListPredictionSelected` | the accent wash, as a background only | The picked suggestion. Its text keeps its colors |
| `ListPredictionTooltip` | faint | PSReadLine's own default uses its inline prediction color here too |

## Gaps and trade-offs

- Values are written as hex in the file and turned into 24-bit escape sequences when it loads, because a background needs an escape sequence (a hex value is only a foreground).
- Only the colors the loaded PSReadLine knows are set: `InlinePrediction` came in 2.1, `ListPrediction` and `ListPredictionSelected` in 2.2, `ListPredictionTooltip` in 2.3. An unknown name prints an error. Checked with PSReadLine 2.0.0 and 2.4.5.
- The file runs in a script block, so it leaves no variables in the reader's session. It does nothing when PSReadLine is not installed.
- PSReadLine has no punctuation color: brackets, braces, pipes and member dots are `Default`, so text, not dim.
- PSReadLine draws part of the list view's source summary (`<History(1/3)>`) in its own `DefaultInlinePredictionColor`, which no option changes (`Prediction.Views.cs`, `RenderMetadataLine`).
- The scene cannot show `Selection`, `InlinePrediction`, `ListPredictionTooltip` or `Error`: past lines are drawn as PSReadLine leaves them after Enter, with no selection or suggestion, and the last line shows the list view. History suggestions have no tooltip.

## Research

- [Catppuccin for PowerShell](https://github.com/catppuccin/powershell): a module whose README builds a `$Colors` table of escape sequences per flavor (prompt, syntax, `Selection` and `ListPredictionSelected` as backgrounds, `InlinePrediction` muted) and passes it to `Set-PSReadLineOption -Colors`. Same method here, as one sourced file per variant instead of a module; no files reused.
- [Dracula for PowerShell](https://github.com/dracula/powershell): a configuration file the reader adds to `$PROFILE`, and a check for PSReadLine 2.0 or later. Same install method.
- Color names and the option each one sets: the `-Colors` table in `Cmdlets.cs` of PSReadLine. `ListPredictionTooltip` is there and not yet on Microsoft Learn. `Default` sets `DefaultTokenColor`; every other name sets `<Name>Color`.

## Screenshot recipe

- PowerShell and PSReadLine need no login or license (MIT: [PowerShell](https://github.com/PowerShell/PowerShell/blob/master/LICENSE.txt), [PSReadLine](https://github.com/PowerShell/PSReadLine/blob/master/License.txt)).
- PowerShell 7.6.10 (with PSReadLine 2.4.5) is installed from its GitHub release `.deb`, checked against its SHA-256. It runs in the GNOME Terminal port, the host.
- **apply** is the README's steps 1, 2, 4 and 5 for Linux. Step 3 is Windows only.
- **stage** seeds the PSReadLine history the list view suggests from, and turns off PowerShell's update check. The scene (`build/photograph/scenes/cli/psreadline/`) types each command line for PSReadLine when it first waits for a key (`PowerShell.OnIdle` and `PSConsoleReadLine::Insert`), standing in for typing: not tested by hand. Each past line is drawn by its own PowerShell, which then exits; the command's output is fixed text. The prompt and the list view (`-PredictionViewStyle ListView`) are set by the scene, not by the theme.
