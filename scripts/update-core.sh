#!/usr/bin/env bash
# redsub-claude-code update core operations
# Consolidates all internal file operations into a single script.
# Usage: bash update-core.sh <CLAUDE_PLUGIN_ROOT>
# Output: JSON result on stdout (last line)

set -o pipefail

source "$(dirname "$0")/lib.sh"

PLUGIN_ROOT="${1:?Usage: update-core.sh <CLAUDE_PLUGIN_ROOT>}"
MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/redsub-plugins"
INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"
PLUGIN_KEY="redsub-claude-code@redsub-plugins"

# Helper: output JSON result and exit
output_json() {
  if command -v jq &>/dev/null; then
    jq -n \
      --arg status "$1" \
      --arg old_version "${2:-}" \
      --arg new_version "${3:-}" \
      --argjson template_changed "${4:-false}" \
      --arg template_old "${5:-}" \
      --arg template_new "${6:-}" \
      --arg message "${7:-}" \
      '{status:$status, old_version:$old_version, new_version:$new_version, template_changed:$template_changed, template_old:$template_old, template_new:$template_new, message:$message}'
  else
    python3 -c "
import json, sys
print(json.dumps({
  'status': sys.argv[1],
  'old_version': sys.argv[2],
  'new_version': sys.argv[3],
  'template_changed': sys.argv[4] == 'true',
  'template_old': sys.argv[5],
  'template_new': sys.argv[6],
  'message': sys.argv[7]
}))" "$1" "${2:-}" "${3:-}" "${4:-false}" "${5:-}" "${6:-}" "${7:-}"
  fi
}

# --- 1. Current version ---
CURRENT_VERSION=$(json_val "$PLUGIN_ROOT/package.json" version)
if [ -z "$CURRENT_VERSION" ]; then
  output_json "error" "" "" "false" "" "" "Cannot read current version from $PLUGIN_ROOT/package.json"
  exit 1
fi

# --- 2. Latest version (GitHub) ---
LATEST_VERSION=""

