#!/usr/bin/env bash
# One take of one variant, inside a fresh container, as the ordinary user.
# photograph.ps1 writes /work/steps.sh and /work/scene.env, mounts the repo read-only at
# /inglenook, and runs this. It leaves the settled screen in /work/root.png and the
# window frame's geometry in /work/frame.env. All cropping happens outside.
# A desktop recipe is shot by desktop.sh instead.
set -euo pipefail
# shellcheck source=/dev/null
source /work/scene.env   # KIND, SCREEN, BACKDROP_KIND, BACKDROP, GTK_THEME, WINDOW_KIND, WINDOW_MATCH, SETTLE, TIMEOUT, RECIPE
# A desktop brings its own session, window manager and compositor, and has no window to find.
[ "$KIND" = desktop ] && exec bash /inglenook/build/photograph/linux/desktop.sh

fail() { echo "photograph: $*" >&2; exit 1; }
export DISPLAY=:99 XDG_RUNTIME_DIR=/tmp/xdg-$UID GTK_THEME
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

# -noreset, or the backdrop is wiped when hsetroot exits.
Xvfb :99 -screen 0 "${SCREEN}x24" -noreset >/tmp/xvfb.log 2>&1 &
until xdpyinfo >/dev/null 2>&1; do sleep 0.1; done
# The backdrop: a plain palette fill, or a wallpaper filling the screen.
case "$BACKDROP_KIND" in
  fill) hsetroot -solid "$BACKDROP" >/dev/null ;;
  image) hsetroot -fill "/inglenook/$BACKDROP" >/dev/null ;;
  *) fail "unknown backdrop kind '$BACKDROP_KIND'." ;;
esac

# The compositor before any app, so GTK picks an ARGB visual.
picom --config /inglenook/build/photograph/linux/picom.conf >/tmp/picom.log 2>&1 &
picom=$!
until xwininfo -root -children | grep -q '"picom"'; do
  kill -0 "$picom" 2>/dev/null || { cat /tmp/picom.log >&2; fail "picom did not start. Check build/photograph/linux/picom.conf."; }
  sleep 0.1
done
# The stock frame: Adwaita, in the variant's mode through GTK_THEME. Mint's
# /etc/gtk-3.0/settings.ini names Yaru, which is not installed.
mkdir -p ~/.config/gtk-3.0
printf '[Settings]\ngtk-theme-name=Adwaita\ngtk-cursor-blink=false\n' > ~/.config/gtk-3.0/settings.ini

# Inside the session, our own messages go to fd 3; the session's services are noisy on stderr.
dbus-run-session -- bash -c '
  set -euo pipefail
  fail() { echo "photograph: $*" >&3; exit 1; }
  # A title bar and focus, with compositing left to picom. New windows open in
  # the middle of the screen, so every take puts it in the same place.
  gsettings set org.gnome.metacity placement-mode center
  metacity --no-composite --replace >/tmp/wm.log 2>&1 &
  until xprop -root _NET_SUPPORTING_WM_CHECK 2>/dev/null | grep -q "window id"; do sleep 0.1; done

  # The pointer in a corner, off every window, so no app shows a hover state.
  xdotool mousemove 0 0
  bash /work/steps.sh 2>&3 || exit 1

  # Poll for the window: xdotool search --sync dies with BadWindow when a window
  # vanishes mid-walk. Take the newest visible match. A class matches either
  # part of WM_CLASS (instance or class).
  search() {
    if [ "$WINDOW_KIND" = title ]; then xdotool search --onlyvisible --name "$WINDOW_MATCH"
    else xdotool search --onlyvisible --classname "$WINDOW_MATCH"; xdotool search --onlyvisible --class "$WINDOW_MATCH"; fi
  }
  wid=; start=$SECONDS
  until [ -n "$wid" ]; do
    if (( SECONDS - start >= TIMEOUT )); then
      for log in /tmp/step-*-launch-*.log; do [ -s "$log" ] && { echo "${log#/tmp/step-}:"; tail -n 20 "$log" | sed "s/^/    /"; }; done >&3
      fail "no window matching $WINDOW_KIND \"$WINDOW_MATCH\" after ${TIMEOUT}s. Check window and launch in $RECIPE."
    fi
    sleep 0.2
    wid=$(search 2>/dev/null | tail -1 || true)
  done

  xdotool windowactivate "$wid" 2>/dev/null || true
  # The stock frame in the variant'"'"'s mode: metacity draws the dark frame only for a window
  # that asks for it, and some apps (Chromium) never ask. Before the settle wait, so it is drawn.
  case "$GTK_THEME" in *:dark) xprop -id "$wid" -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT dark ;; esac

  # Wait for pixels, not time: the screen the same for SETTLE seconds, grabs at least
  # 500 ms apart. An app can change on its own a few seconds after it looks done.
  # Stillness is timed by the clock, from the end of the grab that first showed the
  # screen as it is to the start of the latest grab that still shows it, never by a
  # count of grabs: picom repaints the whole screen on every frame (use-damage off),
  # which keeps a slow X server busy, so one grab can take seconds.
  now() { echo "${EPOCHREALTIME/./}"; }   # microseconds
  start=$SECONDS; n=0
  import -window root /tmp/a.png; since=$(now)
  while :; do
    sleep 0.5; t=$(now); import -window root /tmp/b.png; n=$((n+1))
    if [ "$(compare -metric AE /tmp/a.png /tmp/b.png null: 2>&1 | cut -d" " -f1 || true)" = 0 ]; then
      (( t - since >= SETTLE * 1000000 )) && break
    else mv /tmp/b.png /tmp/a.png; since=$(now); fi
    if (( SECONDS - start >= TIMEOUT )); then fail "the screen never settled after ${TIMEOUT}s. Something in $RECIPE keeps moving (a blinking cursor?)."; fi
  done
  # The frame metacity drew around the window. An app that draws its own title bar
  # (VS Code) asks for no frame, and metacity leaves it a child of the root window.
  f=$(xwininfo -id "$wid" -children | sed -n "s/^  Parent window id: \(0x[0-9a-f]*\).*/\1/p")
  [ "$((f))" = "$(($(xwininfo -root | sed -n "s/^xwininfo: Window id: \(0x[0-9a-f]*\).*/\1/p")))" ] && f=$wid
  eval "$(xdotool getwindowgeometry --shell "$f")"
  # An app that draws its own frame keeps a clear margin for its shadow around the
  # window it paints, and names it in _GTK_FRAME_EXTENTS (left, right, top, bottom).
  # The frame is the painted window, so the margin of the shot is the same for every app.
  ext=$(xprop -id "$f" _GTK_FRAME_EXTENTS 2>/dev/null | sed -n "s/^_GTK_FRAME_EXTENTS(CARDINAL) = //p" | tr -d " ")
  if [ -n "$ext" ]; then
    IFS=, read -r el er et eb <<< "$ext"
    X=$((X + el)); Y=$((Y + et)); WIDTH=$((WIDTH - el - er)); HEIGHT=$((HEIGHT - et - eb))
  fi
  cp /tmp/b.png /work/root.png
  printf "X=%s\nY=%s\nWIDTH=%s\nHEIGHT=%s\n" "$X" "$Y" "$WIDTH" "$HEIGHT" > /work/frame.env
  echo "settled after $n grabs, frame ${WIDTH}x${HEIGHT}+${X}+${Y}" >&3
' 3>&2 2>/tmp/session.log
