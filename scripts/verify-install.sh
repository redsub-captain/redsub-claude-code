#!/usr/bin/env bash
# [Verification] Static validation of plugin file structure
# Checks file existence, JSON validity, executable permissions, reference consistency

set -euo pipefail
source "$(dirname "$0")/lib.sh"

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
    if json_valid "$PLUGIN_ROOT/$f"; then
      check "ok" "$f — valid JSON"
    else
      check "fail" "$f — JSON parse error"
    fi
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 2. Skills (auto-discovered from filesystem)
SKILLS=$(ls -d "$PLUGIN_ROOT"/skills/*/SKILL.md 2>/dev/null | while read -r f; do basename "$(dirname "$f")"; done)
SKILL_COUNT=$(echo "$SKILLS" | wc -w | tr -d ' ')
echo "[Skills ($SKILL_COUNT)]"
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

# 3. Agents (auto-discovered from filesystem)
AGENTS=$(ls "$PLUGIN_ROOT"/agents/*.md 2>/dev/null | while read -r f; do basename "$f" .md; done)
AGENT_COUNT=$(echo "$AGENTS" | wc -w | tr -d ' ')
echo "[Agents ($AGENT_COUNT)]"
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
for f in "agents/reviewer.md" "agents/designer.md" "rules/security.md" "rules/database.md" ".lsp.json" "skills/redsub-design/SKILL.md" "templates/design-guide.template.md"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "fail" "$f — should be deleted but still exists"
  else
    check "ok" "$f — correctly absent"
  fi
done

echo ""

# 5. Rules (auto-discovered from filesystem)
RULES=$(ls "$PLUGIN_ROOT"/rules/redsub-*.md 2>/dev/null | while read -r f; do basename "$f" .md; done)
RULE_COUNT=$(echo "$RULES" | wc -w | tr -d ' ')
echo "[Rules ($RULE_COUNT)]"
for rule in $RULES; do
  f="rules/$rule.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "ok" "$f"
  else
    check "fail" "$f — file not found"
  fi
done

echo ""

# 6. Scripts (auto-discovered from filesystem)
SCRIPTS=$(ls "$PLUGIN_ROOT"/scripts/*.sh 2>/dev/null | while read -r f; do basename "$f"; done)
SCRIPT_COUNT=$(echo "$SCRIPTS" | wc -w | tr -d ' ')
echo "[Scripts ($SCRIPT_COUNT)]"
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
LEGACY_COUNT=$(set +o pipefail; grep -r --include='*.md' '/rs-' "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/agents/" "$PLUGIN_ROOT/rules/" 2>/dev/null | grep -v "redsub-doctor" | wc -l | tr -d ' ')
if [ "$LEGACY_COUNT" = "0" ]; then
  check "ok" "No legacy /rs- references found (excluding redsub-doctor diagnostics)"
else
  check "fail" "$LEGACY_COUNT legacy /rs- references found"
  grep -r --include='*.md' '/rs-' "$PLUGIN_ROOT/skills/" "$PLUGIN_ROOT/agents/" "$PLUGIN_ROOT/rules/" 2>/dev/null | grep -v "redsub-doctor" | head -5
fi

echo ""

# 8. Version consistency
echo "[Version Consistency]"
PLUGIN_VER=$(json_val "$PLUGIN_ROOT/.claude-plugin/plugin.json" version)
PKG_VER=$(json_val "$PLUGIN_ROOT/package.json" version)
MKT_VER=$(json_val "$PLUGIN_ROOT/.claude-plugin/marketplace.json" plugins 0 version)

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

# 10. Asset count summary (all auto-discovered)
echo "[Asset Counts]"
ACTUAL_HOOKS=$(json_count "$PLUGIN_ROOT/hooks/hooks.json" hooks)
ACTUAL_MCPS=$(json_count "$PLUGIN_ROOT/.mcp.json" mcpServers)
check "ok" "Skills: $SKILL_COUNT, Agents: $AGENT_COUNT, Rules: $RULE_COUNT, Scripts: $SCRIPT_COUNT"
check "ok" "Hooks: $ACTUAL_HOOKS registered, MCPs: $ACTUAL_MCPS configured"

echo ""

# 11. Plugin registry drift detection (SSOT: config/plugins.json)
echo "[Plugin Registry (SSOT)]"
REGISTRY="$PLUGIN_ROOT/config/plugins.json"
if [ -f "$REGISTRY" ]; then
  EXPECTED_PLUGINS=$(json_count "$REGISTRY" plugins)

  # Check README files (static copies that need manual sync)
  SSOT_NAMES=$(json_list_field "$REGISTRY" plugins name)

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
