---
name: rs-start-work
description: feature 브랜치 생성 후 작업 시작.
disable-model-invocation: true
argument-hint: "[branch-name]"
---

# 브랜치 생성

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 입력

`$ARGUMENTS`로 브랜치 이름을 받습니다.

## 절차

### 1. 최신 main 동기화

```bash
git fetch origin && git pull origin main
```

원격 저장소가 없으면 (로컬 전용 저장소) fetch/pull을 건너뜁니다.

### 2. 브랜치 생성

```bash
git checkout -b feature/$ARGUMENTS
```

`$ARGUMENTS`가 이미 `feature/`, `fix/`, `chore/` 접두사를 포함하고 있으면 그대로 사용합니다.

### 3. 확인

브랜치 생성 결과를 사용자 언어에 맞춰 출력합니다:
```
✅ Branch feature/$ARGUMENTS created. Ready to work.
```
