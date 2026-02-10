---
name: review
description: 보안, 타입, 성능, DB, 테스트 관점에서 코드 리뷰.
context: fork
agent: reviewer
argument-hint: "[target-path]"
---

# 코드 리뷰

## 입력

`$ARGUMENTS`로 리뷰 대상 경로를 받습니다. 생략 시 최근 변경 파일을 대상으로 합니다.

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
## 코드 리뷰: [대상]

### Critical
- `file.ts:42` — [문제 설명] → [수정 방안]

### Warning
- `file.ts:15` — [문제 설명] → [수정 방안]

### Info
- `file.ts:8` — [제안]

### 요약
- Critical: N건, Warning: N건, Info: N건
```

## 주의사항

- **읽기 전용**입니다. 코드를 수정하지 않습니다.
- 근거 없는 지적 금지. 파일:라인 번호를 명시하세요.
