---
paths:
  - "src/**/*.ts"
  - "src/**/*.svelte"
  - "src/**/*.js"
---

# 코드 품질 규칙

## TypeScript
- strict 모드 필수. `any` 타입 사용 금지.
- 타입 추론이 충분한 경우 명시적 타입 생략 가능.

## SvelteKit 5
- Runes API 사용: `$state`, `$derived`, `$effect`, `$props`.
- 레거시 반응성 API (`$:`, `export let`) 사용 금지.
- 서버 전용 로직은 `+server.ts` 또는 `src/lib/server/`에만 작성.
- `+page.ts`의 `load` 함수에서 서버 데이터는 `+page.server.ts`로 분리.

## 환경변수
- 새 환경변수 추가 시 반드시 동시 갱신:
  1. `.env` (로컬)
  2. `apphosting.yaml` (배포)
  3. 관련 문서

## 문자열
- 하드코딩 문자열 금지. i18n 키 또는 상수로 관리.
- 에러 메시지, UI 텍스트 모두 포함.

## 스타일
- Tailwind CSS 4 유틸리티 우선. 커스텀 CSS 최소화.
- 컴포넌트 props에 `class` 전달 시 `clsx` 또는 `cn` 사용.
