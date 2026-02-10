#!/usr/bin/env bash
# [PostToolUse:Bash] validate 스킬 성공 시 마커 파일 생성
# merge 전 validate 실행 여부를 확인하기 위한 마커

set -euo pipefail

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# 실행된 명령어 추출
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input',{}).get('command',''))" 2>/dev/null || echo "")

# npm run lint, npm run check, npm run test:unit 모두 포함된 경우 마커 생성
if echo "$COMMAND" | grep -q "npm run lint" && echo "$COMMAND" | grep -q "npm run check"; then
  # 실행 결과가 성공인지 확인
  EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('output',{}).get('exitCode',1))" 2>/dev/null || echo "1")
  if [ "$EXIT_CODE" = "0" ]; then
    touch /tmp/.claude-redsub-validated
  fi
fi
