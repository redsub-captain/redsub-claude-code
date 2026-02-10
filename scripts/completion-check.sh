#!/usr/bin/env bash
# [Stop] Check for uncommitted changes on session end + completion notification

set -euo pipefail

# Check uncommitted changes
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES" -gt 0 ]; then
  echo "WARNING: ${CHANGES} uncommitted changes. Consider /redsub-session-save."
fi

# macOS completion notification
if command -v osascript &>/dev/null; then
  if [ "$CHANGES" -gt 0 ]; then
    osascript -e "display notification \"${CHANGES} uncommitted changes\" with title \"Claude Code Session End\"" 2>/dev/null || true
  else
    osascript -e "display notification \"Work complete\" with title \"Claude Code Session End\"" 2>/dev/null || true
  fi
fi
