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

# 6. Scripts (8, executable)
echo "[Scripts (executable)]"
SCRIPTS="version-check.sh guard-main.sh validate-marker.sh auto-format.sh notify-attention.sh pre-compact-context.sh completion-check.sh verify-install.sh"
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
for f in "templates/CLAUDE.md.template" "package.json" "README.md" "COMPATIBILITY.md" "LICENSE"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "ok" "$f"
  else
    check "fail" "$f — file not found"
  fi
done

echo ""
echo "=== Result: ${CHECKS} checks, ${ERRORS} errors ==="

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
