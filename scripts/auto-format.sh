#!/usr/bin/env bash
# [PostToolUse:Edit|Write] Auto-run prettier after file modification
# No-op if prettier is not installed

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract modified file path
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input',{}).get('file_path',''))" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only run if prettier is installed locally
if command -v npx &>/dev/null && [ -f "node_modules/.bin/prettier" ]; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
fi
