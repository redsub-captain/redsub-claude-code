#!/usr/bin/env bash
# [PreToolUse:Bash] Quality gate: type-check + unit test before push
# Only gates pushes to main/master (feature pushes already blocked by guard-push)
# Graceful skip if no check/test scripts found
# exit 2 = block tool execution in Claude Code

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract command
COMMAND=$(json_input_val "$INPUT" "" input command)

# Only check git push commands
if ! echo "$COMMAND" | grep -qE 'git[[:space:]]+push'; then
  exit 0
fi

# Skip if no package.json (not a Node project)
if [ ! -f "package.json" ]; then
  exit 0
fi

# Detect package manager
PM="npm"
[ -f "pnpm-lock.yaml" ] && PM="pnpm"
[ -f "yarn.lock" ] && PM="yarn"

ERRORS=""

# Type check: find check/typecheck/type-check script
CHECK=$(node -p "Object.keys(require('./package.json').scripts||{}).find(s=>/^(check|typecheck|type-check)$/.test(s))||''" 2>/dev/null || echo "")
if [ -n "$CHECK" ]; then
  if ! $PM run "$CHECK" 2>&1; then
    ERRORS="${ERRORS}type-check "
  fi
fi

# Unit test: find test or test:unit script
TEST=$(node -p "Object.keys(require('./package.json').scripts||{}).find(s=>/^test(:unit)?$/.test(s))||''" 2>/dev/null || echo "")
if [ -n "$TEST" ]; then
  # Detect vitest watch mode — append --run if needed
  TEST_CMD=$(node -p "require('./package.json').scripts['$TEST']" 2>/dev/null || echo "")
  if echo "$TEST_CMD" | grep -q "vitest" && ! echo "$TEST_CMD" | grep -q -- "--run"; then
    if ! $PM run "$TEST" -- --run 2>&1; then
      ERRORS="${ERRORS}unit-test "
    fi
  else
    if ! $PM run "$TEST" 2>&1; then
      ERRORS="${ERRORS}unit-test "
    fi
  fi
fi

if [ -n "$ERRORS" ]; then
  echo "BLOCKED: Pre-push quality gate failed: ${ERRORS}"
  echo "Fix issues and retry the push."
  exit 2
fi
