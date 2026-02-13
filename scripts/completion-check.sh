#!/usr/bin/env bash
# [Stop] Check for uncommitted changes on session end + completion notification

set -uo pipefail
source "$(dirname "$0")/lib.sh"

# Check uncommitted changes
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') || CHANGES=0

if [ "$CHANGES" -gt 0 ]; then
  echo "WARNING: ${CHANGES} uncommitted changes. Consider /redsub-session-save."
fi

# --- /revise-claude-md check ---
if [ ! -f "$REDSUB_DIR/claude-md-revised" ]; then
  echo "REMINDER: Run /revise-claude-md to capture session learnings before ending."
fi

# --- Design documentation check ---
COMPONENT_EDITS=$(cat "$REDSUB_DIR/component-count" 2>/dev/null || echo 0)
if [ "$COMPONENT_EDITS" -ge 3 ]; then
  echo "DESIGN: ${COMPONENT_EDITS} component files edited. Consider documenting UI decisions with frontend-design."
fi

# --- Code quality check ---
TOTAL_EDITS=$(cat "$REDSUB_DIR/edit-count" 2>/dev/null || echo 0)
if [ "$TOTAL_EDITS" -ge 10 ]; then
  echo "QUALITY: ${TOTAL_EDITS} files edited this session. code-simplifier plugin auto-reviews for clarity."
fi

# --- Cleanup session markers ---
rm -f "$REDSUB_DIR"/claude-md-revised \
     "$REDSUB_DIR"/edit-count \
     "$REDSUB_DIR"/component-count 2>/dev/null || true

# macOS completion notification (safe_osascript escapes special characters)
if command -v osascript &>/dev/null; then
  if [ "$CHANGES" -gt 0 ]; then
    safe_osascript "Claude Code Session End" "${CHANGES} uncommitted changes"
  else
    safe_osascript "Claude Code Session End" "Work complete"
  fi
fi
