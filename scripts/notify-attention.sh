#!/usr/bin/env bash
# [Notification] macOS desktop notification when user attention is needed
# Triggered on permission_prompt and idle_prompt events

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract notification type
NOTIFICATION_TYPE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('type',''))" 2>/dev/null || echo "attention")

case "$NOTIFICATION_TYPE" in
  permission_prompt)
    TITLE="Claude Code"
    MESSAGE="Permission approval needed."
    ;;
  idle_prompt)
    TITLE="Claude Code"
    MESSAGE="Waiting for your input."
    ;;
  *)
    TITLE="Claude Code"
    MESSAGE="Your attention is needed."
    ;;
esac

# macOS notification
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null || true
fi
