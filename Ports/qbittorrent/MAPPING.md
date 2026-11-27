# qBittorrent: color mapping

For maintainers. The install guide is [README.md](README.md).

The port is a theme folder per variant, `config.json` plus a small `stylesheet.qss` (qBittorrent loads a folder when its custom theme path ends in `config.json`). No `.qbtheme`, so no `rcc` build step.

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `Palette.Window` | deep | toolbar, filter side panel frame, dialogs: recessed around the lists |
| `Palette.Base` | base | the transfer list and other lists, where content lives |
| `Palette.AlternateBase` | raised | alternating rows |
| `Palette.Text`, `WindowText`, `ButtonText`, `ToolTipText` | text | |
| `Palette.Button`, `ToolTipBase` | raised | lifted surfaces |
| `Palette.BrightText` | on_accent | Qt's text for strong fills |
| `Palette.Highlight` | accent wash | the selection is a firelight wash |
| `Palette.HighlightedText` | text | text keeps its color on the wash |
| `Palette.Link`, `LinkVisited` | accent | no role for a visited link |
| `Palette.Light` | raised | Fusion bevels |
| `Palette.Midlight` | hover | |
| `Palette.Mid`, `Dark`, `Shadow` | line | frames and dividers carry no meaning |
| `Palette.*Disabled` | faint | |
| `Log.TimeStamp` | faint | metadata |
| `Log.Normal` | text | |
| `Log.Info` | info | |
| `Log.Warning` | warning | |
| `Log.Critical`, `Log.BannedPeer` | error | |
| `RSS.ReadArticle` | dim | |
| `RSS.UnreadArticle` | text | |
| `TransferList.Downloading`, `ForcedDownloading`, `DownloadingMetadata`, `ForcedDownloadingMetadata` | info | in progress |
| `TransferList.CheckingDownloading`, `CheckingUploading`, `CheckingResumeData`, `Moving` | info | in progress |
| `TransferList.Uploading`, `ForcedUploading` | success | complete and seeding |
| `TransferList.StoppedUploading` | success | complete, stopped |
| `TransferList.StalledDownloading`, `StalledUploading` | warning | stalled: no peers |
| `TransferList.QueuedDownloading`, `QueuedUploading` | dim | waiting its turn, no meaning |
| `TransferList.StoppedDownloading` | faint | stopped and incomplete: quiet |
| `TransferList.MissingFiles`, `Error` | error | failure |
| `ProgressBar`, QSS `QProgressBar::chunk` | info wash | progress is "in progress", not "you are here"; a wash keeps the percentage readable on it |
| QSS `QWidget` color, selection | text, accent wash | qBittorrent sets the palette for the active window only; without this, a background window falls back to Qt's default colors |
| QSS `QProgressBar` | base, line, text | |
| QSS `QToolTip` | raised, text, line | |
| `PiecesBar.Piece` | info | |
| `PiecesBar.PartialPiece` | info wash | a piece being downloaded |
| `PiecesBar.MissingPiece` | base | |
| `PiecesBar.Border` | line | |

## Gaps and trade-offs

- Icons are qBittorrent's own. A theme can replace them (`icons/` in the folder), but recoloring the whole icon set is beyond a color port.
- The stylesheet is kept small: with the Fusion style the palette reaches menus, tabs, headers, and inputs. Other styles (the macOS style, Windows' native styles) ignore parts of the palette, so the README asks for Fusion. Fusion is the default on Windows.
- `Palette.*` keys are read only from the `colors` section (qBittorrent reads palette overrides from its light-mode colors), so one `config.json` cannot carry both variants. Each variant is its own folder.
- The Web UI is a separate HTML/CSS app and is out of scope.
- The scene cannot show: the error and missing-files states (ember), downloading with peers, checking, moving, and queued states, the log, RSS, and the pieces bar (these need a network, a timing window, or another tab).

## Research

- Catppuccin for qBittorrent (github.com/catppuccin/qbittorrent): a `.qbtheme` per flavor, built with `rcc` from `config.json`, a large `stylesheet.qss`, and SVG icons. Learned the full `colors` key list in practice and that the palette alone carries most of the window; their stylesheet mainly restyles menus, tabs, and check boxes.
- qBittorrent 5.3.1 source, `src/gui/uithemecommon.h` and `uithemesource.cpp`: the color keys (5.0 renamed `Paused*` to `Stopped*` and added `ForcedDownloadingMetadata`, `PiecesBar.*`, `ProgressBar`), the `colors`, `colors.light`, and `colors.dark` sections, and `FolderThemeSource`. `uithememanager.cpp`: a theme path ending in `config.json` loads that folder; `.qbtheme` loads a resource bundle.
- `src/base/preferences.cpp`: `Appearance/Style` defaults to Fusion on Windows and to the system style elsewhere.

## Screenshot recipe

- qBittorrent needs no login or license (GPL-2.0-or-later). The legal notice is accepted through `LegalNotice\Accepted` in `qBittorrent.conf`.
- The recipe uses the official 5.3.1 AppImage, extracted, since Ubuntu 24.04 ships 4.6.
- Apply writes `UseCustomUITheme`, `CustomUIThemePath`, and `Appearance\Style=Fusion` to `qBittorrent.conf` instead of using the Options dialog: not tested by hand.
- The scene (`build/photograph/scenes/app/qbittorrent/`) makes four private torrents with no trackers from fixed local files and a trackerless magnet, with DHT, LSD, and PeX off, under a fixed clock (`faketime`), so nothing reaches the network.
