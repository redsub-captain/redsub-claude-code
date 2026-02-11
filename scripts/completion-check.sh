#!/usr/bin/env bash
# [Stop] Check for uncommitted changes on session end + completion notification

set -euo pipefail

# Check uncommitted changes
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES" -gt 0 ]; then
  echo "WARNING: ${CHANGES} uncommitted changes. Consider /redsub-session-save."
fi

# --- /revise-claude-md check ---
if [ ! -f /tmp/.claude-redsub-claude-md-revised ]; then
  echo "REMINDER: Run /revise-claude-md to capture session learnings before ending."
fi

# --- Design documentation check ---
SVELTE_EDITS=$(cat /tmp/.claude-redsub-svelte-count 2>/dev/null || echo 0)
if [ "$SVELTE_EDITS" -ge 3 ]; then
  echo "DESIGN: ${SVELTE_EDITS} Svelte files edited. Consider documenting UI decisions with /redsub-design or frontend-design."
fi

# --- Code quality check ---
TOTAL_EDITS=$(cat /tmp/.claude-redsub-edit-count 2>/dev/null || echo 0)
if [ "$TOTAL_EDITS" -ge 10 ]; then
  echo "QUALITY: ${TOTAL_EDITS} files edited this session. code-simplifier plugin auto-reviews for clarity."
fi

# --- Cleanup session markers ---
rm -f /tmp/.claude-redsub-claude-md-revised
rm -f /tmp/.claude-redsub-edit-count
rm -f /tmp/.claude-redsub-svelte-count

# macOS completion notification
if command -v osascript &>/dev/null; then
  if [ "$CHANGES" -gt 0 ]; then
    osascript -e "display notification \"${CHANGES} uncommitted changes\" with title \"Claude Code Session End\"" 2>/dev/null || true
  else
    osascript -e "display notification \"Work complete\" with title \"Claude Code Session End\"" 2>/dev/null || true
  fi
fi
