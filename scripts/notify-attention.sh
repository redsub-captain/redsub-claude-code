#!/usr/bin/env bash
# [Notification] 사용자 주의 필요 시 macOS 데스크톱 알림
# permission_prompt, idle_prompt 이벤트에서 트리거

set -euo pipefail

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# 알림 타입 추출
NOTIFICATION_TYPE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('type',''))" 2>/dev/null || echo "attention")

case "$NOTIFICATION_TYPE" in
  permission_prompt)
    TITLE="Claude Code"
    MESSAGE="권한 승인이 필요합니다."
    ;;
  idle_prompt)
    TITLE="Claude Code"
    MESSAGE="입력을 기다리고 있습니다."
    ;;
  *)
    TITLE="Claude Code"
    MESSAGE="주의가 필요합니다."
    ;;
esac

# macOS 알림
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null || true
fi
