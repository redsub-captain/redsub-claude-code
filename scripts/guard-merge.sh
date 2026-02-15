#!/usr/bin/env bash
# [PreToolUse:Bash] CI status check before gh pr merge
# exit 2 = block (CI failed), exit 0 = allow/warn

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract command
COMMAND=$(json_input_val "$INPUT" "" input command)

# gh pr merge 아닌 명령은 즉시 통과
if ! echo "$COMMAND" | grep -qE 'gh[[:space:]]+pr[[:space:]]+merge'; then
  exit 0
fi

# gh CLI 미설치 → 경고 후 통과
if ! command -v gh &>/dev/null; then
  echo "WARNING: gh CLI not found. Skipping CI check."
  exit 0
fi

# PR 번호 추출 (없으면 현재 브랜치 PR)
PR_NUM=$(echo "$COMMAND" | grep -oE 'gh[[:space:]]+pr[[:space:]]+merge[[:space:]]+[0-9]+' \
  | grep -oE '[0-9]+' | head -1 || echo "")

# CI 체크 조회
CHECKS_JSON=$(gh pr checks $PR_NUM --json name,state,conclusion 2>&1) || {
  echo "WARNING: Could not retrieve CI status. Proceeding with merge."
  exit 0
}

# JSON 파싱 (jq 우선, python3 폴백)
parse_checks() {
  local json="$1" filter="$2"
  if command -v jq &>/dev/null; then
    echo "$json" | jq -r "$filter" 2>/dev/null || echo "0"
  else
    echo "$json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
f = sys.argv[1]
if f == 'fail_count':
    print(len([c for c in data if c.get('conclusion') == 'FAILURE']))
elif f == 'pending_count':
    print(len([c for c in data if c.get('state') != 'COMPLETED']))
elif f == 'fail_names':
    for c in data:
        if c.get('conclusion') == 'FAILURE': print('  - ' + c.get('name', 'unknown'))
elif f == 'pending_names':
    for c in data:
        if c.get('state') != 'COMPLETED': print('  - ' + c.get('name', 'unknown') + ': ' + c.get('state', 'unknown'))
" "$filter" 2>/dev/null || echo "0"
  fi
}

FAIL_COUNT=$(parse_checks "$CHECKS_JSON" '[.[] | select(.conclusion == "FAILURE")] | length')
PENDING_COUNT=$(parse_checks "$CHECKS_JSON" '[.[] | select(.state != "COMPLETED")] | length')

# 실패 → 차단
if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "BLOCKED: CI failed ($FAIL_COUNT check(s)). Fix before merging."
  if command -v jq &>/dev/null; then
    echo "$CHECKS_JSON" | jq -r '.[] | select(.conclusion == "FAILURE") | "  - \(.name)"' 2>/dev/null
  else
    parse_checks "$CHECKS_JSON" "fail_names"
  fi
  exit 2
fi

# 진행중 → 경고
if [ "$PENDING_COUNT" -gt 0 ]; then
  echo "WARNING: CI in progress ($PENDING_COUNT check(s) pending). Consider waiting."
  if command -v jq &>/dev/null; then
    echo "$CHECKS_JSON" | jq -r '.[] | select(.state != "COMPLETED") | "  - \(.name): \(.state)"' 2>/dev/null
  else
    parse_checks "$CHECKS_JSON" "pending_names"
  fi
  exit 0
fi
