# The user applies the theme

Superseded by [ADR 0013](0013-nowheres-theme-script-applies-inglenook.md).

Inglenook ships each port's files for both variants and a step-by-step guide to install them. It does not put them in place. The user does it by hand: copying a file, adding a `source` line, picking Day or Night, and switching between them. Nowhere made the same call for its side (its ADR 0002): it loads an optional theme file last and never creates, chooses or changes it. So neither repo applies the theme, and no suite-wide installer, variant setting, switch command or OS light and dark detection lives in either.

An install script that copies every shell file into place, or a theme file that picks the variant, would save steps on the owner's machines. It was turned down because each port stands alone and works without the owner's setup, and a script that edits profiles and config folders across a dozen tools is one more thing to break on a machine the repo has never seen.

## Consequences

- A port's guide may hand the user a script for its own app, such as GNOME Terminal's `install.sh`, or a package the app installs itself, such as a VS Code extension. The user runs it as a step of the guide. Nothing runs on its own.
- A port's "With Nowhere" section says which file goes in Nowhere's theme file. It does not write the theme file.
- An automatic sunrise and sunset switch belongs to neither repo.
