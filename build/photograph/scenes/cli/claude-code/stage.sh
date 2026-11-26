#!/usr/bin/env bash
# Claude Code's part of the CLI/TUI scene, run from its recipe's stage steps. No key
# and no login: first-run questions are answered ahead, updates and other
# non-essential traffic are off, and `claude --resume` replays the saved session in
# session.jsonl without a model call. The "Not logged in" footer stays.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo="$HOME/Inglenook"
id=6c1e5a0d-2b4f-4a8e-9d3c-7f1b2e4a6c80

# Keep the theme the apply steps set; add only staging to settings.json.
python3 - "$HOME/.claude/settings.json" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f:
    s = json.load(f)
s.setdefault("env", {}).update({"DISABLE_AUTOUPDATER": "1", "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"})
with open(path, "w") as f:
    json.dump(s, f, indent=2)
PY

python3 - "$HOME/.claude.json" "$repo" <<'PY'
import json, sys
path, repo = sys.argv[1:]
config = {
    "hasCompletedOnboarding": True,
    "autoUpdates": False,
    "projects": {repo: {"hasTrustDialogAccepted": True, "hasCompletedProjectOnboarding": True}},
}
with open(path, "w") as f:
    json.dump(config, f, indent=2)
PY

sessions="$HOME/.claude/projects/${repo//\//-}"
mkdir -p "$sessions"
sed "s#@REPO@#$repo#g" "$here/session.jsonl" > "$sessions/$id.jsonl"
printf 'claude --resume %s\n' "$id" > ~/.inglenook-cli
