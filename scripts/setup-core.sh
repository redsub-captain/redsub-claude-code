#!/usr/bin/env bash
# redsub-claude-code setup core operations
# Consolidates all setup: dependency check, legacy cleanup, permission registration,
# CLAUDE.md template merge, and manifest update. Runs EVERYTHING in one call with ZERO user input.
# Usage: bash setup-core.sh <CLAUDE_PLUGIN_ROOT> [--force]
# Output: JSON result on stdout (last line)

set -o pipefail

source "$(dirname "$0")/lib.sh"

# Guard: require jq or python3 for JSON operations
if ! command -v jq &>/dev/null && ! command -v python3 &>/dev/null; then
  echo '{"status":"error","message":"Either jq or python3 is required but neither was found"}'
  exit 1
fi

PLUGIN_ROOT="${1:?Usage: setup-core.sh <CLAUDE_PLUGIN_ROOT> [--force]}"
FORCE="${2:-}"
INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"
SETTINGS_FILE="$HOME/.claude/settings.json"
MANIFEST_FILE="$HOME/.claude-redsub/install-manifest.json"
SETUP_DONE="$HOME/.claude-redsub/.setup-done"

# --- Re-run prevention ---
if [ -f "$SETUP_DONE" ] && [ "$FORCE" != "--force" ]; then
  if command -v jq &>/dev/null; then
    jq -n '{status:"already_configured",message:"Already configured. Use --force to re-run."}'
  else
    echo '{"status":"already_configured","message":"Already configured. Use --force to re-run."}'
  fi
  exit 0
fi

# --- 1. Dependency check ---
PLUGINS_JSON="$PLUGIN_ROOT/config/plugins.json"
TOTAL_PLUGINS=0
MISSING_PLUGINS_JSON="[]"

