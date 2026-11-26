#!/usr/bin/env bash
# The web scene's browser: the Photographer's pinned Chromium (pins.json) as an app
# window, so no toolbar shows, with the stock window frame, 1200x660 in the middle of
# the 1600x1000 screen, at scale 1. No first-run page, no sign-in or sync, no
# updates, no network of its own. It never changes a color: the page decides them.
# Launch it with: bash "$INGLENOOK_SCENE/browser.sh" <url>
set -euo pipefail
url=${1:?usage: browser.sh <url>}

# A seeded profile: first run done, and the system frame instead of Chromium's own.
profile=$HOME/.config/chromium
mkdir -p "$profile/Default"
touch "$profile/First Run"
printf '{"browser":{"custom_chrome_frame":false}}\n' > "$profile/Default/Preferences"

# Chromium places its own window, so --window-position puts the frame where the
# window manager centers every other port (the frame adds 5 px a side and a 42 px title bar). --no-sandbox and --disable-gpu are needed
# in the container; --test-type hides the bar that warns about --no-sandbox.
exec chromium --no-sandbox --test-type --disable-gpu --no-first-run --no-default-browser-check \
  --password-store=basic --disable-background-networking --disable-component-update --disable-sync \
  --disable-features=Translate,MediaRouter --hide-scrollbars --force-device-scale-factor=1 \
  --force-color-profile=srgb --user-data-dir="$profile" \
  --window-position=200,188 --window-size=1200,660 --app="$url"
