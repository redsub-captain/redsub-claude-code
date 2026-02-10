#!/usr/bin/env bash
# [검증] 플러그인 정적 파일 검증
# 파일 존재, JSON 유효성, 실행 권한 체크

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
CHECKS=0

check() {
  CHECKS=$((CHECKS + 1))
  if [ "$1" = "ok" ]; then
    echo "  ✅ $2"
  else
    echo "  ❌ $2"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== redsub-claude-code 정적 검증 ==="
echo ""

# JSON 유효성 검사
echo "[JSON 파일]"
for f in ".claude-plugin/plugin.json" ".mcp.json" ".lsp.json" "hooks/hooks.json"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if python3 -m json.tool "$PLUGIN_ROOT/$f" > /dev/null 2>&1; then
      check "ok" "$f — 유효한 JSON"
    else
      check "fail" "$f — JSON 파싱 실패"
    fi
  else
    check "fail" "$f — 파일 없음"
  fi
done

echo ""

# 스킬 파일 확인
echo "[스킬 (15개)]"
SKILLS="setup plan start-work save explore fix-all design test validate review ship deploy status session-save update-check"
for skill in $SKILLS; do
  f="skills/$skill/SKILL.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    # frontmatter 존재 확인
    if head -1 "$PLUGIN_ROOT/$f" | grep -q "^---"; then
      check "ok" "$f"
    else
      check "fail" "$f — frontmatter 없음"
    fi
  else
    check "fail" "$f — 파일 없음"
  fi
done

echo ""

# 에이전트 파일 확인
echo "[에이전트 (5개)]"
AGENTS="developer reviewer planner devops designer"
for agent in $AGENTS; do
  f="agents/$agent.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if head -1 "$PLUGIN_ROOT/$f" | grep -q "^---"; then
      check "ok" "$f"
    else
      check "fail" "$f — frontmatter 없음"
    fi
  else
    check "fail" "$f — 파일 없음"
  fi
done

echo ""

# Rules 파일 확인
echo "[Rules (5개)]"
RULES="code-quality database security workflow testing"
for rule in $RULES; do
  f="rules/$rule.md"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "ok" "$f"
  else
    check "fail" "$f — 파일 없음"
  fi
done

echo ""

# 스크립트 파일 확인 (실행 권한)
echo "[스크립트 (실행 권한)]"
SCRIPTS="version-check.sh guard-main.sh validate-marker.sh auto-format.sh notify-attention.sh pre-compact-context.sh completion-check.sh"
for script in $SCRIPTS; do
  f="scripts/$script"
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    if [ -x "$PLUGIN_ROOT/$f" ]; then
      check "ok" "$f — 실행 가능"
    else
      check "fail" "$f — 실행 권한 없음 (chmod +x 필요)"
    fi
  else
    check "fail" "$f — 파일 없음"
  fi
done

echo ""

# 템플릿 확인
echo "[기타]"
for f in "templates/CLAUDE.md.template" "package.json" "README.md" "COMPATIBILITY.md" "LICENSE"; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    check "ok" "$f"
  else
    check "fail" "$f — 파일 없음"
  fi
done

echo ""
echo "=== 결과: ${CHECKS}개 체크, ${ERRORS}개 오류 ==="

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
