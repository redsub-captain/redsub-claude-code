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

### 1. 언어 선택

사용자에게 언어를 선택하게 합니다:
```
Select language / 언어를 선택하세요:
1. 한국어
2. English
```

선택한 언어를 저장합니다:
```bash
mkdir -p ~/.claude-redsub
echo "[ko 또는 en]" > ~/.claude-redsub/language
```

### 2. Rules 배포

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

### 3. CLAUDE.md 생성

프로젝트 루트에 `CLAUDE.md`가 없는 경우에만 템플릿에서 생성합니다:

```bash
if [ ! -f CLAUDE.md ]; then
  cp ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template CLAUDE.md
fi
```

**중요: 기존 CLAUDE.md가 있으면 절대 덮어쓰지 않습니다.**
이미 존재하는 경우 "CLAUDE.md가 이미 존재합니다. 템플릿을 참고하려면 `cat ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template`를 확인하세요."라고 안내합니다.

### 4. 환경변수 확인

다음 환경변수가 설정되어 있는지 확인하고, 없으면 경고합니다:
- `STITCH_API_KEY` — Google Stitch MCP에 필요

### 5. LSP 의존성 확인

`typescript-language-server`가 설치되어 있는지 확인합니다:

```bash
command -v typescript-language-server
```

없으면 설치를 안내합니다:
```
npm install -g typescript-language-server typescript
```

### 6. Agent Teams (실험적 기능)

사용자에게 Agent Teams 활성화 여부를 확인합니다:
```
Agent Teams 실험적 기능을 활성화하시겠습니까?
- /review, /fix-all 스킬에서 --team 옵션으로 병렬 에이전트 팀을 사용할 수 있습니다.
- --team 옵션 사용 시 토큰 사용량이 크게 증가합니다.
(y/n)
```

사용자가 승인하면 settings.json에 추가합니다:
```bash
# ~/.claude/settings.json의 env에 추가
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

거부하면 건너뜁니다.

### 7. 완료 마커 생성

```bash
mkdir -p ~/.claude-redsub
date > ~/.claude-redsub/.setup-done
```

### 8. 결과 요약

설정 결과를 요약하여 출력합니다:
- 언어 설정 (한국어/English)
- Rules 배포 완료 (5개)
- CLAUDE.md 상태 (생성/이미 존재)
- 환경변수 상태
- LSP 상태
- Agent Teams 상태 (활성화/비활성화)

> **모든 출력 메시지는 `~/.claude-redsub/language` 설정에 맞춰 작성하세요.**
