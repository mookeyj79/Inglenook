#!/usr/bin/env bash
# The document scene as an Obsidian vault: bash "$INGLENOOK_SCENE/obsidian/stage.sh" <vault>
# Run it in a recipe's stage, after apply has put the theme in <vault>/.obsidian/themes/.
#
# It copies the notes into the vault and writes the app's own state so the first launch
# opens straight into it: the vault registered and open, updates off, the window at
# about 1200x760 in the middle of the 1600x1000 screen, and "Evening reading" open in
# reading view (no blinking caret) beside the file explorer. Nothing here sets a color.
set -euo pipefail
vault=${1:?usage: obsidian/stage.sh <vault>}
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bash "$here/../stage.sh" "$vault"
id=1a2b3c4d5e6f7081

# The app's list of vaults, with this one open, and no update checks.
mkdir -p "$HOME/.config/obsidian"
printf '{"vaults":{"%s":{"path":"%s","ts":1764201600000,"open":true}},"updateDisabled":true}\n' \
  "$id" "$vault" > "$HOME/.config/obsidian/obsidian.json"
# The vault window's place and size, which Obsidian keeps per vault.
printf '{"x":200,"y":120,"width":1200,"height":760,"isMaximized":false,"devTools":false,"zoom":0}\n' \
  > "$HOME/.config/obsidian/$id.json"

# No inline title: the note's own first heading is its title.
mkdir -p "$vault/.obsidian"
printf '{"showInlineTitle":false}\n' > "$vault/.obsidian/app.json"

# The open note and the file explorer, as Obsidian saves its layout.
cat > "$vault/.obsidian/workspace.json" <<'JSON'
{
  "main": {
    "id": "scene-main", "type": "split", "direction": "vertical",
    "children": [{
      "id": "scene-tabs", "type": "tabs",
      "children": [{
        "id": "scene-note", "type": "leaf",
        "state": { "type": "markdown", "state": { "file": "Evening reading.md", "mode": "preview", "source": false } }
      }]
    }]
  },
  "left": {
    "id": "scene-left", "type": "split", "direction": "horizontal", "width": 260,
    "children": [{
      "id": "scene-left-tabs", "type": "tabs",
      "children": [{
        "id": "scene-files", "type": "leaf",
        "state": { "type": "file-explorer", "state": { "sortOrder": "alphabetical" } }
      }]
    }]
  },
  "right": { "id": "scene-right", "type": "split", "direction": "horizontal", "width": 300, "collapsed": true, "children": [] },
  "active": "scene-note",
  "lastOpenFiles": ["Evening reading.md", "Kindling.md"]
}
JSON
