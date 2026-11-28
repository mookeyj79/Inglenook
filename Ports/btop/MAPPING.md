# btop++: color mapping

For maintainers. The install guide is [README.md](README.md).

One `.theme` file per variant, `theme[key]="#rrggbb"` lines. btop reads only the keys it knows and skips `#` comment lines; a missing key falls back to btop's default theme, so every key is set.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `main_bg` | base | Solid surface |
| `main_fg`, `title` | text | |
| `hi_fg` (shortcut letters, box numbers) | info | No role means "key to press". Steel reads as information without competing with the accent, as fzf's matches do |
| `selected_bg` | accent wash | The selected process row |
| `selected_fg` | text | |
| `inactive_fg` | faint | |
| `graph_text` (uptime, net scale) | dim | |
| `meter_bg` (empty part of meters) | line | |
| `proc_misc` (process details: running state, memory graph) | info | In progress |
| `cpu_box`, `mem_box`, `net_box`, `proc_box`, `div_line` | line | Borders carry no meaning |
| `cpu_*`, `process_*` | info | CPU activity, in progress |
| `temp_*` | clay | A warm color for heat, not a state |
| `used_*` | rosewood | Memory groups only tell series apart, so they use colors without a status meaning |
| `available_*` | pine | |
| `cached_*` | dusk | |
| `free_*` | heather | |
| `download_*` | pine | |
| `upload_*` | heather | |
| `proc_pause_bg` (1.4+) | warning wash | Paused: caution |
| `proc_follow_bg`, `followed_bg` (1.4+) | info wash | |
| `proc_banner_bg` (paused and following, 1.4+) | keyword wash | |
| `proc_banner_fg`, `followed_fg` | text | Text on a wash |

## Gaps and trade-offs

- btop builds 101-step gradients between each graph's `_start`, `_mid` and `_end`. Blends between palette colors would be colors the palette lacks, so all three are the same color and each graph is flat. A load gradient (moss, brass, ember) would also give ember to high load, which is not a failure.
- btop's own process list still blends two palette colors: rows fade from `main_fg` to `inactive_fg` (`proc_gradient`), and CPU and memory values from `inactive_fg` to `process_start` (`proc_colors`). These are app settings, left at their defaults.
- `accent` appears only as the selected row's wash: btop has no cursor or focus color.
- Not in the shots: `proc_misc` (the detailed view is closed), the pause and follow banners and the followed row (btop 1.4+, the scene runs 1.3.0), disks (hidden, see below), net graphs with traffic (the scene's machine has none), and the 256-color fallback.

## Research

- [Catppuccin](https://github.com/catppuccin/btop): one theme per flavor, every key set as hex. Uses three-stop gradients across different hues.
- [Rosé Pine](https://github.com/rose-pine/btop): sets `_start`, `_mid` and `_end` to one color for memory meters, the method used here for every graph.
- [Tokyo Night](https://github.com/folke/tokyonight.nvim/tree/main/extras/btop): same layout, one gradient for all graphs.
- btop source (`src/btop_theme.cpp`): the key list, `#` comment lines skipped, unknown keys ignored, an empty `main_bg` means the terminal's background, an empty `_mid` or `_end` gives a two-stop or flat gradient. `proc_pause_bg`, `proc_follow_bg`, `proc_banner_*` and `followed_*` are in 1.4.x, not 1.3.0.
- `color_theme` matches a theme file by full path, file name or stem (`setTheme`), so `inglenook-day` works.

## Screenshot recipe

- btop needs no login or license (Apache 2.0).
- btop 1.3.0, proot and tcc come from the pinned Ubuntu snapshot, so the recipe has no `version`. The host is the GNOME Terminal port.
- btop shows live data, so the scene (`build/photograph/scenes/cli/btop/`) gives it a fixed machine: `machine.py` builds a small `/proc` and `/sys` that proot lays over the real ones, with FIFOs for the busy processes so the graphs move one sample per btop update. After 170 updates `/proc/stat` becomes a FIFO nothing writes, btop's next read waits, and the screen holds still. `loadavg.c` (built with tcc, preloaded) fixes the load average, which glibc reads from the kernel. libfaketime fixes the clock. taskset holds btop to one real CPU so the machine's four cores decide the count. Disks and the battery are hidden in `btop.conf`; their numbers come from the real filesystem.
- Stage sets `update_ms`, the clock format, the net interface, the sort, and presses Down once to select the top process: not tested by hand.
