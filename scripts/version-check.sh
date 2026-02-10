#!/usr/bin/env bash
# [SessionStart] Claude Code 버전 변경 감지 → 알림 출력
# $CLAUDE_ENV_FILE을 사용하여 버전 정보를 영속화

set -euo pipefail

VERSION_FILE="$HOME/.claude-redsub/claude-version"
mkdir -p "$HOME/.claude-redsub"

# 현재 Claude Code 버전 획득
CURRENT_VERSION=""
if command -v claude &>/dev/null; then
  CURRENT_VERSION=$(claude --version 2>/dev/null || echo "unknown")
fi

if [ -z "$CURRENT_VERSION" ] || [ "$CURRENT_VERSION" = "unknown" ]; then
  exit 0
fi

# 저장된 버전과 비교
if [ -f "$VERSION_FILE" ]; then
  SAVED_VERSION=$(cat "$VERSION_FILE")
  if [ "$SAVED_VERSION" != "$CURRENT_VERSION" ]; then
    echo "⚠️  Claude Code 업데이트 감지: $SAVED_VERSION → $CURRENT_VERSION"
    echo "   /update-check 실행을 권장합니다."
    echo "$CURRENT_VERSION" > "$VERSION_FILE"
  fi
else
  # 최초 실행 — 버전 저장
  echo "$CURRENT_VERSION" > "$VERSION_FILE"
fi
