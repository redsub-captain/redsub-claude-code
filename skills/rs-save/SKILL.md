---
name: rs-save
description: 변경사항 WIP 커밋.
disable-model-invocation: true
argument-hint: "[description]"
---

# WIP 커밋

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 입력

`$ARGUMENTS`로 변경 설명을 받습니다.

## 절차

### 1. 브랜치 확인

현재 main/master 브랜치가 아닌지 확인합니다.
main/master라면 feature 브랜치에서만 커밋 가능하다고 사용자 언어에 맞춰 안내합니다.

### 2. 변경 확인

```bash
git status --short
```

변경이 없으면 커밋할 변경이 없다고 사용자 언어에 맞춰 안내하고 종료합니다.

### 3. 커밋

```bash
git add -A
git commit -m "wip: $ARGUMENTS"
```

### 4. 확인

커밋 결과를 출력합니다.
