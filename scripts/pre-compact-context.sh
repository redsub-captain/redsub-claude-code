#!/usr/bin/env bash
# [PreCompact] 컨텍스트 압축 전 진행 중인 작업 정보 보존
# 현재 브랜치, 미커밋 변경, 최근 커밋을 요약하여 stdout으로 출력

set -euo pipefail

echo "=== 컨텍스트 보존 ==="

# 현재 브랜치
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "없음")
echo "브랜치: $BRANCH"

# 미커밋 변경 수
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
echo "미커밋 변경: ${CHANGES}개"

# 최근 커밋 3개
echo "최근 커밋:"
git log --oneline -3 2>/dev/null || echo "  (커밋 없음)"

echo "===================="
