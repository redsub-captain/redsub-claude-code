#!/usr/bin/env bash
# Register dependency plugins in ~/.claude/plugins/installed_plugins.json.
# Checks config/plugins.json (SSOT) and reports missing plugins.
# Usage: bash register-plugins.sh <CLAUDE_PLUGIN_ROOT>
# Output: JSON result on stdout (last line)
#   {"status": "success", "added": N, "total": N}
#   {"status": "error", "message": "..."}

set -euo pipefail

source "$(dirname "$0")/lib.sh"

if ! command -v python3 &>/dev/null && ! command -v jq &>/dev/null; then
  echo '{"status":"error","message":"Either jq or python3 is required"}'
  exit 1
fi

PLUGIN_ROOT="${1:?Usage: register-plugins.sh <CLAUDE_PLUGIN_ROOT>}"
INSTALLED_FILE="$HOME/.claude/plugins/installed_plugins.json"
REGISTRY="$PLUGIN_ROOT/config/plugins.json"

if [ ! -f "$REGISTRY" ]; then
  echo '{"status":"error","message":"config/plugins.json not found"}'
  exit 1
fi

# Ensure installed_plugins.json exists with minimal structure
if [ ! -f "$INSTALLED_FILE" ]; then
  mkdir -p "$(dirname "$INSTALLED_FILE")"
  echo '{"version":2,"plugins":{}}' > "$INSTALLED_FILE"
fi

# Use python3 (primary) or jq (fallback) to check and add missing plugins
PYTHON_OK=true
python3 - "$REGISTRY" "$INSTALLED_FILE" <<'PYEOF' || PYTHON_OK=false
import json, sys, os
from datetime import datetime, timezone

registry_path = sys.argv[1]
installed_path = sys.argv[2]

# Read SSOT registry
with open(registry_path) as f:
    registry = json.load(f)

# Read installed plugins
with open(installed_path) as f:
    installed = json.load(f)

plugins_map = installed.get("plugins", {})
added = 0
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z")

for plugin in registry.get("plugins", []):
    name = plugin["name"]
    marketplace = plugin.get("marketplace", "claude-plugins-official")
    key = f"{name}@{marketplace}"

    if key not in plugins_map:
        # Add placeholder entry — Claude Code will resolve the actual install path
        plugins_map[key] = [{
            "scope": "user",
            "installPath": "",
            "version": "",
            "installedAt": timestamp,
            "lastUpdated": timestamp,
            "gitCommitSha": ""
        }]
        added += 1

installed["plugins"] = plugins_map

# Write back
with open(installed_path, 'w') as f:
    json.dump(installed, f, indent=4)
    f.write('\n')

total = len(plugins_map)
print(json.dumps({"status": "success", "added": added, "total": total}))
PYEOF

# Fallback: if python3 failed, try jq-based approach
if [ "$PYTHON_OK" = false ]; then
  if command -v jq &>/dev/null; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    ADDED=0

    # Get list of required plugin keys from registry
    REQUIRED_KEYS=$(jq -r '.plugins[] | "\(.name)@\(.marketplace)"' "$REGISTRY" 2>/dev/null)

    while IFS= read -r KEY; do
      [ -z "$KEY" ] && continue
      # Check if key exists in installed_plugins.json
      EXISTS=$(jq --arg k "$KEY" 'if .plugins | has($k) then "yes" else "no" end' "$INSTALLED_FILE" 2>/dev/null)
      if [ "$EXISTS" = '"no"' ]; then
        # Add placeholder entry
        jq --arg k "$KEY" \
           --arg ts "$TIMESTAMP" \
           '.plugins[$k] = [{"scope":"user","installPath":"","version":"","installedAt":$ts,"lastUpdated":$ts,"gitCommitSha":""}]' \
           "$INSTALLED_FILE" > "${INSTALLED_FILE}.tmp" && \
        mv "${INSTALLED_FILE}.tmp" "$INSTALLED_FILE"
        ADDED=$((ADDED + 1))
      fi
    done <<< "$REQUIRED_KEYS"

    TOTAL=$(jq '.plugins | length' "$INSTALLED_FILE" 2>/dev/null)
    jq -n --argjson added "$ADDED" --argjson total "$TOTAL" '{"status":"success","added":$added,"total":$total}'
  else
    echo '{"status":"error","message":"Both python3 and jq failed"}'
    exit 1
  fi
fi
