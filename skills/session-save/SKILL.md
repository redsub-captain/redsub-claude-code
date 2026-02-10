---
name: session-save
description: 세션 컨텍스트를 저장하여 다음 세션에서 이어서 작업.
disable-model-invocation: true
---

# 세션 컨텍스트 저장

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 절차

### 1. 진행 중 작업 기록

CLAUDE.md의 "진행 중" 섹션을 현재 작업 상태로 갱신합니다:

```markdown
## In progress
- Branch: [current branch]
- Task: [current task description]
- Next: [what to do next]
- Last saved: [date/time]
```

> 위 구조를 유지하되, 사용자 언어 설정에 맞춰 헤더와 내용을 작성하세요.

### 2. 미커밋 변경 처리

미커밋 변경이 있으면 WIP 커밋을 생성합니다:
```bash
git add -A
git commit -m "wip: session save"
```

변경이 없으면 건너뜁니다.

### 3. 확인

```
✅ Session saved
- CLAUDE.md updated: [yes/no]
- WIP commit: [yes/no]
- Branch: [current branch]
```

> 사용자 언어 설정에 맞춰 작성하세요.

## 다음 세션에서

다음 세션 시작 시 CLAUDE.md의 "진행 중" 섹션을 읽고 이전 작업을 이어갑니다.
