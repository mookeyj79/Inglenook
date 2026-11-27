#!/usr/bin/env bash
# KiCad's part of the document scene, run from its recipe's stage steps. It copies
# the pic_programmer demo board that the kicad-demos package ships (GPL-2+, from
# the KiCad developers) to a folder the user can write to, answers KiCad's
# first-run questions with files, and gives the PCB Editor a fixed window size.
# No colors: the port under test decides every color it can.
set -euo pipefail
cfg=~/.config/kicad/7.0
mkdir -p "$cfg"

# The demo, writable, so KiCad can keep its lock and backup files next to it.
rm -rf ~/kicad-demo
cp -r /usr/share/kicad/demos/pic_programmer ~/kicad-demo

# First run: an existing kicad_common.json skips the "Configure KiCad Settings
# Path" dialog, and empty global library tables skip the library table dialogs.
[ -f "$cfg/kicad_common.json" ] || printf '{}\n' > "$cfg/kicad_common.json"
[ -f "$cfg/fp-lib-table" ] || printf '(fp_lib_table\n  (version 7)\n)\n' > "$cfg/fp-lib-table"
[ -f "$cfg/sym-lib-table" ] || printf '(sym_lib_table\n  (version 7)\n)\n' > "$cfg/sym-lib-table"

# A fixed window, so every take frames the same board. Merged into whatever
# pcbnew.json the recipe's apply steps wrote.
python3 - "$cfg/pcbnew.json" <<'PY'
import json, os, sys
path = sys.argv[1]
settings = json.load(open(path)) if os.path.exists(path) else {}
settings.setdefault("window", {}).update({"maximized": False, "size_x": 1360, "size_y": 860})
json.dump(settings, open(path, "w"), indent=2)
PY
