---
name: start-work
description: feature 브랜치 생성 후 작업 시작.
disable-model-invocation: true
argument-hint: "[branch-name]"
---

# 브랜치 생성

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

브랜치 생성 결과를 출력합니다:
```
✅ 브랜치 feature/$ARGUMENTS 생성 완료.
   작업을 시작하세요.
```
