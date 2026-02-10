---
name: rs-test
description: TDD 프로세스. 테스트 데이터 생성부터 E2E까지 자동화.
context: fork
agent: developer
argument-hint: "[test-target]"
---

# TDD 자동화

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 입력

`$ARGUMENTS`로 테스트 대상을 받습니다.

## TDD 순서 (Red-Green-Refactor)

### 1. RED — 테스트 작성

`$ARGUMENTS` 대상에 대한 테스트를 먼저 작성합니다.

**테스트 데이터 생성:**
- 경계값: 0, 빈 문자열, null, undefined, 최대/최소값
- 정상값: 일반적인 입력
- 에러 케이스: 잘못된 타입, 네트워크 실패, 권한 없음

**테스트 레벨:**
1. 단위 테스트 (vitest) — 함수/컴포넌트 단위
2. 통합 테스트 — API 엔드포인트, 서버 로직
3. E2E 테스트 (Playwright CLI) — 사용자 시나리오

### 2. RED 확인 — 실패 검증

```bash
npm run test:unit -- --run
```

작성한 테스트가 **반드시 실패**해야 합니다.
통과하면 테스트가 잘못된 것이니 수정하세요.

### 3. GREEN — 최소 구현

테스트를 통과시키기 위한 **최소한의** 코드만 작성합니다.
불필요한 기능 추가 금지.

```bash
npm run test:unit -- --run
```

모든 테스트가 통과해야 합니다.

### 4. REFACTOR — 리팩토링

코드 품질을 개선합니다. 테스트가 계속 통과하는지 확인합니다.

```bash
npm run test:unit -- --run
```

### 5. 반복

다음 기능/케이스에 대해 1-4를 반복합니다.

## E2E 테스트

Playwright CLI를 사용합니다:
```bash
npx playwright test [test-file]
```

## 결과 요약

```markdown
## TDD complete: [target]

### Tests written
- `tests/[file].test.ts` — N test cases
  - Boundary: N
  - Normal: N
  - Error: N

### Implementation
- `src/[file].ts` — [changes]

### Result
- Unit test: pass
- Type check: pass
```

> 위 구조를 유지하되, 사용자 언어 설정에 맞춰 헤더와 내용을 작성하세요.
