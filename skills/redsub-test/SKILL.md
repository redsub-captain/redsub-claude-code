---
name: redsub-test
description: TDD automation with Red-Green-Refactor cycle.
---

# TDD Automation

> **Language**: Follow the user's Claude Code language setting.

## Input

`$ARGUMENTS` provides the test target. `--loop` flag enables ralph-loop integration.

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
