#!/usr/bin/env bash
# [Notification] macOS desktop notification when user attention is needed
# Triggered on permission_prompt and idle_prompt events

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract notification type
NOTIFICATION_TYPE=$(json_input_val "$INPUT" "attention" type)

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

# macOS notification (safe_osascript escapes special characters)
safe_osascript "$TITLE" "$MESSAGE"
