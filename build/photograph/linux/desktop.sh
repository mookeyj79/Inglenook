#!/usr/bin/env bash
# One take of a desktop recipe (scene kind desktop), run by shoot.sh. The recipe's
# launch step is the desktop's own session, which brings its own window manager,
# compositor and backdrop painter, so none of the Photographer's are started.
# The scene sets the backdrop and the stock frame, fixes the clock, opens the file
# manager on the staged folder and the menu, and leaves the settled screen in
# /work/root.png. The crop (a fixed area at the bottom left) happens outside.
# Today the one desktop is Cinnamon, so the settings and the readiness checks are its.
set -euo pipefail
# shellcheck source=/dev/null
source /work/scene.env   # KIND, SCREEN, BACKDROP_KIND, BACKDROP, FRAME_THEME, CLOCK, TIMEOUT, RECIPE

fail() { echo "photograph: $*" >&2; exit 1; }
# Software rendering. Without XDG_SESSION_TYPE, Muffin exits ("Unsupported session type").
export DISPLAY=:99 XDG_RUNTIME_DIR=/tmp/xdg-$UID LIBGL_ALWAYS_SOFTWARE=1 XDG_SESSION_TYPE=x11 XDG_CURRENT_DESKTOP=X-Cinnamon
export BACKDROP_KIND BACKDROP FRAME_THEME CLOCK TIMEOUT RECIPE
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
Xvfb :99 -screen 0 "${SCREEN}x24" +extension GLX -noreset >/tmp/xvfb.log 2>&1 &
until xdpyinfo >/dev/null 2>&1; do sleep 0.1; done

# The session starts whatever /etc/xdg/autostart names, and the base image's picom
# is there. The desktop composites itself: hide picom the way a user does.
mkdir -p ~/.config/autostart
printf '[Desktop Entry]\nType=Application\nName=picom\nHidden=true\n' > ~/.config/autostart/picom.desktop

# The file manager's folder, on the fixed-size tmpfs photograph.ps1 mounts at /scene.
bash /inglenook/build/photograph/scenes/desktop/folder.sh /scene

# Inside the session, our own messages go to fd 3; the session's services are noisy on stderr.
dbus-run-session -- bash -c '
  set -euo pipefail
  fail() { echo "photograph: $*" >&3; exit 1; }
  logs() { for log in /tmp/step-*-launch-*.log; do [ -s "$log" ] && { echo "${log#/tmp/step-}:"; grep -v dbus-daemon "$log" | tail -n 20 | sed "s/^/    /"; }; done >&3; }
  # Ask the running desktop a question in its own script (Cinnamon answers on the session bus).
  ask() { gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon --method org.Cinnamon.Eval "$1" 2>/dev/null || true; }

  # The scene: backdrop, stock frame in the matching mode, painted by the session itself.
  # A plain fill is the background color with no picture.
  if [ "$BACKDROP_KIND" = image ]; then
    gsettings set org.cinnamon.desktop.background picture-uri "file:///inglenook/$BACKDROP"
    gsettings set org.cinnamon.desktop.background picture-options zoom
  else
    gsettings set org.cinnamon.desktop.background picture-options none
    gsettings set org.cinnamon.desktop.background color-shading-type solid
    gsettings set org.cinnamon.desktop.background primary-color "$BACKDROP"
  fi
  gsettings set org.cinnamon.desktop.interface gtk-theme "$FRAME_THEME"
  gsettings set org.cinnamon.desktop.wm.preferences theme "$FRAME_THEME"

  # The recipe: apply, stage, then launch the session. Every process the steps
  # start begins at the fixed clock and ticks on; a take ends inside the minute.
  # libfaketime directly: the faketime wrapper waits on the session it started.
  LD_PRELOAD=/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1 FAKETIME="@$CLOCK" FAKETIME_DONT_FAKE_MONOTONIC=1 \
    bash /work/steps.sh 2>&3 || exit 1

  # Ready when the panel exists, not only the window manager.
  start=$SECONDS
  until [ "$(ask "Main.panelManager.panels.filter(p => p).length > 0")" = "(true, '\''true'\'')" ]; do
    (( SECONDS - start >= TIMEOUT )) && { logs; fail "the desktop never showed its panel after ${TIMEOUT}s. Check launch in $RECIPE."; }
    sleep 0.2
  done

  # One file manager window on the staged folder, the size of every port'\''s window.
  # Rarely (once in a hundred takes or so) nemo starts, logs its usual startup lines,
  # and never maps a window. So a nemo with no window after NEMO_WAIT seconds is
  # stopped and started again, on its own clock. Only the launch is retried: the
  # take is still judged by its pixels.
  NEMO_WAIT=15
  nemo_windows() { for w in $(xdotool search --class "^nemo$" 2>/dev/null); do echo "    window $w: $(xwininfo -id "$w" 2>/dev/null | sed -n "s/^ *Map State: //p")"; done; }
  start=$SECONDS; tries=0; wid=
  until [ -n "$wid" ]; do
    if (( tries == 0 || SECONDS - launched >= NEMO_WAIT )); then
      if (( tries > 0 )); then
        { echo "nemo showed no window after ${NEMO_WAIT}s, starting it again. Its windows:"; nemo_windows; } >&3
        pkill -x nemo || true
        for _ in $(seq 20); do pgrep -x nemo >/dev/null || break; sleep 0.1; done
        pkill -KILL -x nemo || true
      fi
      nemo --geometry=1200x760+200+90 /scene >>/tmp/nemo.log 2>&1 &
      launched=$SECONDS; tries=$((tries+1))
    fi
    (( SECONDS - start >= TIMEOUT )) && { tail -n 20 /tmp/nemo.log >&3; nemo_windows >&3; fail "the file manager never opened after ${TIMEOUT}s."; }
    sleep 0.2
    wid=$(xdotool search --onlyvisible --class "^nemo$" 2>/dev/null | tail -1 || true)
  done

  # The menu, opened the way a person does, and checked open.
  start=$SECONDS
  menu="imports.ui.appletManager.getRunningInstancesForUuid(\"menu@cinnamon.org\").some(a => a.menu.isOpen)"
  open=
  until [ -n "$open" ]; do
    (( SECONDS - start >= TIMEOUT )) && fail "the menu never opened after ${TIMEOUT}s."
    xdotool key super
    # A press before the menu applet has loaded does nothing: give it 3 s, then press again.
    for _ in $(seq 15); do
      [ "$(ask "$menu")" = "(true, '\''true'\'')" ] && { open=1; break; }
      sleep 0.2
    done
  done

  # Wait for pixels, not time: two equal grabs 300 ms apart.
  start=$SECONDS
  import -window root /tmp/a.png; n=0
  while :; do
    sleep 0.3; import -window root /tmp/b.png; n=$((n+1))
    [ "$(compare -metric AE /tmp/a.png /tmp/b.png null: 2>&1 | cut -d" " -f1 || true)" = 0 ] && break
    mv /tmp/b.png /tmp/a.png
    (( SECONDS - start >= TIMEOUT )) && fail "the screen never settled after ${TIMEOUT}s. Something in $RECIPE keeps moving."
  done
  cp /tmp/b.png /work/root.png
  echo "settled after $n grabs" >&3
' 3>&2 2>/tmp/session.log
