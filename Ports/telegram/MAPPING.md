# Telegram Desktop: color mapping

For maintainers. The install guide is [README.md](README.md).

## Layout

- **Frame** (`deeper`): the title bar, the folders side bar, the media viewer, call windows, and the fade behind boxes and menus.
- **Recessed** (`deep`): the chat list, outgoing message bubbles, box dividers, and the open folder in the side bar.
- **Content** (`base`): windows, boxes, settings, the chat header, and the ground of the chat wallpaper.
- **Raised** (`raised`): incoming message bubbles, the message field, menus, tooltips, toasts, date pills, and service messages.
- **Hover** (`hover`): hovered rows and buttons, and the scroll bar track.
- **Washes**: selected messages and text (firelight), search matches (steel), bot and call buttons (moss, ember, steel, brass).

**Chat wallpaper.** Each variant is a `.tdesktop-theme` ZIP holding `colors.tdesktop-theme` and `tiled.png` ([Theme Reference](https://github.com/telegramdesktop/tdesktop/wiki/Theme-Reference)), so Choose from file applies the colors and the wallpaper in one step. The tile is `backdrop-damask.svg` from `assets/ornaments/`, drawn in the oxblood wash on `base` and rendered at 240 px from `template/{{variant.slug}}.tdesktop-theme.zip/tiled.png.svg`. Telegram draws a tile at its pixel size in device pixels (`SectionWidget::PaintBackground` in [`section_widget.cpp`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/window/section_widget.cpp)), so it shows at 120 px on a 2x screen. Full oxblood was tried first and was too busy behind the bubbles; the owner chose the wash, a solid color with no role and no meaning.

**Ornaments.** This port uses an ornament (ADR 0010): the damask chat wallpaper. It is allowed because the theme installs whole as one package file. It is oxblood (as its wash), never firelight or a status color, and it sits only behind solid bubbles and pills, so no text is drawn on the pattern.

**Message bubbles.** Telegram draws bubbles on the chat wallpaper, whose ground is `base`. Incoming bubbles are `raised`, a step lighter than the wallpaper, and outgoing ones are `deep`, a step darker, so the two sides stay apart in both variants without using a color that means something. Both take `text` and `faint` times, and turn into the firelight wash when selected, with `dim` times on the wash. Outgoing ticks are `success`.

**The open chat** in the list is an `accent` fill with `on_accent` text, the same as a selected list row in the other ports. Hovered chats are `hover`.

**Unread badges** are `info` (steel), with `on_accent` text; muted chats get `faint`. An unread count is information. It is not "you are here", so it is not firelight, and it is not a failure or a warning. Mention badges, the tray counter and the folders side bar badge use the same color.

**Online** status is `success`. Drafts in the chat list are `warning`, an unsent change.

**Names and userpics.** Telegram gives each user one of eight colors. They carry no meaning, so they map by nearest hue to named colors that avoid the error and success roles: red rosewood, green ivy, yellow brass, blue steel, purple dusk, pink heather, sea pine, orange clay. Settings icons and file-type colors follow the same hue map.

## Color mapping

The theme sets 396 keys: every key in Telegram's [`colors.palette`](https://github.com/desktop-app/lib_ui/blob/master/ui/colors.palette) whose default is a literal color, plus a few whose default reference would carry the wrong meaning. The other 188 keys default to a reference to another key (for example `activeButtonBg: windowBgActive`), and Telegram resolves them, so they follow the keys set here.

The template keeps Telegram's key order. It was written from `colors.palette` with a script that failed on any literal-color key left unmapped; check the same way when Telegram adds keys.

**Window and widgets**

| Telegram key | Color | Why |
|---|---|---|
| `windowBg` | `base` |  |
| `windowFg`, `windowFgOver`, `windowBoldFg`, `windowBoldFgOver` | `text` |  |
| `windowSubTextFg`, `windowSubTextFgOver` | `dim` | supporting text: last seen, message previews |
| `windowBgOver`, `lightButtonBgOver`, `titleButtonBgOver` | `hover` |  |
| `windowBgRipple`, `lightButtonBgRipple` | `line` | a press shows one step past hover |
| `windowBgActive`, `activeButtonBg`, `activeButtonBgOver`, `activeButtonBgRipple`, `activeLineFg`, `windowActiveTextFg`, `lightButtonFg`, `filterInputBorderFg`, `sliderBgActive` | `accent` | primary buttons, focus lines, links |
| `windowFgActive`, `activeButtonFg`, `activeButtonSecondaryFg` | `on_accent` |  |
| `windowShadowFg`, `windowShadowFgFallback`, `shadowFg`, `titleShadow`, `inputBorderFg`, `menuSeparatorFg`, `sliderBgInactive` | `line` | shadows are solid lines |
| `slideFadeOutBg`, `layerBg` | `deeper` | the fade behind boxes and menus, solid |
| `imageBg` | `deeper` |  |
| `imageBgTransparent` | `raised` |  |
| `activeLineFgError`, `attentionButtonFg`, `attentionButtonFgOver`, `spellUnderline` | `error` |  |
| `attentionButtonBgOver`, `attentionButtonBgRipple` | `error` wash | hover on a destructive button |
| `menuBg`, `filterInputActiveBg`, `filterInputInactiveBg`, `tooltipBg`, `radialBg` | `raised` |  |
| `menuIconFg`, `menuSubmenuArrowFg`, `smallCloseIconFgOver` | `dim` |  |
| `menuIconFgOver`, `tooltipFg` | `text` |  |
| `menuFgDisabled`, `smallCloseIconFg`, `placeholderFg`, `placeholderFgActive`, `checkboxFg` | `faint` |  |
| `scrollBarBg`, `tooltipBorderFg` | `line` |  |
| `scrollBarBgOver` | `faint` |  |
| `scrollBg`, `scrollBgOver` | `hover` | the track, solid |
| `radialFg` | `accent` |  |

**Bot keyboards**

| Telegram key | Color | Why |
|---|---|---|
| `botKbPrimaryBg`, `botKbInlinePrimaryBg` | `accent` wash | washes keep the button text readable |
| `botKbDangerBg`, `botKbInlineDangerBg` | `error` wash |  |
| `botKbSuccessBg`, `botKbInlineSuccessBg` | `success` wash |  |

**Title bar and tray**

| Telegram key | Color | Why |
|---|---|---|
| `titleBg`, `titleBgActive` | `deeper` |  |
| `titleButtonFg`, `titleFgActive` | `dim` |  |
| `titleButtonFgOver` | `text` |  |
| `titleFg` | `faint` |  |
| `titleButtonCloseBgOver` | `error` |  |
| `trayCounterBg` | `info` | unread count is information |
| `trayCounterBgMute` | `faint` |  |
| `trayCounterFg` | `on_accent` |  |

**Boxes, contacts, login**

| Telegram key | Color | Why |
|---|---|---|
| `boxTitleFg` | `text` |  |
| `boxTitleAdditionalFg`, `profileStatusFgOver` | `dim` |  |
| `boxTextFgGood`, `paymentsTipActive`, `contactsStatusFgOnline`, `callArrowFg`, `dialogsOnlineBadgeFg` | `success` | online is success |
| `boxTextFgError`, `callArrowMissedFg` | `error` |  |
| `boxDividerBg`, `introCoverTopBg`, `introCoverBottomBg` | `deep` |  |
| `photoCropPointFg`, `photoEditorItemBaseHandleFg` | `accent` |  |
| `introCoverIconsFg`, `introCoverPlaneTrace` | `line` |  |
| `introCoverPlaneInner` | `faint` |  |
| `introCoverPlaneOuter` | `dim` |  |
| `introCoverPlaneTop` | `raised` |  |

**Chat list**

| Telegram key | Color | Why |
|---|---|---|
| `dialogsBg` | `deep` | recessed beside the chat, like a side bar |
| `dialogsNameFg`, `dialogsTextFgService` | `text` |  |
| `dialogsDateFg`, `dialogsSendingIconFg`, `dialogsUnreadBgMuted` | `faint` |  |
| `dialogsTextFg`, `dialogsArchiveFg`, `dialogsArchiveFgOver` | `dim` |  |
| `dialogsDraftFg` | `warning` | a draft is an unsent change |
| `dialogsScamFg` | `error` |  |
| `dialogsVerifiedIconBg`, `dialogsUnreadBg`, `dialogsMentionIconFg` | `info` | unread badges are information, not "you are here" |
| `dialogsVerifiedIconFg`, `dialogsUnreadFg` | `on_accent` |  |
| `dialogsSentIconFg`, `dialogsSentIconFgOver` | `success` | a sent tick is success |
| `dialogsBgOver` | `hover` |  |
| `dialogsReactionIconFg` | `rosewood` | a detail, not an error |
| `dialogsPollIconFg` | `dusk` |  |
| `dialogsBgActive` | `accent` | the open chat is "you are here" |
| `dialogsNameFgActive`, `dialogsDateFgActive`, `dialogsTextFgActive`, `dialogsDraftFgActive`, `dialogsSendingIconFgActive`, `dialogsOnlineBadgeFgActive` | `on_accent` |  |
| `searchedBarBg` | `hover` |  |
| `searchedTextMatchBg` | `steel` wash | every match (ADR 0009) |
| `searchedTextMatchFg` | `text` |  |
| `searchedTextCurrentMatchBg` | `accent` | the current match |
| `searchedTextCurrentMatchFg` | `on_accent` |  |

**Folders side bar**

| Telegram key | Color | Why |
|---|---|---|
| `sideBarBg` | `deeper` |  |
| `sideBarBgActive` | `deep` | the open folder joins the chat list |
| `sideBarBgRipple` | `line` |  |
| `sideBarTextFg`, `sideBarIconFg` | `dim` |  |
| `sideBarTextFgActive`, `sideBarIconFgActive` | `accent` |  |
| `sideBarBadgeBg` | `info` |  |
| `sideBarBadgeBgMuted` | `faint` |  |
| `sideBarBadgeFg` | `on_accent` |  |

**Emoji and stickers**

| Telegram key | Color | Why |
|---|---|---|
| `emojiPanCategories` | `deep` |  |
| `emojiPanHeaderBg`, `stickerPreviewBg` | `base` |  |
| `emojiIconFg` | `dim` |  |
| `emojiSubIconFgActive` | `text` |  |
| `stickerPanDeleteBg` | `error` |  |
| `stickerPanPremium1`, `stickerPanPremium2`, `premiumIconBg1`, `premiumIconBg2`, `premiumIconBg3` | `oxblood` | premium marks are a detail, one solid color |

**Messages**

| Telegram key | Color | Why |
|---|---|---|
| `msgInBg`, `historyComposeAreaBg` | `raised` | incoming bubbles lift off the chat wallpaper |
| `msgOutBg` | `deep` | outgoing bubbles sit one step below the wallpaper |
| `msgInBgSelected`, `msgOutBgSelected`, `msgServiceBgSelected`, `msgSelectOverlay`, `msgStickerOverlay`, `msgDateImgBgSelected`, `overviewPhotoSelectOverlay` | `accent` wash | selection |
| `msgInServiceFg`, `msgInServiceFgSelected`, `msgOutServiceFg`, `msgOutServiceFgSelected`, `msgOutReplyBarColor`, `msgOutReplyBarSelColor`, `msgFileThumbLinkOutFg`, `msgFileThumbLinkOutFgSelected`, `msgFileInBgOver`, `msgFileInBgSelected`, `msgFileOutBg`, `msgFileOutBgSelected`, `msgWaveformInActiveSelected`, `msgWaveformOutActive`, `msgWaveformOutActiveSelected` | `accent` | clickable names and the play controls |
| `msgInShadow`, `msgInShadowSelected`, `msgOutShadow`, `msgOutShadowSelected`, `msgWaveformInInactive`, `msgWaveformOutInactive`, `msgBotKbRippleBg`, `historyToDownShadow` | `line` |  |
| `msgInDateFg`, `msgOutDateFg`, `historySendingOutIconFg`, `historySendingInIconFg`, `msgWaveformInInactiveSelected`, `msgWaveformOutInactiveSelected`, `mediaPlayerDisabledFg` | `faint` |  |
| `msgInDateFgSelected`, `msgOutDateFgSelected` | `dim` | dim reads on the selection wash |
| `msgServiceFg`, `historyForwardChooseFg`, `youtubePlayIconFg`, `videoPlayIconFg`, `toastFg` | `text` |  |
| `msgServiceBg`, `historyUnreadBarBg`, `toastBg` | `raised` | date pills and service messages |
| `msgInMonoFg`, `msgOutMonoFg` | `literal` | inline code |
| `msgDateImgBg`, `historyForwardChooseBg`, `youtubePlayIconBg`, `videoPlayIconBg`, `overviewCheckBg`, `songCoverOverlayFg` | `deeper` |  |
| `msgDateImgBgOver`, `msgBotKbOverBgAdd` | `hover` |  |
| `historyOutIconFg`, `historyOutIconFgSelected`, `historyCallArrowInFg`, `historyCallArrowInFgSelected` | `success` | read ticks and answered calls |
| `historySendingInvertedIconFg`, `mapPointDot` | `on_accent` |  |
| `historyUnreadBarFg` | `info` |  |
| `mapPointDrop` | `reference` | a place |
| `historyScrollBarBg` | `line` | Telegram retints these to the wallpaper |
| `historyScrollBarBgOver` | `faint` |  |
| `historyScrollBg`, `historyScrollBgOver` | `hover` |  |

**Names, userpics, settings icons**

| Telegram key | Color | Why |
|---|---|---|
| `historyPeer1NameFg`, `historyPeer1UserpicBg`, `historyPeer1UserpicBg2` | `rosewood` | nearest hue; names carry no meaning |
| `historyPeer2NameFg`, `historyPeer2UserpicBg`, `historyPeer2UserpicBg2` | `ivy` |  |
| `historyPeer3NameFg`, `historyPeer3UserpicBg`, `historyPeer3UserpicBg2` | `brass` |  |
| `historyPeer4NameFg`, `historyPeer4UserpicBg`, `historyPeer4UserpicBg2` | `steel` |  |
| `historyPeer5NameFg`, `historyPeer5UserpicBg`, `historyPeer5UserpicBg2` | `dusk` |  |
| `historyPeer6NameFg`, `historyPeer6UserpicBg`, `historyPeer6UserpicBg2` | `heather` |  |
| `historyPeer7NameFg`, `historyPeer7UserpicBg`, `historyPeer7UserpicBg2` | `pine` |  |
| `historyPeer8NameFg`, `historyPeer8UserpicBg`, `historyPeer8UserpicBg2` | `clay` |  |
| `settingsIconBg1` | `rosewood` |  |
| `settingsIconBg2` | `ivy` |  |
| `settingsIconBg3` | `brass` |  |
| `settingsIconBg4` | `steel` |  |
| `settingsIconBg5` | `dusk` |  |
| `settingsIconBg6` | `heather` |  |
| `settingsIconBg8` | `clay` |  |
| `settingsIconBgArchive` | `faint` |  |
| `settingsIconFg`, `historyPeerUserpicFg` | `on_accent` |  |
| `rankAdminFg` | `ivy` | badges use the detail colors |
| `rankOwnerFg`, `profileAdminStartFg` | `oxblood` |  |
| `profileVerifiedCheckBg`, `currencyFg` | `info` |  |

**Files**

| Telegram key | Color | Why |
|---|---|---|
| `msgFile1Bg`, `msgFile1BgDark`, `msgFile1BgOver`, `msgFile1BgSelected` | `steel` | file kinds by nearest hue |
| `msgFile2Bg`, `msgFile2BgDark`, `msgFile2BgOver`, `msgFile2BgSelected` | `ivy` |  |
| `msgFile3Bg`, `msgFile3BgDark`, `msgFile3BgOver`, `msgFile3BgSelected` | `rosewood` |  |
| `msgFile4Bg`, `msgFile4BgDark`, `msgFile4BgOver`, `msgFile4BgSelected` | `brass` |  |
| `mediaviewFileRedCornerFg` | `rosewood` |  |
| `mediaviewFileYellowCornerFg` | `brass` |  |
| `mediaviewFileGreenCornerFg` | `ivy` |  |
| `mediaviewFileBlueCornerFg` | `steel` |  |

**Media viewer**

| Telegram key | Color | Why |
|---|---|---|
| `mediaviewBg` | `deeper` |  |
| `mediaviewMenuBg`, `mediaviewControlBg`, `mediaviewCaptionBg`, `mediaviewTransparentBg` | `raised` |  |
| `mediaviewMenuBgOver`, `mediaviewTransparentFg` | `hover` |  |
| `mediaviewMenuBgRipple`, `mediaviewPlaybackInactive`, `mediaviewPlaybackIconRipple`, `mediaviewPipPlaybackInactive` | `line` |  |
| `mediaviewMenuFg`, `mediaviewControlFg`, `mediaviewPlaybackProgressFg`, `mediaviewPlaybackIconFg`, `mediaviewPlaybackIconFgOver`, `mediaviewPipControlsFg`, `mediaviewPipControlsFgOver` | `text` |  |
| `mediaviewTextLinkFg`, `mediaviewPlaybackActive`, `mediaviewPlaybackActiveOver`, `mediaviewPipPlaybackActive` | `accent` |  |
| `mediaviewPlaybackInactiveOver` | `faint` |  |

**Calls**

| Telegram key | Color | Why |
|---|---|---|
| `callBg`, `callBgOpaque`, `callBgButton`, `groupCallBg` | `deeper` |  |
| `callNameFg`, `callIconFg`, `callIconBgActive`, `groupCallMembersFg`, `groupCallIconFg`, `groupCallVideoTextFg` | `text` |  |
| `callStatusFg`, `callIconActiveRipple`, `groupCallVideoSubTextFg` | `dim` |  |
| `callIconBg`, `groupCallMenuBg` | `raised` |  |
| `callIconFgActive` | `base` | the muted button inverts |
| `callMuteRipple`, `groupCallMembersBgRipple`, `groupCallMenuBgRipple`, `callBarMuteRipple` | `line` |  |
| `callAnswerBg`, `callAnswerRipple`, `callAnswerBgOuter`, `groupCallLive1`, `groupCallLive2` | `success` wash | washes keep the icons readable |
| `callHangupBg`, `callHangupRipple`, `groupCallLeaveBg`, `groupCallLeaveBgRipple` | `error` wash |  |
| `groupCallActiveFg` | `accent` |  |
| `groupCallMembersBg` | `deep` |  |
| `groupCallMembersBgOver`, `groupCallMenuBgOver`, `callBarBgMuted` | `hover` |  |
| `groupCallMemberActiveIcon`, `groupCallMemberActiveStatus` | `success` | speaking |
| `groupCallMemberInactiveIcon`, `groupCallMemberNotJoinedStatus` | `faint` |  |
| `groupCallMemberInactiveStatus` | `info` | listening |
| `groupCallMemberMutedIcon` | `error` |  |
| `groupCallMuted1`, `groupCallMuted2`, `callBarBg` | `steel` wash | a call in progress is information |
| `groupCallForceMutedBar1`, `groupCallForceMutedBar2`, `groupCallForceMutedBar3`, `groupCallForceMuted1`, `groupCallForceMuted2`, `groupCallForceMuted3` | `warning` wash | muted by an admin is a caution |
| `callBarFg` | `text` |  |

**Notifications settings**

| Telegram key | Color | Why |
|---|---|---|
| `notificationsBoxScreenBg` | `deep` |  |
| `notificationSampleUserpicFg`, `notificationSampleCloseFg`, `notificationSampleNameFg` | `faint` |  |
| `notificationSampleTextFg` | `line` |  |

**Other**

| Telegram key | Color | Why |
|---|---|---|
| `outdatedFg`, `premiumButtonFg` | `on_accent` |  |
| `outdateSoonBg` | `warning` |  |
| `outdatedBg` | `error` |  |
| `premiumButtonBg1`, `premiumButtonBg2`, `premiumButtonBg3` | `accent` | a primary button, one solid color |
| `statisticsChartInactive` | `hover` |  |
| `statisticsChartActive` | `line` |  |
| `statisticsChartLineRed` | `ember` | ten distinct named colors |
| `statisticsChartLineOrange` | `clay` |  |
| `statisticsChartLineGolden` | `brass` |  |
| `statisticsChartLineGreen` | `moss` |  |
| `statisticsChartLineLightgreen` | `ivy` |  |
| `statisticsChartLineCyan` | `pine` |  |
| `statisticsChartLineLightblue` | `steel` |  |
| `statisticsChartLineBlue` | `dusk` |  |
| `statisticsChartLineIndigo` | `rosewood` |  |
| `statisticsChartLinePurple` | `heather` |  |
| `creditsBg1`, `creditsBg2`, `creditsBg3`, `creditsFg` | `brass` | Stars are gold |
| `creditsStroke` | `clay` |  |
| `walletTitleBg` | `deeper` |  |
| `walletTitleButtonFg`, `walletSubBalanceFg` | `dim` |  |
| `walletTitleButtonBgOver`, `mainMenuCloudBg` | `hover` |  |
| `walletTitleButtonFgOver`, `walletBalanceFg`, `mainMenuCloudFg` | `text` |  |
| `walletTopBg` | `deep` |  |
| `walletTopLabelFg` | `faint` |  |
| `walletTopIconRipple` | `line` |  |

**Left to Telegram**

| Telegram key | Why |
|---|---|
| `trayCounterBgMacInvert`, `trayCounterFgMacInvert` | drawn on the macOS menu bar, whose color the theme does not know; the text is a cut-out that needs transparency |

## Gaps and trade-offs

- **Telegram retints six keys to a wallpaper that is not the theme's own.** With the theme's damask, `adjustPaletteRequired` returns false for a non-default theme, so every key is exactly the palette. If the user picks another wallpaper, Telegram moves `msgServiceBg`, `msgServiceBgSelected` and the four `historyScroll*` keys toward that wallpaper's average color (`adjustPaletteUsingColor` in [`window_theme.cpp`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/window/themes/window_theme.cpp)). Date pills and service messages keep their own solid fill either way.
- **Overlays are solid.** Telegram's defaults for the fade behind boxes (`layerBg`), the slide fade, the photo crop fade, the selected-photo overlay and the media viewer background are translucent. Here they are solid, so a box or menu hides the window behind it, and a selected photo shows as the selection wash instead of a tinted photo.
- **Gradients are one color.** Premium buttons and icons, group call buttons and the second userpic color take the same color at both ends.
- **Shadows are `line`.** Telegram tints its soft shadow images with the shadow colors, so shadows become soft `line` edges.
- **`windowActiveTextFg` is shared.** Telegram uses it for links and light buttons, and as the fallback for other "active" text. It is `accent` for the links. Online status in lists and boxes has its own keys (`contactsStatusFgOnline`, `dialogsOnlineBadgeFg`), set to `success`; any online text Telegram draws with `windowActiveTextFg` shows in firelight.
- **The main menu cover** follows `dialogsBgActive`, so it is the accent fill, as in Telegram's own themes.
- **Other apps.** Telegram for Android, iOS and the separate macOS app use other theme formats and are not covered.
- **Not seen yet.** No screenshot exists, so no row of the table has been checked in the app.

## Research

- **Catppuccin for Telegram** ([catppuccin/telegram](https://github.com/catppuccin/telegram), MIT, studied at commit `25e4ddb`). Its desktop theme is a plain palette text file rendered from a template (`templates/desktop.tera`), not a zip, and it is distributed as `t.me/addtheme` cloud links. From it: a palette file alone is enough, values can reference other keys, and the chat list, bubbles, side bar and call colors are worth setting. Not taken: its extra palette keys, its translucent values, and its colors. Its theme lines end without the `;` that Telegram's parser expects; this port follows Telegram's source instead.
- **Packaged form.** `loadBackground` in `window_theme.cpp` reads `background.jpg`, `background.png`, `tiled.jpg` or `tiled.png` from the zip, in that order; a `tiled` name repeats the image. The build packs the zip from a `<name>.zip/` template folder, stored and dated so a rebuild gives the same bytes.
- **Format, from Telegram's source.** `ReadPaletteValues` and `readNameAndValue` in [`window_theme.cpp`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/window/themes/window_theme.cpp) strip `//` and `/* */` comments, then read `key: value;` pairs, where the value is `#rrggbb`, `#rrggbbaa`, or another key. `ReadPaletteContent` reads `colors.tdesktop-theme` (or `colors.tdesktop-palette`) from a zip, and reads the whole file as the palette when it is not a zip.
- **Applying a file.** Settings > Chat Settings > Choose from file accepts `*.tdesktop-theme` and `*.tdesktop-palette` and applies either as a theme (`ChooseFromFile` in [`settings_chat.cpp`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/settings/sections/settings_chat.cpp)). A palette file sent in a chat opens as a theme too (`DocumentData::isTheme` in [`data_document.cpp`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/data/data_document.cpp)).
- **Day and Night.** Telegram keeps one saved theme for day mode and one for night mode (`_themeKeyDay` and `_themeKeyNight` in [`localstorage.cpp`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/SourceFiles/storage/localstorage.cpp)), and the main menu's Night Mode switch and Auto-night mode swap between them (`reapplyWithNightMode`). So the README applies Day in day mode and Night in night mode, once each.
- **Keys.** Every key and its meaning come from Telegram's [`colors.palette`](https://github.com/desktop-app/lib_ui/blob/master/ui/colors.palette) in desktop-app/lib_ui. Telegram's own [night theme](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/Resources/night.tdesktop-theme) was read to see which keys a dark theme sets.
- Menu names are from [`lang.strings`](https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/Resources/langs/lang.strings): Chat Settings, Chat wallpaper, Choose from file, Keep changes, Night Mode, Auto-night mode, Font family.

## Screenshot recipe

- **Manual.** Telegram Desktop requires signing in with a phone number before it shows any chat ([Telegram FAQ](https://telegram.org/faq), [Terms of Service](https://telegram.org/tos)). There is no guest or demo mode, and a login never goes in a recipe.
- **Scene kind.** No scene kind fits a chat app. The recipe uses `document`, which has no staged content yet, so the Photographer asks for shots that match the other ports. A suggested scene: the chat list with a few chats (one open, one unread, one muted) and an open chat with incoming and outgoing messages, a link, a reply, and one selected message, on the theme's damask wallpaper.
- Not tested by hand yet.
