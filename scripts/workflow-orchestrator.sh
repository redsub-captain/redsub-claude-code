#!/usr/bin/env bash
# [UserPromptSubmit] Active workflow orchestration
# Injects context-aware workflow guidance into every user prompt.
# Output is visible to Claude as a system reminder, making it hard to ignore.

set -euo pipefail

# Skip if not in a git repo
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
VALIDATED=""
[ -f /tmp/.claude-redsub-validated ] && VALIDATED="yes"

# Build output — only when there's something actionable
OUTPUT=""

# Case 1: On main/master — always remind
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  if [ "$CHANGES" -gt 0 ]; then
    OUTPUT="WORKFLOW: On '$BRANCH' with $CHANGES uncommitted changes. Create a branch: /redsub-start-work [name]"
  else
    OUTPUT="WORKFLOW: On '$BRANCH'. Create a feature branch before making changes: /redsub-start-work [name]"
  fi
# Case 2: On feature branch with many uncommitted changes — remind to save/validate
elif [ "$CHANGES" -gt 20 ]; then
  OUTPUT="WORKFLOW: $CHANGES uncommitted changes on '$BRANCH'. Consider /redsub-session-save or /redsub-validate."
fi

if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
fi
