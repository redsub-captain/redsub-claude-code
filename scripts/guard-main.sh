#!/usr/bin/env bash
# [PreToolUse:Bash] main/master 브랜치에서 직접 커밋 차단
# exit 2 = Claude Code에서 도구 실행 차단

set -euo pipefail

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# 명령어 추출
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input',{}).get('command',''))" 2>/dev/null || echo "")

# git commit 명령인지 확인
if ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# 현재 브랜치 확인
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "❌ main/master 브랜치에 직접 커밋할 수 없습니다."
  echo "   /start-work [branch-name]으로 feature 브랜치를 생성하세요."
  exit 2
fi
