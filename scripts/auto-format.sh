#!/usr/bin/env bash
# [PostToolUse:Edit|Write] Auto-run prettier after file modification
# No-op if prettier is not installed

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract modified file path
FILE_PATH=$(json_input_val "$INPUT" "" input file_path)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only run if prettier is installed locally
if command -v npx &>/dev/null && [ -f "node_modules/.bin/prettier" ]; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
fi

# --- Session edit tracker ---
COUNTER_FILE="$REDSUB_DIR/edit-count"
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
echo $((COUNT + 1)) > "$COUNTER_FILE"

# Track component file edits (framework-specific extensions)
if echo "$FILE_PATH" | grep -qE '\.(svelte|vue|jsx|tsx)$'; then
  COMP_FILE="$REDSUB_DIR/component-count"
  CCOUNT=$(cat "$COMP_FILE" 2>/dev/null || echo 0)
  echo $((CCOUNT + 1)) > "$COMP_FILE"
fi