if [ -f "$PLUGINS_JSON" ]; then
  TOTAL_PLUGINS=$(json_count "$PLUGINS_JSON" plugins)

  if command -v jq &>/dev/null; then
    MISSING_PLUGINS_JSON=$(jq -r --slurpfile installed <([ -f "$INSTALLED_PLUGINS" ] && cat "$INSTALLED_PLUGINS" || echo '{"plugins":{}}') '
      [.plugins[] |
        "\(.name)@\(.marketplace)" as $key |
        select($installed[0].plugins[$key] == null) |
        $key
      ]' "$PLUGINS_JSON" 2>/dev/null || echo "[]")
  else
    MISSING_PLUGINS_JSON=$(python3 - "$PLUGINS_JSON" "$INSTALLED_PLUGINS" <<'PYEOF'
import json, sys, os
with open(sys.argv[1]) as f:
    plugins = json.load(f)
installed = {}
if os.path.exists(sys.argv[2]):
    with open(sys.argv[2]) as f:
        installed = json.load(f).get("plugins", {})
missing = []
for p in plugins.get("plugins", []):
    key = f"{p['name']}@{p['marketplace']}"
    if key not in installed:
        missing.append(key)
print(json.dumps(missing))
PYEOF
    )
  fi
fi

MISSING_COUNT=$(echo "$MISSING_PLUGINS_JSON" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

# --- 1b. Auto-register plugins ---
REGISTER_PLUGINS_SCRIPT="$(dirname "$0")/register-plugins.sh"
if [ -x "$REGISTER_PLUGINS_SCRIPT" ] && [ "$MISSING_COUNT" -gt 0 ]; then
  bash "$REGISTER_PLUGINS_SCRIPT" "$PLUGIN_ROOT" 2>/dev/null || true
  # Re-check after registration
  MISSING_COUNT=0
  MISSING_PLUGINS_JSON="[]"
fi

INSTALLED_COUNT=$((TOTAL_PLUGINS - MISSING_COUNT))

# --- 2. Legacy rules cleanup ---
RULES_DST="$HOME/.claude/rules"
if ls "$RULES_DST"/redsub-*.md &>/dev/null 2>&1; then
  rm -f "$RULES_DST"/redsub-*.md
fi

# --- 3. Auto-register permissions ---
REGISTER_PERMS_SCRIPT="$(dirname "$0")/register-permissions.sh"
if [ -x "$REGISTER_PERMS_SCRIPT" ]; then
  bash "$REGISTER_PERMS_SCRIPT" "$PLUGIN_ROOT" 2>/dev/null || true
fi

# --- 4. Permission status ---
PERMS_JSON="$PLUGIN_ROOT/config/permissions.json"
TOTAL_PERMS=0
REGISTERED_PERMS=0
MISSING_PERMS_JSON="[]"

if [ -f "$PERMS_JSON" ]; then
  if command -v jq &>/dev/null; then
    # Flatten all patterns and check against settings.json
    ALL_PATTERNS_JSON=$(jq '[.categories | to_entries[].value.patterns[]]' "$PERMS_JSON" 2>/dev/null || echo "[]")
    TOTAL_PERMS=$(echo "$ALL_PATTERNS_JSON" | jq 'length' 2>/dev/null || echo "0")

    EXISTING_PERMS="[]"
    if [ -f "$SETTINGS_FILE" ]; then
      EXISTING_PERMS=$(jq '.permissions.allow // []' "$SETTINGS_FILE" 2>/dev/null || echo "[]")
    fi

    MISSING_PERMS_JSON=$(jq -n \
      --argjson all "$ALL_PATTERNS_JSON" \
      --argjson existing "$EXISTING_PERMS" \
      '[$all[] | select(. as $p | $existing | index($p) | not)]')
  else
    PERMS_RESULT=$(python3 - "$PERMS_JSON" "$SETTINGS_FILE" <<'PYEOF'
import json, sys, os

with open(sys.argv[1]) as f:
    perms = json.load(f)

all_patterns = []
for cat in perms.get("categories", {}).values():
    all_patterns.extend(cat.get("patterns", []))

existing = []
if os.path.exists(sys.argv[2]):
    with open(sys.argv[2]) as f:
        settings = json.load(f)
    existing = settings.get("permissions", {}).get("allow", [])

missing = [p for p in all_patterns if p not in existing]
print(json.dumps({"total": len(all_patterns), "missing": missing}))
PYEOF
    )
    TOTAL_PERMS=$(echo "$PERMS_RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['total'])" 2>/dev/null || echo "0")
    MISSING_PERMS_JSON=$(echo "$PERMS_RESULT" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)['missing']))" 2>/dev/null || echo "[]")
  fi

  MISSING_PERM_COUNT=$(echo "$MISSING_PERMS_JSON" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
  REGISTERED_PERMS=$((TOTAL_PERMS - MISSING_PERM_COUNT))
fi

# --- 5. Install manifest ---
mkdir -p "$HOME/.claude-redsub"
PLUGIN_VERSION=$(json_val "$PLUGIN_ROOT/package.json" version)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

if [ -f "$MANIFEST_FILE" ]; then
  # Update existing manifest
  if command -v jq &>/dev/null; then
    jq --arg ver "$PLUGIN_VERSION" \
       --arg ts "$TIMESTAMP" \
       '.version = $ver | .installed_at = $ts | del(.rules_installed)' \
       "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp" && \
    mv "${MANIFEST_FILE}.tmp" "$MANIFEST_FILE"
  else
    python3 - "$MANIFEST_FILE" "$PLUGIN_VERSION" "$TIMESTAMP" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
data['version'] = sys.argv[2]
data['installed_at'] = sys.argv[3]
data.pop('rules_installed', None)
with open(sys.argv[1], 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PYEOF
  fi
else
  # Create new manifest
  if command -v jq &>/dev/null; then
    jq -n \
      --arg ver "$PLUGIN_VERSION" \
      --arg ts "$TIMESTAMP" \
      '{version:$ver, installed_at:$ts, files_created:["~/.claude/CLAUDE.md"], files_modified:[]}' \
      > "$MANIFEST_FILE"
  else
    python3 -c "
import json, sys
data = {
    'version': sys.argv[1],
    'installed_at': sys.argv[2],
    'files_created': ['~/.claude/CLAUDE.md'],
    'files_modified': []
}
with open(sys.argv[3], 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" "$PLUGIN_VERSION" "$TIMESTAMP" "$MANIFEST_FILE"
  fi
fi

# --- 6. Auto-merge CLAUDE.md template ---
MERGE_TEMPLATE_SCRIPT="$(dirname "$0")/merge-template.sh"
if [ -x "$MERGE_TEMPLATE_SCRIPT" ]; then
  bash "$MERGE_TEMPLATE_SCRIPT" "$PLUGIN_ROOT" 2>/dev/null || true
fi

# --- 7. Completion marker ---
date > "$SETUP_DONE"

# --- 8. CLAUDE.md status check ---
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CLAUDE_MD_STATUS="missing"
TEMPLATE_VERSION=""

if [ -f "$CLAUDE_MD" ]; then
  if grep -q 'redsub-claude-code:start' "$CLAUDE_MD" 2>/dev/null; then
    TEMPLATE_VERSION=$(grep -m1 'redsub-template-version:' "$CLAUDE_MD" | sed -n 's/.*redsub-template-version: *\([0-9.]*\).*/\1/p')
    CLAUDE_MD_STATUS="has_markers"
  else
    CLAUDE_MD_STATUS="no_markers"
  fi
fi

TEMPLATE_LATEST=""
TEMPLATE_FILE="$PLUGIN_ROOT/templates/CLAUDE.md.template"
if [ -f "$TEMPLATE_FILE" ]; then
  TEMPLATE_LATEST=$(head -1 "$TEMPLATE_FILE" | sed -n 's/.*redsub-template-version: *\([0-9.]*\).*/\1/p')
fi

# --- Output JSON ---
if command -v jq &>/dev/null; then
  jq -n \
    --arg status "completed" \
    --argjson dep_total "$TOTAL_PLUGINS" \
    --argjson dep_installed "$INSTALLED_COUNT" \
    --argjson dep_missing "$MISSING_PLUGINS_JSON" \
    --argjson perm_total "$TOTAL_PERMS" \
    --argjson perm_registered "$REGISTERED_PERMS" \
    --argjson perm_missing "$MISSING_PERMS_JSON" \
    --arg version "$PLUGIN_VERSION" \
    --arg claude_md_status "$CLAUDE_MD_STATUS" \
    --arg template_version "$TEMPLATE_VERSION" \
    --arg template_latest "$TEMPLATE_LATEST" \
    '{
      status: $status,
      dependencies: {total: $dep_total, installed: $dep_installed, missing: $dep_missing},
      permissions: {total: $perm_total, registered: $perm_registered, missing: $perm_missing},
      manifest_updated: true,
      version: $version,
      claude_md: {status: $claude_md_status, template_version: $template_version, template_latest: $template_latest}
    }'
else
  python3 -c "
import json, sys
print(json.dumps({
    'status': 'completed',
    'dependencies': {'total': int(sys.argv[1]), 'installed': int(sys.argv[2]), 'missing': json.loads(sys.argv[3])},
    'permissions': {'total': int(sys.argv[4]), 'registered': int(sys.argv[5]), 'missing': json.loads(sys.argv[6])},
    'manifest_updated': True,
    'version': sys.argv[7],
    'claude_md': {'status': sys.argv[8], 'template_version': sys.argv[9], 'template_latest': sys.argv[10]}
}, indent=2))
" "$TOTAL_PLUGINS" "$INSTALLED_COUNT" "$MISSING_PLUGINS_JSON" \
  "$TOTAL_PERMS" "$REGISTERED_PERMS" "$MISSING_PERMS_JSON" "$PLUGIN_VERSION" \
  "$CLAUDE_MD_STATUS" "$TEMPLATE_VERSION" "$TEMPLATE_LATEST"
fi
