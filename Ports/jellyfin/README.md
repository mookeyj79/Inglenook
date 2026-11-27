# Inglenook for Jellyfin

**Tier:** 2 Partial\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

## Before you start

- Jellyfin 12 or later, opened in a web browser or another app that uses Jellyfin Web. The theme follows the colors Jellyfin's own themes are built on since 12.0.
- An account on the server. To theme the server for every user, an administrator account.

## Install

This installs the theme for your own account. To install it for everyone, see [Install for every user](#install-for-every-user).

1. Open the file for the variant you want (listed below) on GitHub, select **Raw**, and copy all of its text.
2. In Jellyfin, sign in, open the user menu at the top right, and select **Settings**.
3. Select **Display**.
4. Set **Display mode** to **Desktop (Legacy)**, **Mobile (Legacy)**, or **TV**. The theme is made for these layouts.
5. Set **Theme** to **Light** for Inglenook Day or **Dark** for Inglenook Night.
6. Paste the text into **Custom CSS code**.
7. Select **Save**, then reload the page.

The page now has a warm, solid background, and links, focused fields, and the **Save** button are amber.

Files to use:

- Inglenook Day: `dist/day/jellyfin.css`
- Inglenook Night: `dist/night/jellyfin.css`

### Install for every user

The server's custom CSS applies to every user on every device that uses Jellyfin Web, including the sign-in page. It holds one variant.

1. Copy the text of one file, as in step 1 above.
2. Sign in with an administrator account and open **Dashboard**.
3. Select **Branding**.
4. Paste the text into **Custom CSS**.
5. Select **Save**, then reload the page.

A user can still put the other variant in their own **Custom CSS code** and turn on **Disable server-provided custom CSS code** under **Settings** > **Display**.

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex) for code and terminals. Jellyfin Web shows no code, so the theme keeps Jellyfin's own font. If you want IBM Plex anyway, add this line at the end of your custom CSS. It works only on devices that have the font installed:

```css
html, body, button, input, select, textarea { font-family: "IBM Plex Sans", sans-serif; }
```

## Check that it worked

Open **Settings** > **Display** again. The page background is the soft Day or smoked-walnut Night background, and the **Save** button is amber.

## Switch between Day and Night

1. Copy the text of the other file.
2. Open **Settings** > **Display**, replace everything in **Custom CSS code** with it, and select **Save**.
3. Set **Theme** to match (**Light** for Day, **Dark** for Night), and reload the page.

Jellyfin cannot follow your device's light or dark setting, so switching is by hand.

## Make it see-through (optional)

Turn on **Backdrops** under **Settings** > **Display**. Jellyfin then shows a title's artwork faintly behind its page. The theme itself stays solid.

## Uninstall

1. Open **Settings** > **Display** (or **Dashboard** > **Branding** for the server-wide copy).
2. Delete the text in **Custom CSS code** (or **Custom CSS**).
3. Select **Save** and reload the page.

## Troubleshooting

- **Nothing changed**: reload the page. If the server has its own custom CSS, it may hide yours: turn on **Disable server-provided custom CSS code** under **Settings** > **Display**.
- **Only some colors changed**: check **Display mode**. The theme is made for the Legacy and TV layouts.
- **A Jellyfin app on a TV or phone is not themed**: custom CSS only applies to Jellyfin Web. Apps with their own interface ignore it.

## Known limits

- The theme is made for the **Desktop (Legacy)**, **Mobile (Legacy)**, and **TV** layouts. The default layout in Jellyfin 12 picks up the main background, text, and accent, but some of its hover and selection tints stay Jellyfin's own blue.
- Custom CSS is only used by Jellyfin Web. Apps with their own interface, such as some TV apps, keep their own colors.
- Movie and show artwork, and backdrops when **Backdrops** is on, are images and keep their own colors.
- A new Jellyfin release can rename parts of the page. If something looks unthemed after an update, the theme may need a fix.

## Sources

- [Jellyfin docs: CSS Customization](https://jellyfin.org/docs/general/clients/css-customization/)
- [Jellyfin 12.0 release notes](https://jellyfin.org/posts/jellyfin-release-12.0/)
- The list of page parts this theme colors is adapted from [Catppuccin for Jellyfin](https://github.com/catppuccin/jellyfin), [MIT License](https://github.com/catppuccin/jellyfin/blob/main/LICENSE), Copyright (c) 2021 Catppuccin. Its license notice is at the top of each CSS file.
