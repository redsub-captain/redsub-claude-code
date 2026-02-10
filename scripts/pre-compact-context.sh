#!/usr/bin/env bash
# [PreCompact] Preserve work-in-progress context before context compression
# Outputs current branch, uncommitted changes, and recent commits to stdout

set -euo pipefail

echo "=== Context Preservation ==="

# Current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "none")
echo "Branch: $BRANCH"

# Uncommitted changes count
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
echo "Uncommitted changes: ${CHANGES}"

# Recent 3 commits
echo "Recent commits:"
git log --oneline -3 2>/dev/null || echo "  (no commits)"

echo "=========================="
