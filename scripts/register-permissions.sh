#!/usr/bin/env bash
# Register permission patterns in ~/.claude/settings.json.
# Eliminates Read/Edit permission prompts by doing everything in Bash.
# Usage: bash register-permissions.sh <CLAUDE_PLUGIN_ROOT> [pattern1 pattern2 ...]
#   If patterns are provided as args, register only those.
#   If no patterns provided, register all from config/permissions.json.
# Output: JSON result on stdout (last line)

set -euo pipefail

source "$(dirname "$0")/lib.sh"

if ! command -v python3 &>/dev/null && ! command -v jq &>/dev/null; then
  echo '{"status":"error","message":"Either jq or python3 is required"}'
  exit 1
fi

PLUGIN_ROOT="${1:?Usage: register-permissions.sh <CLAUDE_PLUGIN_ROOT> [patterns...]}"
shift
SETTINGS_FILE="$HOME/.claude/settings.json"
PERMS_JSON="$PLUGIN_ROOT/config/permissions.json"

# Collect patterns to register
if [ $# -gt 0 ]; then
  # Patterns provided as arguments
  PATTERNS_JSON=$(printf '%s\n' "$@" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))")
else
  # All patterns from config
  if [ ! -f "$PERMS_JSON" ]; then
    echo '{"status":"error","message":"permissions.json not found"}'
    exit 1
  fi
  if command -v jq &>/dev/null; then
    PATTERNS_JSON=$(jq '[.categories | to_entries[].value.patterns[]]' "$PERMS_JSON")
  else
    PATTERNS_JSON=$(python3 - "$PERMS_JSON" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f: d = json.load(f)
patterns = []
for cat in d.get('categories', {}).values():
    patterns.extend(cat.get('patterns', []))
print(json.dumps(patterns))
PYEOF
    )
  fi
fi

# Update settings.json
python3 - "$SETTINGS_FILE" "$PATTERNS_JSON" <<'PYEOF'
import json, sys, os

settings_path = sys.argv[1]
new_patterns = json.loads(sys.argv[2])

# Read existing settings
settings = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)

# Ensure permissions.allow exists
if "permissions" not in settings:
    settings["permissions"] = {}
if "allow" not in settings["permissions"]:
    settings["permissions"]["allow"] = []

existing = settings["permissions"]["allow"]
added = 0
for p in new_patterns:
    if p not in existing:
        existing.append(p)
        added += 1

# Write back
os.makedirs(os.path.dirname(settings_path), exist_ok=True)
with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print(json.dumps({"status": "success", "added": added, "total": len(existing)}))
PYEOF
