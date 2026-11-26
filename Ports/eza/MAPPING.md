# eza: color mapping

For maintainers. The install guide is [README.md](README.md).

The port has two files per variant: `theme.yml` (eza 0.19.2+) and `eza.env`, built into `eza.sh` and `eza.ps1`, which set `LS_COLORS`. eza reads both, and `LS_COLORS` (then `EZA_COLORS`) wins over `theme.yml` (`src/theme/mod.rs`, `parse_color_vars` runs on top of the theme). So every `LS_COLORS` key below uses the same color as its `theme.yml` slot.

Every slot is a foreground. eza has backgrounds, but none is used: the terminal's background stays.

## Color mapping

### theme.yml

| App setting | Color | Why |
|---|---|---|
| `filekinds.normal` | `text` | |
| `filekinds.directory`, `mount_point` (underlined) | `ansi.blue` (steel), bold | eza and `ls` draw folders in ANSI blue, so eza matches `ls` in an Inglenook terminal |
| `filekinds.symlink`, `symlink_path` | `reference` | a link is a reference |
| `filekinds.executable` | `ansi.green` (moss), bold | the ANSI green of `ls` and eza's default, not a success state |
| `filekinds.pipe`, `socket` (bold) | `heather` | special files, kept apart from data files |
| `filekinds.block_device`, `char_device` (bold), `special` | `clay` | |
| `perms.*_read` | `dim` | the most common bit, kept quiet |
| `perms.*_write` | `clay` | eza's default is red; ember means failure, so not ember |
| `perms.*_execute*` | `ansi.green` (moss) | the same as executable files |
| `perms.special_user_file`, `special_other` | `heather` | setuid, setgid, sticky |
| `perms.attribute` | `faint` | metadata |
| `size.number_*`, `major`, `minor`, `octal`, `links.*` | `literal` | numbers. Not bold: eza's defaults bold some, which the theme turns off |
| `size.unit_*` | `dim` | |
| `users.user_you`, `group_yours` | `text` | eza keeps them bold |
| `users.user_root`, `group_root` | `keyword` | |
| `users.user_other`, `group_other` | `dim` | |
| `git.new` | `success` | addition |
| `git.modified` | `warning` | change |
| `git.deleted` | `error` | removal |
| `git.conflicted` | `error`, bold | |
| `git.renamed` | `info` | |
| `git.typechange` | `heather` | |
| `git.ignored` | `faint` | |
| `git_repo.branch_main`, `branch_other` | `reference` | branches are references |
| `git_repo.git_clean`, `git_dirty` | `success`, `warning` | |
| `security_context.*` | `faint`, `dim`, `info` (type) | |
| `file_type.image`, `video` (bold) | `heather` | file groups only tell files apart, so they use colors without a status meaning |
| `file_type.music`, `lossless` (bold) | `dusk` | |
| `file_type.crypto` (bold), `document` | `ivy` | detail color |
| `file_type.compressed` | `oxblood` | detail color; eza's default red would read as an error |
| `file_type.temp`, `compiled` | `faint` | leftovers and build output |
| `file_type.source`, `build` (bold, underlined) | `rosewood` | |
| `punctuation`, `inode`, `blocks` | `faint` | |
| `date` | `info` | eza's default blue |
| `header` | `text`, underlined | |
| `flags` | `dim` | |
| `control_char` | `literal` | an escaped character |
| `broken_symlink` | `error` | |
| `broken_path_overlay` | underline only | |

### LS_COLORS (eza.env)

| Key | Color |
|---|---|
| `di` | `ansi.blue`, bold |
| `ln` | `reference` |
| `ex` | `ansi.green`, bold |
| `pi`, `so` (bold), `do` (bold) | `heather` |
| `bd`, `cd` | `clay`, bold |
| `or`, `mi` | `error` |
| `su`, `sg` | `heather`, bold |
| `tw`, `ow`, `st` | `ansi.blue`, bold and underlined |
| archives (`*.tar`, `*.zip`, ...) | `oxblood` |
| images | `heather` |
| video | `heather`, bold |
| lossy audio | `dusk` |
| lossless audio | `dusk`, bold |
| documents (`*.pdf`, ...) | `ivy` |
| `*.tmp`, `*.swp`, `*.bak` | `faint` |

Values are 24-bit (`38;2;r;g;b`). GNU `ls`, fd (lscolors crate), carapace and Zsh's `list-colors` pass them through.

## Gaps and trade-offs

- `accent` is not used: eza has no focus, cursor or selection.
- `LS_COLORS` has no keys for eza's source and build groups, so `ls` and fd leave those files in the terminal's text color.
- eza reads only the ten `ls` keys from `LS_COLORS`. The others (`do`, `mi`, `su`, `sg`, `tw`, `ow`, `st`) are for GNU `ls`; eza treats them as file name globs, which only matter for a file with exactly that name.
- The screenshots show the stock GNOME Terminal (white in Day, dark gray in Night), because there is no Inglenook GNOME Terminal port to host the shot yet (#6). Not shown: devices, pipes, sockets, setuid bits, root, Git deleted, renamed and conflicted, images, audio, video, documents, SELinux.

## Research

- [Catppuccin for eza](https://github.com/catppuccin/eza): one `theme.yml` per flavor generated from a template, every slot set as a hex foreground, the `colourful` key set. Learned that unset style fields keep eza's defaults (bold), so bold has to be turned off by hand.
- [Rosé Pine](https://github.com/rose-pine/eza), [Dracula](https://github.com/dracula/eza), [eza-themes](https://github.com/eza-community/eza-themes): the same `theme.yml` layout.
- eza source (`src/options/theme.rs`): with no `EZA_CONFIG_DIR`, eza reads `theme.yml` from `dirs::config_dir()/eza`, which is `%APPDATA%` on Windows, `$XDG_CONFIG_HOME` or `~/.config` on Linux, and `~/Library/Application Support` on macOS.
- Ubuntu 24.04 ships eza 0.18, older than `theme.yml` support, so the recipe installs the release binary.

## Screenshot recipe

- eza needs no login or license (MIT, [repository](https://github.com/eza-community/eza)).
- The recipe installs eza 0.23.5 from its GitHub release, checked by sha256, and the stock GNOME Terminal from the package date.
- Stage sets the system monospace font to BlexMono Nerd Font Mono and turns off the cursor blink. Neither is a color.
- The scene (`build/photograph/scenes/cli/eza/`) runs an interactive bash, so the source line the apply steps add to `~/.bashrc` loads `LS_COLORS` as it does for a reader. Not tested by hand on Windows or macOS.
- When the GNOME Terminal port lands, switch the recipe to `"host": "gnome-terminal"` (drop `launch` and `window`) and retake.
