#!/usr/bin/env bash
# [PreToolUse:Edit|Write] Warn (once per session) when editing files on main/master
# Does NOT block — only warns. Commits are blocked separately by guard-main.sh.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Skip if not in a git repo
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Only warn on main/master
if [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  exit 0
fi

# One warning per session (marker resets at SessionStart via clean_session_markers)
if [ -f "$REDSUB_DIR/main-edit-warned" ]; then
  exit 0
fi

# First edit on main — show warning and create marker
touch "$REDSUB_DIR/main-edit-warned"
chmod 600 "$REDSUB_DIR/main-edit-warned"
echo "WARNING: Editing files on '$BRANCH'. Consider creating a feature branch first: /redsub-start-work [name]"
