#!/usr/bin/env bash
# [PostToolUse:Bash] Create validate marker when lint+check pass
# Used by guard-main.sh to verify validation before merge

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract executed command
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input',{}).get('command',''))" 2>/dev/null || echo "")

# Create marker if both lint and check were in the command
if echo "$COMMAND" | grep -q "npm run lint" && echo "$COMMAND" | grep -q "npm run check"; then
  # Verify command succeeded
  EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('output',{}).get('exitCode',1))" 2>/dev/null || echo "1")
  if [ "$EXIT_CODE" = "0" ]; then
    touch /tmp/.claude-redsub-validated
  fi
fi
