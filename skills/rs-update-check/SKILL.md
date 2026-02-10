---
name: rs-update-check
description: Claude Code 버전 변경 시 릴리즈 노트 분석 및 플러그인 호환성 확인.
context: fork
agent: planner
---

# Claude Code 업데이트 확인

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 절차

### 1. 버전 확인

현재 Claude Code 버전과 이전 버전을 비교합니다:
```bash
claude --version
cat ~/.claude-redsub/claude-version
```

### 2. 릴리즈 노트 분석

WebSearch로 Claude Code 릴리즈 노트를 검색합니다:
- 새로운 기능
- 변경된 API/동작
- 제거된 기능
- breaking changes

### 3. 플러그인 호환성 체크

릴리즈 노트를 기반으로 플러그인의 다음 파일들을 점검합니다:
- `hooks/hooks.json` — 훅 이벤트/매처 변경 여부
- `skills/*/SKILL.md` — frontmatter 필드 변경 여부
- `agents/*.md` — 에이전트 설정 변경 여부
- `.mcp.json` — MCP 설정 변경 여부
- `.lsp.json` — LSP 설정 변경 여부

### 4. 영향 보고서 생성

```markdown
## Update Report: Claude Code [prev] → [current]

### Summary
- Compatibility: ✅ No issues / ⚠️ Changes needed

### New features (applicable)
- [feature]: [how to leverage in plugin]

### Changes needed
- `[file:line]` — [change] → [fix]

### Removed features
- [impact analysis]
```

> 위 구조를 유지하되, 사용자 언어 설정에 맞춰 헤더와 내용을 작성하세요.

### 5. COMPATIBILITY.md 갱신

보고서 내용을 COMPATIBILITY.md에 추가합니다.

## 주의사항

- **읽기 전용**입니다. 플러그인 파일을 직접 수정하지 않습니다.
- 구체적인 파일:라인 수준의 변경 목록을 제시하여 사용자가 바로 수정할 수 있게 합니다.
