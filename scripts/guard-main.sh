#!/usr/bin/env bash
# [PreToolUse:Bash] Block direct commits on main/master + block merge without validate marker
# exit 2 = block tool execution in Claude Code

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract command
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input',{}).get('command',''))" 2>/dev/null || echo "")

# Check if git merge command — require validate marker + version consistency
if echo "$COMMAND" | grep -q "git merge"; then
  if [ ! -f /tmp/.claude-redsub-validated ]; then
    echo "BLOCKED: Cannot merge without validation. Run /redsub-validate first."
    exit 2
  fi

  # Version consistency check across 3 files
  PKG_VER=$(python3 -c "import json; print(json.load(open('package.json'))['version'])" 2>/dev/null || echo "")
  PLUGIN_VER=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "")
  MKT_VER=$(python3 -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['plugins'][0]['version'])" 2>/dev/null || echo "")

  if [ -n "$PKG_VER" ] && { [ "$PKG_VER" != "$PLUGIN_VER" ] || [ "$PKG_VER" != "$MKT_VER" ]; }; then
    echo "BLOCKED: Version mismatch — package.json: $PKG_VER, plugin.json: $PLUGIN_VER, marketplace.json: $MKT_VER"
    echo "All 3 files must have the same version before merge. Fix with /redsub-ship."
    exit 2
  fi

  exit 0
fi

# Check if git commit command
if ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# Check current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "BLOCKED: Cannot commit directly to $BRANCH. Use /redsub-start-work [name] to create a feature branch."
  exit 2
fi
