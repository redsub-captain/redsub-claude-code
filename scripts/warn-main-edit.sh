#!/usr/bin/env bash
# [PreToolUse:Edit|Write] Warn (once per session) when editing files on main/master
# Does NOT block — only warns. Commits are blocked separately by guard-main.sh.

set -euo pipefail

# Skip if not in a git repo
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Only warn on main/master
if [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  exit 0
fi

# One warning per session (marker resets when /tmp is cleaned or session ends)
MARKER="/tmp/.claude-redsub-main-edit-warned-$$"

# Check for any existing marker from this parent process tree
EXISTING=$(ls /tmp/.claude-redsub-main-edit-warned-* 2>/dev/null | head -1 || echo "")

if [ -n "$EXISTING" ]; then
  # Already warned this session
  exit 0
fi

# First edit on main — show warning and create marker
touch "$MARKER"
echo "WARNING: Editing files on '$BRANCH'. Consider creating a feature branch first: /redsub-start-work [name]"
