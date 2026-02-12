#!/usr/bin/env bash
# [PostToolUse:Bash] Create validate marker when lint+check pass
# Used by guard-main.sh to verify validation before merge

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract executed command
COMMAND=$(json_input_val "$INPUT" "" input command)

# Create marker if both lint and check were in the command (any package manager)
if echo "$COMMAND" | grep -qE "(npm|pnpm|yarn) run lint" && echo "$COMMAND" | grep -qE "(npm|pnpm|yarn) run check"; then
  # Verify command succeeded
  EXIT_CODE=$(json_input_val "$INPUT" "1" output exitCode)
  if [ "$EXIT_CODE" = "0" ]; then
    touch "$REDSUB_DIR/validated"
    chmod 600 "$REDSUB_DIR/validated"
  fi
fi
