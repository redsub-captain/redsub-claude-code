#!/usr/bin/env bash
# [PostToolUse:Edit|Write] 파일 수정 후 prettier 자동 실행
# prettier가 없으면 무동작

set -euo pipefail

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# 수정된 파일 경로 추출
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input',{}).get('file_path',''))" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# prettier가 설치되어 있는 경우에만 실행
if command -v npx &>/dev/null && [ -f "node_modules/.bin/prettier" ]; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
fi
