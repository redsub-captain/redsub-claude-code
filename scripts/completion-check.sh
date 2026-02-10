#!/usr/bin/env bash
# [Stop] 세션 종료 시 미완료 작업 확인 + 완료 알림
# 미커밋 변경이 있으면 경고, 없으면 완료 알림

set -euo pipefail

# 미커밋 변경 확인
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES" -gt 0 ]; then
  echo "⚠️  미커밋 변경 ${CHANGES}개가 있습니다. /save 또는 /session-save를 고려하세요."
fi

# macOS 완료 알림
if command -v osascript &>/dev/null; then
  if [ "$CHANGES" -gt 0 ]; then
    osascript -e "display notification \"미커밋 변경 ${CHANGES}개 있음\" with title \"Claude Code 세션 종료\"" 2>/dev/null || true
  else
    osascript -e "display notification \"작업 완료\" with title \"Claude Code 세션 종료\"" 2>/dev/null || true
  fi
fi
