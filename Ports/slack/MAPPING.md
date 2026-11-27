# Slack: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

The import string is four colors, in this order:

| App setting | Color | Why |
|---|---|---|
| System navigation | deeper | The window frame and sidebar behind the message pane: the area behind panels |
| Selected items | accent | The channel or item you are on: "you are here" |
| Presence indication | success | The active dot means someone is online and available, the closest fit to success |
| Notifications | oxblood | The mention badge. A mention is not a failure, so not ember; it is not "you are here", so not firelight; and it is not a caution, so not brass. Oxblood is the detail color for badges and carries no meaning. The badge also shows a count, so color is not its only signal |

Slack sets every other color itself (text, message pane, buttons), from its Light or Dark Color Mode. The README pairs Day with Light and Night with Dark, and turns off Window gradient so the frame stays solid.

## Gaps and trade-offs

- Tier 3: Slack's current design exposes only four colors. Text color was a slot in the legacy format and is gone; Slack picks it.
- Slack says on import that it adapts the colors "as best we can to preserve contrast", so the drawn colors can differ from the file. The screenshots will show how far.
- Day's System navigation is a light color, so Darker sidebars must be off; with it on, Slack darkens the sidebar away from the palette. Night's is dark, so the checkbox makes little difference.
- Window gradient blends the frame color into a gradient. The README turns it off (solid surfaces only).
- A theme is per workspace and does not follow the OS color mode.
- Colors the screenshots may not show: the presence dot needs a member who is online, and the mention badge needs an unread mention in another channel. The shot should include both if the workspace has them.

## Research

- [Catppuccin for Slack](https://github.com/catppuccin/slack) (MIT, Copyright (c) 2021 Catppuccin): one comma-separated string per flavor in its README, generated from a whiskers template. Its strings are the legacy 10-color sidebar format, and its README notes the redesign maps them to Slack's built-in colors. Learned: ship one paste line per variant and tell the reader to set light mode for the light flavor. The install steps here are adapted from its README. No colors or names were taken.
- The official help article ([Change your Slack theme](https://slack.com/help/articles/205166337-Change-your-Slack-theme)) gives the path Preferences > Appearance > Custom theme, the Theme Colors Share and Import theme buttons, "Paste your legacy theme colors", and the Window gradient and Darker sidebars preferences. It does not name the four slots or their order.
- The slot names and order (System navigation, Selected items, Presence indication, Notifications) and what the importer accepts come from a third-party test write-up, [slack.green: Slack Themes](https://slack.green/en/blog/slack-themes): 4 colors accepted, each with `#`; 8 (legacy) and 10 (legacy with text colors) also accepted, Slack keeping four of them; the Share button copies a sentence ("Check out my Slack theme: ...") that must be trimmed to the colors before importing. Confirm the order against Slack's own Custom theme panel when taking the screenshots: Share copies the four colors in slot order.
- Color Mode (Light, Dark, System) is under Preferences > Appearance, per [Use dark mode in Slack](https://slack.com/help/articles/360019434914-Use-dark-mode-in-Slack).

## Screenshot recipe

- Manual recipe. Slack requires signing in to a workspace before any themed screen appears; there is no guest or offline mode ([Slack's sign-in help](https://slack.com/help/articles/212681477-Sign-in-to-Slack), [User Terms of Service](https://slack.com/terms-of-service/user)). A login never goes in a recipe.
- The scene kind is `web`, the nearest of the existing kinds: Slack is a web app in a desktop shell. Its staged demo page does not fit a chat app, so the shot is of a real Slack workspace window over the variant's backdrop, with a sidebar showing a selected channel and, where possible, an online member and an unread mention.
- No recipe step stands in for a reader step.
