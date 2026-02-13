#!/usr/bin/env bash
# [SessionStart] Branch safety check + version changes + plugin updates via GitHub API

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Clean session markers from previous session
clean_session_markers

# --- Branch safety check ---
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "WARNING: On '$BRANCH' branch. Create a feature branch before making changes: /redsub-start-work [name]"
  fi
fi

# --- Claude Code version change detection ---
VERSION_FILE="$REDSUB_DIR/claude-version"

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

# --- Network checks (parallel, non-blocking, best-effort) ---
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NET_TMP=$(mktemp -d)
trap 'rm -rf "$NET_TMP"' EXIT

# Background job 1: redsub version check
(
  if [ -f "$PLUGIN_ROOT/package.json" ]; then
    curl -s --connect-timeout 2 --max-time 5 \
      "https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json" \
      > "$NET_TMP/redsub-remote.json" 2>/dev/null || true
  fi
) &
PID_REDSUB=$!

# Background job 2: marketplace plugin update check
MARKETPLACE_OFFICIAL="$HOME/.claude/plugins/marketplaces/claude-plugins-official"
(
  if [ -d "$MARKETPLACE_OFFICIAL/.git" ]; then
    git -C "$MARKETPLACE_OFFICIAL" ls-remote origin HEAD 2>/dev/null \
      | cut -f1 > "$NET_TMP/marketplace-sha.txt" || true
  fi
) &
PID_MARKETPLACE=$!

wait "$PID_REDSUB" 2>/dev/null || true
wait "$PID_MARKETPLACE" 2>/dev/null || true

# Process redsub version result
if [ -f "$PLUGIN_ROOT/package.json" ]; then
  LOCAL_VER=$(json_val "$PLUGIN_ROOT/package.json" version)
  if [ -n "$LOCAL_VER" ]; then
    REMOTE_VER=""
    if [ -s "$NET_TMP/redsub-remote.json" ]; then
      REMOTE_VER=$(json_input_val "$(cat "$NET_TMP/redsub-remote.json")" "" version)
    fi
    if [ -n "$REMOTE_VER" ] && [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
      MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/redsub-plugins"
      if [ -d "$MARKETPLACE_DIR/.git" ]; then
        git -C "$MARKETPLACE_DIR" fetch origin main &>/dev/null || true
      fi
      echo "UPDATE: redsub-claude-code v$LOCAL_VER -> v$REMOTE_VER available. Run /redsub-update to auto-update."
    fi
  fi

  # Auto-sync install-manifest.json version after plugin update
  MANIFEST="$REDSUB_DIR/install-manifest.json"
  if [ -f "$MANIFEST" ] && [ -n "$LOCAL_VER" ]; then
    MANIFEST_VER=$(json_val "$MANIFEST" version)
    if [ -n "$MANIFEST_VER" ] && [ "$MANIFEST_VER" != "$LOCAL_VER" ]; then
      json_set_version "$MANIFEST" "$LOCAL_VER" && echo "install-manifest.json synced: v$MANIFEST_VER -> v$LOCAL_VER"
    fi
  fi
fi

# Process marketplace update result
if [ -d "$MARKETPLACE_OFFICIAL/.git" ] && [ -s "$NET_TMP/marketplace-sha.txt" ]; then
  LOCAL_SHA=$(git -C "$MARKETPLACE_OFFICIAL" rev-parse HEAD 2>/dev/null || echo "")
  REMOTE_SHA=$(cat "$NET_TMP/marketplace-sha.txt")
  if [ -n "$LOCAL_SHA" ] && [ -n "$REMOTE_SHA" ] && [ "$LOCAL_SHA" != "$REMOTE_SHA" ]; then
    echo "PLUGINS: claude-plugins-official updates available. Run 'claude plugin update <name>' to update."
  fi
fi

# --- Plugin count check (SSOT: config/plugins.json) ---
INSTALLED_COUNT=0
INSTALLED_FILE="$HOME/.claude/plugins/installed_plugins.json"
REGISTRY="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/config/plugins.json"
EXPECTED_PLUGINS=0
if [ -f "$REGISTRY" ]; then
  EXPECTED_PLUGINS=$(json_count "$REGISTRY" plugins)
fi
if [ "$EXPECTED_PLUGINS" -eq 0 ]; then
  exit 0  # SSOT registry를 읽을 수 없으면 체크 skip
fi
if [ -f "$INSTALLED_FILE" ]; then
  # Count only plugins with non-empty gitCommitSha (truly installed, not just registered)
  if command -v jq &>/dev/null; then
    INSTALLED_COUNT=$(jq '[.plugins | to_entries[] | select(.value[0].gitCommitSha | length > 0)] | length' "$INSTALLED_FILE" 2>/dev/null || echo "0")
  else
    INSTALLED_COUNT=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f: data = json.load(f)
print(sum(1 for v in data.get('plugins',{}).values() if v and v[0].get('gitCommitSha')))
" "$INSTALLED_FILE" 2>/dev/null || echo "0")
  fi
fi
if [ "$INSTALLED_COUNT" -lt "$EXPECTED_PLUGINS" ]; then
  echo "SETUP: Some dependency plugins may be missing ($INSTALLED_COUNT/$EXPECTED_PLUGINS). Run /redsub-doctor to check."
fi

# --- Legacy rules cleanup detection (v3.0+) ---
if ls "$HOME/.claude/rules/redsub-"*.md &>/dev/null 2>&1; then
  LEGACY_COUNT=$(ls -1 "$HOME/.claude/rules/redsub-"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "CLEANUP: Legacy rules files ($LEGACY_COUNT) found in ~/.claude/rules/. Run /redsub-doctor to clean up."
fi
