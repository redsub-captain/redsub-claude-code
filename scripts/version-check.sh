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

# --- Claude Code version change detection ---
VERSION_FILE="$HOME/.claude-redsub/claude-version"
mkdir -p "$HOME/.claude-redsub"

CURRENT_VERSION=""
if command -v claude &>/dev/null; then
  CURRENT_VERSION=$(claude --version 2>/dev/null || echo "")
fi

if [ -n "$CURRENT_VERSION" ]; then
  if [ -f "$VERSION_FILE" ]; then
    SAVED_VERSION=$(cat "$VERSION_FILE")
    if [ "$SAVED_VERSION" != "$CURRENT_VERSION" ]; then
      echo "Claude Code updated: $SAVED_VERSION -> $CURRENT_VERSION. Run /redsub-update to check compatibility."
      echo "$CURRENT_VERSION" > "$VERSION_FILE"
    fi
  else
    echo "$CURRENT_VERSION" > "$VERSION_FILE"
  fi
fi

# Check plugin updates (non-blocking, best-effort)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$PLUGIN_ROOT/package.json" ]; then
  LOCAL_VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/package.json'))['version'])" 2>/dev/null || echo "")
  if [ -n "$LOCAL_VER" ]; then
    REMOTE_VER=$(curl -s --connect-timeout 2 "https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "")
    if [ -n "$REMOTE_VER" ] && [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
      # Pre-fetch marketplace repo so /redsub-update or /plugin update can see the new version
      MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/redsub-plugins"
      if [ -d "$MARKETPLACE_DIR/.git" ]; then
        git -C "$MARKETPLACE_DIR" fetch origin main &>/dev/null || true
      fi
      echo "UPDATE: redsub-claude-code v$LOCAL_VER -> v$REMOTE_VER available. Run /redsub-update to auto-update."
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

# --- Plugin count check (reads from SSOT: config/plugins.json) ---
INSTALLED_COUNT=0
INSTALLED_FILE="$HOME/.claude/plugins/installed_plugins.json"
REGISTRY="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/config/plugins.json"
EXPECTED_PLUGINS=13
if [ -f "$REGISTRY" ]; then
  EXPECTED_PLUGINS=$(python3 -c "import json; print(len(json.load(open('$REGISTRY'))['plugins']))" 2>/dev/null || echo 13)
fi
if [ -f "$INSTALLED_FILE" ]; then
  INSTALLED_COUNT=$(python3 -c "import json; print(len(json.load(open('$INSTALLED_FILE'))))" 2>/dev/null || echo 0)
fi
if [ "$INSTALLED_COUNT" -lt "$EXPECTED_PLUGINS" ]; then
  echo "SETUP: Some dependency plugins may be missing ($INSTALLED_COUNT/$EXPECTED_PLUGINS). Run /redsub-doctor to check."
fi

# --- CLAUDE.md freshness check ---
if [ -f "CLAUDE.md" ]; then
  LAST_MOD=$(stat -f %m "CLAUDE.md" 2>/dev/null || stat -c %Y "CLAUDE.md" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  DAYS=$(( (NOW - LAST_MOD) / 86400 ))
  if [ "$DAYS" -ge 7 ]; then
    echo "MAINTENANCE: CLAUDE.md hasn't been updated in ${DAYS} days. Run /revise-claude-md."
  fi
fi
