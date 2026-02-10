---
name: rs-explore
description: 코드베이스의 파일, 타입, 데이터 흐름을 조사하여 아키텍처를 파악.
context: fork
agent: planner
---

# 코드베이스 탐색

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 입력

`$ARGUMENTS`로 탐색 대상/질문을 받습니다.

## 절차

### 1. 탐색

`$ARGUMENTS`와 관련된 코드베이스를 조사합니다:
- Glob으로 관련 파일 패턴 검색
- Grep으로 키워드/타입/함수 검색
- 핵심 파일 읽기

### 2. 분석

다음을 파악합니다:
- **핵심 파일**: 관련된 주요 파일 목록
- **의존 관계**: 파일 간 import/export 관계
- **데이터 흐름**: 데이터가 어떻게 흐르는지
- **패턴**: 사용 중인 디자인 패턴/컨벤션

### 3. 출력

```markdown
## Explore: [target]

### Key files
- `path/file.ts` — [role]

### Architecture
[description]

### Data flow
[description]

### Patterns
[description]
```

> 위 구조를 유지하되, 사용자 언어 설정에 맞춰 헤더와 내용을 작성하세요.

## 주의사항

- **읽기 전용**입니다. 코드를 수정하지 않습니다.
- 추측하지 말고 실제 코드를 읽으세요.
