#!/usr/bin/env bash
# [Verification] Static validation of plugin file structure
# Checks file existence, JSON validity, executable permissions, reference consistency

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
CHECKS=0

check() {
  CHECKS=$((CHECKS + 1))
  if [ "$1" = "ok" ]; then
    echo "  OK: $2"
  else
    echo "  FAIL: $2"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== redsub-claude-code Static Verification ==="
echo ""

# 1. JSON file validity
echo "[JSON Files]"
for f in ".claude-plugin/plugin.json" ".mcp.json" "hooks/hooks.json" ".claude-plugin/marketplace.json"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if python3 -m json.tool "$PLUGIN_ROOT/$f" > /dev/null 2>&1; then
      check "ok" "$f — valid JSON"
    else
      check "fail" "$f — JSON parse error"
    fi
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 2. Skills (12 with redsub- prefix)
echo "[Skills (12)]"
SKILLS="redsub-setup redsub-ship redsub-start-work redsub-deploy redsub-design redsub-test redsub-validate redsub-fix-all redsub-session-save redsub-uninstall redsub-update redsub-doctor"
for skill in $SKILLS; do
  f="skills/$skill/SKILL.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if head -1 "$PLUGIN_ROOT/$f" | grep -q "^---"; then
      # Verify name field matches directory
      NAME_FIELD=$(grep "^name:" "$PLUGIN_ROOT/$f" | head -1 | sed 's/name: *//')
      if [ "$NAME_FIELD" = "$skill" ]; then
        check "ok" "$f (name: $NAME_FIELD)"
      else
        check "fail" "$f — name mismatch: '$NAME_FIELD' != '$skill'"
      fi
    else
      check "fail" "$f — missing frontmatter"
    fi
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 3. Agents (4)
echo "[Agents (4)]"
AGENTS="developer planner devops designer"
for agent in $AGENTS; do
  f="agents/$agent.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if head -1 "$PLUGIN_ROOT/$f" | grep -q "^---"; then
      check "ok" "$f"
    else
      check "fail" "$f — missing frontmatter"
    fi
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 4. Verify deleted files don't exist
echo "[Deleted Files (should not exist)]"
for f in "agents/reviewer.md" "rules/security.md" "rules/database.md" ".lsp.json"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "fail" "$f — should be deleted but still exists"
  else
    check "ok" "$f — correctly absent"
  fi
done

echo ""

# 5. Rules (3 with redsub- prefix)
echo "[Rules (3)]"
RULES="redsub-code-quality redsub-workflow redsub-testing"
for rule in $RULES; do
  f="rules/$rule.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "ok" "$f"
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 6. Scripts (10, executable)
echo "[Scripts (executable)]"
SCRIPTS="workflow-orchestrator.sh version-check.sh guard-main.sh warn-main-edit.sh validate-marker.sh auto-format.sh notify-attention.sh pre-compact-context.sh completion-check.sh verify-install.sh"
for script in $SCRIPTS; do
  f="scripts/$script"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if [ -x "$PLUGIN_ROOT/$f" ]; then
      check "ok" "$f — executable"
    else
      check "fail" "$f — not executable (chmod +x needed)"
    fi
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 7. Legacy prefix check
echo "[Legacy Prefix Check]"
LEGACY_COUNT=$(set +o pipefail; grep -r '/rs-' "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/agents/" "$PLUGIN_ROOT/rules/" 2>/dev/null | grep -v "node_modules" | grep -v "redsub-doctor" | wc -l | tr -d ' ')
if [ "$LEGACY_COUNT" = "0" ]; then
  check "ok" "No legacy /rs- references found (excluding redsub-doctor diagnostics)"
else
  check "fail" "$LEGACY_COUNT legacy /rs- references found"
  grep -r '/rs-' "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/agents/" "$PLUGIN_ROOT/rules/" 2>/dev/null | grep -v "node_modules" | grep -v "redsub-doctor" | head -5
fi

echo ""

# 8. Version consistency
echo "[Version Consistency]"
PLUGIN_VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "")
PKG_VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/package.json'))['version'])" 2>/dev/null || echo "")
MKT_VER=$(python3 -c "import json; p=json.load(open('$PLUGIN_ROOT/.claude-plugin/marketplace.json')); print(p['plugins'][0]['version'])" 2>/dev/null || echo "")

if [ -n "$PLUGIN_VER" ] && [ "$PLUGIN_VER" = "$PKG_VER" ] && [ "$PLUGIN_VER" = "$MKT_VER" ]; then
  check "ok" "All versions match: v$PLUGIN_VER"
else
  check "fail" "Version mismatch — plugin.json: $PLUGIN_VER, package.json: $PKG_VER, marketplace.json: $MKT_VER"
fi

echo ""

# 9. Other required files
echo "[Other Files]"
for f in "templates/CLAUDE.md.template" "package.json" "README.md" "COMPATIBILITY.md" "LICENSE" "config/plugins.json"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "ok" "$f"
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 10. Cross-reference count consistency (auto-count vs hardcoded)
echo "[Count Consistency]"

