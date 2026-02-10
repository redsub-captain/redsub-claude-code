---
name: review
description: 보안, 타입, 성능, DB, 테스트 관점에서 코드 리뷰.
context: fork
agent: reviewer
argument-hint: "[--team] [target-path]"
---

# 코드 리뷰

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 입력

`$ARGUMENTS`로 리뷰 대상 경로를 받습니다. 생략 시 최근 변경 파일(`git diff --name-only main..HEAD`)을 대상으로 합니다.

## 모드 선택

### 기본 모드 (단일 리뷰어)

`--team` 없이 실행하면 reviewer 서브에이전트가 모든 관점을 순차 리뷰합니다.

### 팀 모드 (`--team`)

`--team` 인수가 포함되어 있으면 Agent Teams를 사용하여 **병렬 리뷰**를 실행합니다.

> Agent Teams가 활성화되어 있어야 합니다 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).
> 활성화되지 않은 경우 Agent Teams가 비활성화 상태이며 `/setup --force`로 활성화할 수 있다고 사용자 언어에 맞춰 안내합니다.

3명의 리뷰어를 동시에 생성합니다:
- **보안 리뷰어**: API 키 노출, 입력 검증, 인증/인가, RLS/Security Rules
- **성능 리뷰어**: 리렌더링, N+1 쿼리, 메모리 누수, 인덱스
- **테스트 리뷰어**: 커버리지, 경계값, 테스트 품질, i18n

리드가 3명의 결과를 종합하여 최종 리뷰 보고서를 생성합니다.

## 리뷰 체크리스트

### 보안
- API 키/시크릿 노출 여부
- 입력 검증 (XSS, SQL injection)
- 인증/인가 로직

### 타입
- TypeScript strict 준수
- any 타입 사용 여부
- 타입 안전성

### 성능
- 불필요한 리렌더링
- N+1 쿼리
- 메모리 누수 가능성

### 데이터베이스
- RLS/Security Rules 영향
- 마이그레이션 필요 여부
- 인덱스 필요 여부

### 테스트
- 테스트 커버리지
- 경계값 테스트 유무
- 테스트 품질

### i18n
- 하드코딩 문자열 여부

## 심각도

| 레벨 | 설명 |
|------|------|
| **Critical** | 즉시 수정 필요 (보안 취약점, 데이터 손실 가능) |
| **Warning** | 수정 권장 (성능, 코드 품질) |
| **Info** | 개선 제안 (스타일, 컨벤션) |

## 출력 형식

```markdown
## Code Review: [target]

### Critical
- `file.ts:42` — [issue] → [fix]

### Warning
- `file.ts:15` — [issue] → [fix]

### Info
- `file.ts:8` — [suggestion]

### Summary
- Critical: N, Warning: N, Info: N
```

> 위 구조를 유지하되, 사용자 언어 설정에 맞춰 헤더와 내용을 작성하세요.

## 주의사항

- **읽기 전용**입니다. 코드를 수정하지 않습니다.
- 근거 없는 지적 금지. 파일:라인 번호를 명시하세요.
