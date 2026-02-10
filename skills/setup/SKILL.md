---
name: setup
description: 플러그인 초기 설정. rules 배포, CLAUDE.md 생성, 환경변수 확인.
disable-model-invocation: true
---

# 초기 설정

## 중복 실행 방지

`~/.claude-redsub/.setup-done` 파일이 존재하면 이미 설정된 상태입니다.
`--force` 인수가 주어지지 않았다면 "이미 설정되어 있습니다. --force로 재실행 가능합니다." 메시지를 출력하고 종료하세요.

## 설정 순서

### 1. Rules 배포

플러그인의 `rules/` 디렉토리에 있는 5개 규칙 파일을 `~/.claude/rules/`에 복사합니다:
- `code-quality.md`
- `database.md`
- `security.md`
- `workflow.md`
- `testing.md`

```bash
mkdir -p ~/.claude/rules
cp ${CLAUDE_PLUGIN_ROOT}/rules/*.md ~/.claude/rules/
```

### 2. CLAUDE.md 생성

프로젝트 루트에 `CLAUDE.md`가 없으면 템플릿에서 생성합니다:

```bash
if [ ! -f CLAUDE.md ]; then
  cp ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template CLAUDE.md
fi
```

이미 존재하면 덮어쓰지 않습니다. 사용자에게 알립니다.

### 3. 환경변수 확인

다음 환경변수가 설정되어 있는지 확인하고, 없으면 경고합니다:
- `STITCH_API_KEY` — Google Stitch MCP에 필요

### 4. LSP 의존성 확인

`typescript-language-server`가 설치되어 있는지 확인합니다:

```bash
command -v typescript-language-server
```

없으면 설치를 안내합니다:
```
npm install -g typescript-language-server typescript
```

### 5. 완료 마커 생성

```bash
mkdir -p ~/.claude-redsub
date > ~/.claude-redsub/.setup-done
```

### 6. 결과 요약

설정 결과를 요약하여 출력합니다:
- Rules 배포 완료 (5개)
- CLAUDE.md 상태 (생성/이미 존재)
- 환경변수 상태
- LSP 상태
