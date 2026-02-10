#!/usr/bin/env bash
# [SessionStart] Detect Claude Code version changes + check plugin updates via GitHub API

set -euo pipefail

VERSION_FILE="$HOME/.claude-redsub/claude-version"
mkdir -p "$HOME/.claude-redsub"

# Get current Claude Code version
CURRENT_VERSION=""
if command -v claude &>/dev/null; then
  CURRENT_VERSION=$(claude --version 2>/dev/null || echo "unknown")
fi

if [ -z "$CURRENT_VERSION" ] || [ "$CURRENT_VERSION" = "unknown" ]; then
  exit 0
fi

# Compare with saved version
if [ -f "$VERSION_FILE" ]; then
  SAVED_VERSION=$(cat "$VERSION_FILE")
  if [ "$SAVED_VERSION" != "$CURRENT_VERSION" ]; then
    echo "Claude Code updated: $SAVED_VERSION -> $CURRENT_VERSION. Run /redsub-update to check compatibility."
    echo "$CURRENT_VERSION" > "$VERSION_FILE"
  fi
else
  # First run — save version
  echo "$CURRENT_VERSION" > "$VERSION_FILE"
fi

# Check plugin updates (non-blocking, best-effort)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$PLUGIN_ROOT/package.json" ]; then
  LOCAL_VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/package.json'))['version'])" 2>/dev/null || echo "")
  if [ -n "$LOCAL_VER" ]; then
    REMOTE_VER=$(curl -s --connect-timeout 2 "https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "")
    if [ -n "$REMOTE_VER" ] && [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
      echo "Plugin update available: v$LOCAL_VER -> v$REMOTE_VER. Run /redsub-update for details."
    fi
  fi
fi
