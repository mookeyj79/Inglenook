#!/usr/bin/env bash
# The OBS Studio scene: a small streaming setup, as the main window shows it.
# Run it in a recipe's stage: bash "$INGLENOOK_SCENE/obs-studio/stage.sh"
#
# It writes a scene collection "Inglenook" with three scenes, "Live" current, whose
# sources are a picture (a repo wallpaper), a caption and a music clip with no file, so the
# mixer shows a still meter. The current scene, "Live", shows the Scenes list's selection.
# It also skips the first-run wizard: FirstRun in user.ini and LastVersion in global.ini
# make OBS think it has run before. The status bar is hidden: its CPU and FPS readout
# changes every second, so the screen would never settle. No colors: the port under test decides every color.
set -euo pipefail
cfg=$HOME/.config/obs-studio
picture=$PWD/wallpapers/porch-coffee.jpg
mkdir -p "$cfg/basic/scenes" "$cfg/basic/profiles/Inglenook"

# LastVersion is LIBOBS_API_VER, (major << 24) | (minor << 16) | patch.
IFS=. read -r ma mi pa <<< "${INGLENOOK_VERSION%%-*}"
cat > "$cfg/global.ini" <<EOF
[General]
LastVersion=$(( (ma << 24) | (mi << 16) | pa ))
Pre31Migrated=true
EOF

# user.ini may already hold the theme from the recipe's apply step: add to it, keep that.
cat >> "$cfg/user.ini" <<'EOF'

[General]
FirstRun=true
EnableAutoUpdates=false
WarnBeforeStartingStream=false
WarnBeforeStoppingStream=false
ConfirmOnExit=false

[BasicWindow]
ShowStatusBar=false

[Basic]
Profile=Inglenook
ProfileDir=Inglenook
SceneCollection=Inglenook
SceneCollectionFile=Inglenook
EOF

cat > "$cfg/basic/profiles/Inglenook/basic.ini" <<'EOF'
[General]
Name=Inglenook

[Video]
BaseCX=1920
BaseCY=1080
OutputCX=1920
OutputCY=1080
FPSType=0
FPSCommon=30

[Audio]
SampleRate=48000
ChannelSetup=Stereo
EOF

uuid() { printf '00000000-0000-4000-8000-%012d' "$1"; }
cat > "$cfg/basic/scenes/Inglenook.json" <<EOF
{
  "name": "Inglenook",
  "current_scene": "Live",
  "current_program_scene": "Live",
  "scene_order": [ { "name": "Live" }, { "name": "Starting soon" }, { "name": "Be right back" } ],
  "sources": [
    { "id": "scene", "versioned_id": "scene", "name": "Live", "uuid": "$(uuid 1)",
      "settings": { "id_counter": 3, "items": [
        { "name": "Picture", "source_uuid": "$(uuid 4)", "id": 1, "visible": true, "locked": false,
          "pos": { "x": 0.0, "y": 0.0 }, "scale": { "x": 1.0, "y": 1.0 }, "align": 5,
          "bounds_type": 2, "bounds_align": 0, "bounds": { "x": 1920.0, "y": 1080.0 } },
        { "name": "Caption", "source_uuid": "$(uuid 5)", "id": 2, "visible": true, "locked": true,
          "selected": true, "pos": { "x": 96.0, "y": 900.0 }, "scale": { "x": 1.0, "y": 1.0 }, "align": 5 },
        { "name": "Music", "source_uuid": "$(uuid 6)", "id": 3, "visible": true, "locked": false,
          "pos": { "x": 0.0, "y": 0.0 }, "scale": { "x": 1.0, "y": 1.0 }, "align": 5 }
      ] } },
    { "id": "scene", "versioned_id": "scene", "name": "Starting soon", "uuid": "$(uuid 2)",
      "settings": { "id_counter": 0, "items": [] } },
    { "id": "scene", "versioned_id": "scene", "name": "Be right back", "uuid": "$(uuid 3)",
      "settings": { "id_counter": 0, "items": [] } },
    { "id": "image_source", "versioned_id": "image_source", "name": "Picture", "uuid": "$(uuid 4)",
      "settings": { "file": "$picture" } },
    { "id": "text_ft2_source", "versioned_id": "text_ft2_source_v2", "name": "Caption", "uuid": "$(uuid 5)",
      "settings": { "text": "A quiet evening by the fire",
        "font": { "face": "BlexMono Nerd Font Mono", "style": "Regular", "size": 64, "flags": 0 } } },
    { "id": "ffmpeg_source", "versioned_id": "ffmpeg_source", "name": "Music", "uuid": "$(uuid 6)",
      "settings": { "is_local_file": true, "local_file": "", "looping": false } }
  ],
  "transitions": [],
  "current_transition": "Fade",
  "transition_duration": 300
}
EOF
