# Solid first, transparency optional

Every Inglenook surface is a solid color, and the contrast floor is measured on solid surfaces only. Many apps cannot do transparency at all, and where they can, what shows through is the user's wallpaper, which the theme cannot know. A theme that depended on it would read differently on every desk.

Transparency is an app setting a user may turn on for themselves. A port README may say where that setting is, as an optional extra. The theme never sets it and never counts on it.

## Consequences

- The palette has no transparency values, and the build has no filters for them. The one exception is `|clear`, a fully transparent color for app settings that can only be switched off with a color.
- Highlights that need to show text through them (selections, diff lines) use a wash: a named color mixed into `base` as a solid color.
- Wallpapers are optional and never affect readability.
