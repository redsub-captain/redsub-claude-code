---
name: redsub-test
description: TDD automation with Red-Green-Refactor cycle.
---

# TDD Automation

## Input

`$ARGUMENTS` provides the test target. Optional flags: `--loop` (ralph-loop), `--team` (Agent Teams).

## Parallel Mode (Agent Teams)

### Explicit flag
`--team` in `$ARGUMENTS` → directly use Agent Teams mode.

### Auto-detection
If `--team` was NOT passed, check whether parallelization is beneficial:

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:+enabled}"
```

**If enabled AND scope covers 3+ distinct modules/files** → use `AskUserQuestion` tool:
- question: "여러 모듈이 감지되었습니다. 실행 모드를 선택하세요."
- header: "Test Mode"
- options: ["Sequential (Recommended)" (모듈별 순차 TDD — 안전, 토큰 절약), "Agent Teams" (모듈별 병렬 TDD — 빠르지만 토큰 더 소비)]

**If not enabled OR single target** → Sequential mode without asking.

### Team mode procedure
Uses superpowers:dispatching-parallel-agents.
> Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

1. Analyze target scope, identify distinct modules/test areas.
2. Partition: each teammate gets one module. **No overlapping files.**
3. Each teammate runs independent Red-Green-Refactor cycle.
4. Lead collects results and runs final validation:
   ```bash
   npm run test:unit -- --run
   ```

## Iron Law (superpowers:test-driven-development)

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

## Red-Green-Refactor Cycle

### 1. RED — Write failing test

Write one minimal failing test for `$ARGUMENTS`.

**Test data:**
- Boundary: 0, empty string, null, undefined, min/max
- Normal: typical inputs
- Error: wrong types, network failures, unauthorized

**Test levels:**
1. Unit test (vitest) — functions/components
2. Integration test — API endpoints, server logic
3. E2E test (Playwright CLI) — user scenarios

### 2. Verify RED

```bash
npm run test:unit -- --run
```

Test **MUST fail**. If it passes, the test is wrong.

### 3. GREEN — Minimal implementation

Write **minimum** code to pass. No extras.

```bash
npm run test:unit -- --run
```

### 4. REFACTOR

Improve quality. Verify tests still pass:
```bash
npm run test:unit -- --run
```

### 5. Repeat for next case.

## Verification (superpowers:verification-before-completion)

Show actual test output as evidence before claiming completion.

## Ralph-loop integration

If `--loop` in `$ARGUMENTS`:
```
/ralph-loop "TDD: [target]. Write failing test, implement, verify." --completion-promise "ALL TESTS PASSING" --max-iterations 20
```

## Summary

```
TDD complete: [target]

Tests: tests/[file].test.ts — N cases (Boundary: N | Normal: N | Error: N)
Implementation: src/[file].ts
Result: Unit test pass (evidence: [output]) | Type check pass
```
