#!/usr/bin/env bash
# [PreToolUse:Bash] Quality gate: lint staged files before commit
# Runs ESLint and Prettier on staged files (project config decides targets)
# Graceful skip if tools not installed
# exit 2 = block tool execution in Claude Code

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract command
COMMAND=$(json_input_val "$INPUT" "" input command)

# Only check git commit commands
if ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# Skip on main/master (guard-main.sh already blocks commits there)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  exit 0
fi

# Get staged files (Added, Copied, Modified only)
STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
if [ -z "$STAGED" ]; then
  exit 0
fi

ERRORS=""

# ESLint (project config decides which files to lint)
if [ -f "node_modules/.bin/eslint" ]; then
  if ! echo "$STAGED" | xargs npx eslint --max-warnings 0 2>&1; then
    ERRORS="${ERRORS}eslint "
  fi
fi

# Prettier (project config decides which files to check)
if [ -f "node_modules/.bin/prettier" ]; then
  if ! echo "$STAGED" | xargs npx prettier --check 2>&1; then
    ERRORS="${ERRORS}prettier "
  fi
fi

if [ -n "$ERRORS" ]; then
  echo "BLOCKED: Pre-commit quality gate failed: ${ERRORS}"
  echo "Fix issues and retry the commit."
  exit 2
fi
