# Inglenook for <App>

**Tier:** <1 Full | 2 Partial | 3 Minimal>\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** <App> <version> on <OS>, or "Not tested yet"

| Day | Night |
|---|---|
| ![Inglenook Day](screenshots/day.png) | ![Inglenook Night](screenshots/night.png) |

## Before you start

- <App version or edition required>
- <Anything to install or enable first, or "Nothing">

## Install

1. <One action. Real path or menu name.>
2. <Next action.>
3. <...>

<For a shell file, use the block below in place of the numbered steps, with these headings. Drop the shell a tool does not run in (say why under **Known limits**), and drop the last heading when the file is code, not a variable.>

### Zsh or Bash (Linux, macOS, WSL)

1. Create the folder `~/.config/inglenook/`.
2. Save [`dist/day/<tool>.sh`](dist/day/<tool>.sh) or [`dist/night/<tool>.sh`](dist/night/<tool>.sh) there as `<tool>.sh`.
3. Add this line to the end of `~/.zshrc` (Zsh) or `~/.bashrc` (Bash), <after what it must follow>:

   ```sh
   source ~/.config/inglenook/<tool>.sh
   ```

4. Open a new terminal.

### PowerShell (Windows, macOS, Linux)

1. Create the folder `~/.config/inglenook/` (on Windows, `%USERPROFILE%\.config\inglenook\`).
2. Save [`dist/day/<tool>.ps1`](dist/day/<tool>.ps1) or [`dist/night/<tool>.ps1`](dist/night/<tool>.ps1) there as `<tool>.ps1`.
3. Run `notepad $PROFILE` (or open `$PROFILE` in any editor) and add this line to the end:

   ```powershell
   . ~/.config/inglenook/<tool>.ps1
   ```

4. Open a new PowerShell window.

### With Nowhere

Nowhere loads `~/.config/nowhere/theme.zsh` and `~/.config/nowhere/theme.ps1` last. Put the same `source` line (Zsh) or `.` line (PowerShell) in that file instead of in your profile.

### Setting the variable another way

<Which variable the file sets, and where to copy its value from, for readers who set variables another way (Windows system variables, a dotfiles manager). "variables" when it sets several.>

Files to use:

- Inglenook Day: `dist/day/<file>`
- Inglenook Night: `dist/night/<file>`

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). Where the app shows icons, use [BlexMono Nerd Font](https://www.nerdfonts.com/font-downloads) instead, the same font with icons added. If it is not installed yet, follow [Font](../../README.md#font) in the main README.

1. <Where to set the font in this app. Real menu or setting name.>
2. <Pick **IBM Plex Mono** or **BlexMono Nerd Font Mono**. Say which name the app shows if it differs.>

<If the app cannot change its font, say so in one line and delete the steps.>

## Check that it worked

<What the reader should see. One or two lines.>

## Switch between Day and Night

1. <Steps to switch.>

<Say whether the app can follow the OS light/dark setting, and how to turn that on.>

## Make it see-through (optional)

<Only if the app has its own transparency setting: where it is. The theme itself is solid. Delete this section otherwise.>

## Uninstall

1. <Steps to remove the theme and return to the default.>

## Troubleshooting

- **<Symptom>**: <fix>

## Known limits

- <What the reader will notice that the theme cannot change, in the app's own terms. No color names, no contrast numbers.>

## Sources

- <The app's official docs for the theme format and install steps>
- <A credit line for any files reused from another project, with its license>