# Try releases API first
RELEASE_RESP=$(curl -s --max-time 10 https://api.github.com/repos/redsub-captain/redsub-claude-code/releases/latest 2>/dev/null || echo "")
if [ -n "$RELEASE_RESP" ]; then
  if command -v jq &>/dev/null; then
    LATEST_VERSION=$(echo "$RELEASE_RESP" | jq -r '.tag_name // empty' 2>/dev/null | sed 's/^v//')
  else
    LATEST_VERSION=$(echo "$RELEASE_RESP" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tag_name','').lstrip('v'))" 2>/dev/null || echo "")
  fi
fi

# Fallback: raw package.json from main branch
if [ -z "$LATEST_VERSION" ]; then
  RAW_RESP=$(curl -s --max-time 10 https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json 2>/dev/null || echo "")
  if [ -n "$RAW_RESP" ]; then
    if command -v jq &>/dev/null; then
      LATEST_VERSION=$(echo "$RAW_RESP" | jq -r '.version // empty' 2>/dev/null)
    else
      LATEST_VERSION=$(echo "$RAW_RESP" | python3 -c "import json,sys; print(json.load(sys.stdin).get('version',''))" 2>/dev/null || echo "")
    fi
  fi
fi

if [ -z "$LATEST_VERSION" ]; then
  output_json "error" "$CURRENT_VERSION" "" "false" "" "" "Cannot fetch latest version from GitHub"
  exit 1
fi

# --- 3. Compare versions ---
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  output_json "up_to_date" "$CURRENT_VERSION" "$CURRENT_VERSION" "false" "" ""
  exit 0
fi

# --- 4. Auto-update ---

# 4a. Pull latest from marketplace repo
if [ -d "$MARKETPLACE_DIR/.git" ]; then
  if ! git -C "$MARKETPLACE_DIR" pull origin main 2>/dev/null; then
    git -C "$MARKETPLACE_DIR" fetch origin main 2>/dev/null || true
    git -C "$MARKETPLACE_DIR" reset --hard origin/main 2>/dev/null || true
  fi
else
  output_json "error" "$CURRENT_VERSION" "$LATEST_VERSION" "false" "" "" "Marketplace repo not found at $MARKETPLACE_DIR"
  exit 1
fi

# 4b. New version from pulled repo
NEW_VERSION=$(json_val "$MARKETPLACE_DIR/package.json" version)
if [ -z "$NEW_VERSION" ]; then
  output_json "error" "$CURRENT_VERSION" "" "false" "" "" "Cannot read version from pulled marketplace repo"
  exit 1
fi

# 4c. Cache directory + copy files
CACHE_DIR="$HOME/.claude/plugins/cache/redsub-plugins/redsub-claude-code/$NEW_VERSION"
mkdir -p "$CACHE_DIR"
rsync -a --exclude='.git' "$MARKETPLACE_DIR/" "$CACHE_DIR/"

# 4d. Git commit SHA
COMMIT_SHA=$(git -C "$MARKETPLACE_DIR" rev-parse HEAD 2>/dev/null || echo "unknown")

# 4e. Update installed_plugins.json
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

if [ -f "$INSTALLED_PLUGINS" ]; then
  if command -v jq &>/dev/null; then
    jq --arg path "$CACHE_DIR" \
       --arg ver "$NEW_VERSION" \
       --arg ts "$TIMESTAMP" \
       --arg sha "$COMMIT_SHA" \
       --arg key "$PLUGIN_KEY" \
       'if has($key) then
          (.[$key][0].installPath = $path) |
          (.[$key][0].version = $ver) |
          (.[$key][0].lastUpdated = $ts) |
          (.[$key][0].gitCommitSha = $sha)
        else . end' \
       "$INSTALLED_PLUGINS" > "${INSTALLED_PLUGINS}.tmp" && \
    mv "${INSTALLED_PLUGINS}.tmp" "$INSTALLED_PLUGINS"
  else
    python3 - "$INSTALLED_PLUGINS" "$CACHE_DIR" "$NEW_VERSION" "$TIMESTAMP" "$COMMIT_SHA" "$PLUGIN_KEY" <<'PYEOF'
import json, sys
file_path, cache_path, version, timestamp, sha, key = sys.argv[1:]
with open(file_path) as f:
    data = json.load(f)
if key in data and len(data[key]) > 0:
    data[key][0]["installPath"] = cache_path
    data[key][0]["version"] = version
    data[key][0]["lastUpdated"] = timestamp
    data[key][0]["gitCommitSha"] = sha
with open(file_path, 'w') as f:
    json.dump(data, f, indent=4)
    f.write('\n')
PYEOF
  fi
fi

# --- 5. Verify update ---
VERIFY_VERSION=$(json_val "$CACHE_DIR/package.json" version)
if [ "$VERIFY_VERSION" != "$NEW_VERSION" ]; then
  output_json "error" "$CURRENT_VERSION" "$NEW_VERSION" "false" "" "" "Version mismatch: expected $NEW_VERSION, got $VERIFY_VERSION"
  exit 1
fi

# --- 5.5. Template version comparison ---
TEMPLATE_FILE="$CACHE_DIR/templates/CLAUDE.md.template"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
TEMPLATE_CHANGED=false
TEMPLATE_OLD=""
TEMPLATE_NEW=""

if [ -f "$TEMPLATE_FILE" ]; then
  TEMPLATE_NEW=$(head -1 "$TEMPLATE_FILE" | sed -n 's/.*redsub-template-version:\([0-9.]*\).*/\1/p')
fi

if [ -f "$CLAUDE_MD" ]; then
  TEMPLATE_OLD=$(grep -m1 'redsub-template-version:' "$CLAUDE_MD" | sed -n 's/.*redsub-template-version:\([0-9.]*\).*/\1/p')
fi

if [ -n "$TEMPLATE_NEW" ] && [ "$TEMPLATE_OLD" != "$TEMPLATE_NEW" ]; then
  TEMPLATE_CHANGED=true
fi

# --- Output result ---
output_json "updated" "$CURRENT_VERSION" "$NEW_VERSION" "$TEMPLATE_CHANGED" "$TEMPLATE_OLD" "$TEMPLATE_NEW"