# Actual counts from filesystem
ACTUAL_SKILLS=$(ls -d "$PLUGIN_ROOT"/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_AGENTS=$(ls "$PLUGIN_ROOT"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_RULES=$(ls "$PLUGIN_ROOT"/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_HOOKS=$(python3 -c "
import json
with open('$PLUGIN_ROOT/hooks/hooks.json') as f: d=json.load(f)
print(sum(len(group) for groups in d['hooks'].values() for group in groups))
" 2>/dev/null || echo "0")
ACTUAL_MCPS=$(python3 -c "
import json
with open('$PLUGIN_ROOT/.mcp.json') as f: d=json.load(f)
print(len(d.get('mcpServers',{})))
" 2>/dev/null || echo "0")
ACTUAL_SCRIPTS=$(ls "$PLUGIN_ROOT"/scripts/*.sh 2>/dev/null | wc -l | tr -d ' ')

# Verify counts match expected (hardcoded list lengths above)
EXPECTED_SKILLS=$(echo $SKILLS | wc -w | tr -d ' ')
EXPECTED_AGENTS=$(echo $AGENTS | wc -w | tr -d ' ')
EXPECTED_RULES=$(echo $RULES | wc -w | tr -d ' ')
EXPECTED_SCRIPTS=$(echo $SCRIPTS | wc -w | tr -d ' ')

if [ "$ACTUAL_SKILLS" = "$EXPECTED_SKILLS" ]; then
  check "ok" "Skills: $ACTUAL_SKILLS (matches expected)"
else
  check "fail" "Skills: found $ACTUAL_SKILLS on disk, but verify-install expects $EXPECTED_SKILLS — update SKILLS list"
fi

if [ "$ACTUAL_AGENTS" = "$EXPECTED_AGENTS" ]; then
  check "ok" "Agents: $ACTUAL_AGENTS (matches expected)"
else
  check "fail" "Agents: found $ACTUAL_AGENTS on disk, but verify-install expects $EXPECTED_AGENTS — update AGENTS list"
fi

if [ "$ACTUAL_RULES" = "$EXPECTED_RULES" ]; then
  check "ok" "Rules: $ACTUAL_RULES (matches expected)"
else
  check "fail" "Rules: found $ACTUAL_RULES on disk, but verify-install expects $EXPECTED_RULES — update RULES list"
fi

if [ "$ACTUAL_SCRIPTS" = "$EXPECTED_SCRIPTS" ]; then
  check "ok" "Scripts: $ACTUAL_SCRIPTS (matches expected)"
else
  check "fail" "Scripts: found $ACTUAL_SCRIPTS on disk, but verify-install expects $EXPECTED_SCRIPTS — update SCRIPTS list"
fi

check "ok" "Hooks: $ACTUAL_HOOKS registered, MCPs: $ACTUAL_MCPS configured"

echo ""

# 11. Plugin registry drift detection (SSOT: config/plugins.json)
echo "[Plugin Registry (SSOT)]"
REGISTRY="$PLUGIN_ROOT/config/plugins.json"
if [ -f "$REGISTRY" ]; then
  EXPECTED_PLUGINS=$(python3 -c "import json; print(len(json.load(open('$REGISTRY'))['plugins']))" 2>/dev/null || echo "0")

  # Check README files (static copies that need manual sync)
  # Note: redsub-setup and redsub-doctor read from plugins.json dynamically — no check needed
  SSOT_NAMES=$(python3 -c "import json; [print(p['name']) for p in json.load(open('$REGISTRY'))['plugins']]" 2>/dev/null)

  for TARGET_LABEL_FILE in \
    "README.md:$PLUGIN_ROOT/README.md" \
    "README.en.md:$PLUGIN_ROOT/README.en.md"; do

    TARGET_LABEL="${TARGET_LABEL_FILE%%:*}"
    TARGET_FILE="${TARGET_LABEL_FILE#*:}"
    FOUND=0
    MISSING=""

    for pname in $SSOT_NAMES; do
      if grep -q "$pname" "$TARGET_FILE" 2>/dev/null; then
        FOUND=$((FOUND + 1))
      else
        MISSING="$MISSING $pname"
      fi
    done

    if [ "$FOUND" = "$EXPECTED_PLUGINS" ]; then
      check "ok" "$TARGET_LABEL: all $FOUND/$EXPECTED_PLUGINS plugin names present"
    else
      check "fail" "$TARGET_LABEL: $FOUND/$EXPECTED_PLUGINS plugins found, missing:$MISSING"
    fi
  done

  # Verify SSOT consumers reference plugins.json (not hardcoded lists)
  for CONSUMER_LABEL_FILE in \
    "redsub-setup:$PLUGIN_ROOT/skills/redsub-setup/SKILL.md" \
    "redsub-doctor:$PLUGIN_ROOT/skills/redsub-doctor/SKILL.md"; do

    CONSUMER_LABEL="${CONSUMER_LABEL_FILE%%:*}"
    CONSUMER_FILE="${CONSUMER_LABEL_FILE#*:}"

    if grep -q "config/plugins.json" "$CONSUMER_FILE" 2>/dev/null; then
      check "ok" "$CONSUMER_LABEL: references SSOT (config/plugins.json)"
    else
      check "fail" "$CONSUMER_LABEL: does NOT reference config/plugins.json — may have hardcoded plugin list"
    fi
  done
else
  check "fail" "config/plugins.json — SSOT file not found"
fi

echo ""
echo "=== Result: ${CHECKS} checks, ${ERRORS} errors ==="

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
