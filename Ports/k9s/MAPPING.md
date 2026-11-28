# K9s: color mapping

For maintainers. The install guide is [README.md](README.md).

One YAML skin per variant, `inglenook-day.yaml` and `inglenook-night.yaml`, every key under `k9s:` set. K9s reads the skin named by `k9s.ui.skin` (or `K9S_SKIN`) from `<config dir>/skins/<name>.yaml`. A key left out keeps K9s's stock color, so every key in `internal/config/styles.go` is set.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `body.bgColor`, every view `bgColor`, `charts.*BgColor` | base | Solid surface |
| `body.fgColor`, table, xray, logs and yaml text | text | |
| `body.logoColor` (the K9s logo, top right) | dim | The logo is large; firelight would be a brand color |
| `body.logoColorMsg`, `logoColorInfo`, `logoColorWarn`, `logoColorError` (flash messages in the logo's place) | text, info, warning, error | By meaning |
| `prompt.bgColor` | raised | An input |
| `prompt.suggestColor` (ghost completion) | faint | Placeholder text |
| `prompt.border.command` (`:` prompt) | accent | Focus is in the prompt |
| `prompt.border.default` (`/` filter prompt) | info | A filter is a search: steel, as matches are (ADR 0009) |
| `help.sectionColor`, `info.sectionColor` (labels such as `Context:`) | dim | Supporting text |
| `help.keyColor`, `menu.keyColor`, `picker.shortcutColor` (keys to press) | info | As btop's `hi_fg`: no role means "key to press" |
| `help.numKeyColor`, `menu.numKeyColor` (`<0>` to `<9>` namespace keys) | literal | Numbers |
| `menu.fgColor` (what a key does) | dim | |
| `frame.title.fgColor` | text | |
| `frame.title.highlightColor` (the namespace in `Pods(cabin)`) | reference | A reference to where the view points |
| `frame.title.counterColor` (`[12]`) | literal | A number |
| `frame.title.filterColor` (`</kettle>`) | info | The active filter, a search |
| `frame.border.fgColor` | line | |
| `frame.border.focusColor` | accent | The focused view |
| `frame.crumbs.fgColor` | text | Text on both crumb fills |
| `frame.crumbs.bgColor` (earlier views) | raised | A chip |
| `frame.crumbs.activeColor` (the current view) | accent wash | "You are here", as a chip |
| `frame.status.newColor` (every ordinary row, running pods included) | text | K9s draws every healthy row of every resource in this color (`model1.StdColor`); green here would make every table green |
| `frame.status.addColor` (a row just added, `PodInitializing`) | success | Addition |
| `frame.status.modifyColor` (a row just changed) | warning | Change |
| `frame.status.pendingColor` (`Pending`, `ContainerCreating`) | warning | Waiting, caution |
| `frame.status.errorColor` (`CrashLoopBackOff`, `Error`, any row K9s finds invalid) | error | Failure |
| `frame.status.killColor` (a row deleted, `Terminating`) | error | Removal |
| `frame.status.highlightColor` (`Initialized`) | info | In progress |
| `frame.status.completedColor` (`Completed`) | faint | Finished and out of the way |
| `info.fgColor`, `cpuColor`, `memColor`, `k9sRevColor` (cluster summary values) | text | Content, no state |
| `table.cursorBgColor`, `xray.cursorColor` | accent wash | The selected row |
| `table.cursorFgColor`, `xray.cursorTextColor` | text | Text on a wash |
| `table.markColor` (rows marked with Space) | accent | Marked rows are part of the selection; K9s colors only their text |
| `table.header.fgColor` | dim | |
| `table.header.sorterColor` (the sort arrow) | info | |
| `table.header.selectedSortColumnColor` | text | Stands out from the dim headers without a color |
| `xray.graphicColor` (tree lines) | dim | Punctuation |
| `yaml.keyColor` | info | Keys, per the syntax mapping |
| `yaml.colonColor` | dim | Punctuation |
| `yaml.valueColor` | text | One color for every value; see Gaps |
| `logs.indicator.fgColor` | dim | |
| `logs.indicator.toggleOnColor`, `toggleOffColor` | success, faint | On and off |
| `charts.defaultDialColors`, `defaultChartColors` (ok, fault) | success, error | By meaning |
| `charts.resourceColors.cpu` | steel, heather | Series only; no state |
| `charts.resourceColors.mem` | pine, ivy | Series only; no state |
| `charts.focusBgColor`, `focusFgColor` | accent, on_accent | The focused chart |
| `picker.mainColor`, `focusColor` | text, accent | |
| `dialog.bgColor` | raised | A popup |
| `dialog.fgColor`, `fieldFgColor` | text | |
| `dialog.labelFgColor` | dim | |
| `dialog.buttonBgColor`, `buttonFgColor` | hover, text | |
| `dialog.buttonFocusBgColor`, `buttonFocusFgColor` | accent, on_accent | The primary, focused button |

## Gaps and trade-offs

- Running pods are `text`, not success. K9s's pod colorer (`internal/render/pod.go`) gives `Running` the standard row color, `frame.status.newColor`, which is also every ordinary row in every view. Moss there would color every healthy table green, so the success color is left to rows just added.
- `modifyColor` and `pendingColor` are both warning, and `killColor` and `errorColor` both error: K9s has more row states than the palette has status roles, and each pair means the same thing.
- `yaml.valueColor` is one key for every value, so strings are not moss: a string color would also paint numbers and booleans.
- K9s colors only the text of a filter match, never a fill, so ADR 0009's wash does not apply; the filter is steel in the title and the prompt border.
- `body.bgColor: default` would make K9s see-through; the README points to it as the reader's own edit.
- Not in the shots yet: shots are taken by hand (see below).

## Research

- [Catppuccin for k9s](https://github.com/catppuccin/k9s) (MIT): one YAML per flavor from one template, every section of `styles.go` set, a separate `-transparent` file per flavor that sets backgrounds to `default`. The layout and key coverage here follow it, with every color remapped by role. Its transparent variants are not shipped (solid only).
- [K9s Skins](https://k9scli.io/topics/skins/): `k9s.ui.skin` in `config.yaml`, skins in the config folder's `skins/`, `K9S_SKIN` overrides, per-context `skin:`, `default` for a transparent background.
- K9s source at v0.51.0: `internal/config/styles.go` (every key and its stock color), `internal/config/files.go` (`AppSkinsDir` is the config folder's `skins/`, not `$XDG_DATA_HOME` as some README comments say), `internal/ui/config.go` (`newColor` becomes `model1.StdColor`), `internal/render/pod.go` (status to color), `internal/ui/crumbs.go` (crumbs share `fgColor`, the last one takes `activeColor` as its fill), `internal/config/json/schemas/skin.json` (lists fewer keys than `styles.go` but allows extra ones below `k9s:`'s sections).
- The skin keys match `styles.go`'s YAML tags; both files parse as YAML.

## Screenshot recipe

- K9s is Apache 2.0 and needs no login or license, but its themed views need a reachable Kubernetes cluster. kind and k3d need a privileged Docker, which the Photographer's container lacks, so the recipe is manual.
- A cheaper automatic path was sketched and not run: etcd and kube-apiserver as plain unprivileged processes (no kubelet or scheduler), pods written with `kubectl apply`, then each pod's status set with `kubectl patch --subresource=status` (Running, Pending, ContainerCreating, CrashLoopBackOff, Error, Completed, and a finalizer held pod for Terminating), and the AGE column hidden with a K9s custom view so the shot holds still. It adds about 240 MB of binaries to the image. Worth trying if the owner wants automatic shots.
- For the hand-taken shot: the pods view (`:pods`, all namespaces) of a cluster with a few running, one pending, one crash looping and one completed pod, the cursor on a running pod.
