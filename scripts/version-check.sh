#!/usr/bin/env bash
# [SessionStart] Branch safety check + version changes + plugin updates via GitHub API

set -euo pipefail

# --- Branch safety check ---
# Warn if starting a session on main/master (work should happen on feature branches)
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "WARNING: On '$BRANCH' branch. Create a feature branch before making changes: /redsub-start-work [name]"
  fi
fi

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
      echo "UPDATE: redsub-claude-code v$LOCAL_VER -> v$REMOTE_VER available. Run /plugin -> Installed -> redsub-claude-code -> Update now, then start a new session."
    fi
  fi

  # Auto-sync install-manifest.json version after plugin update
  MANIFEST="$HOME/.claude-redsub/install-manifest.json"
  if [ -f "$MANIFEST" ] && [ -n "$LOCAL_VER" ]; then
    MANIFEST_VER=$(python3 -c "import json; print(json.load(open('$MANIFEST'))['version'])" 2>/dev/null || echo "")
    if [ -n "$MANIFEST_VER" ] && [ "$MANIFEST_VER" != "$LOCAL_VER" ]; then
      python3 -c "
import json
with open('$MANIFEST', 'r') as f:
    data = json.load(f)
data['version'] = '$LOCAL_VER'
with open('$MANIFEST', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null && echo "install-manifest.json synced: v$MANIFEST_VER -> v$LOCAL_VER"
    fi
  fi
fi
