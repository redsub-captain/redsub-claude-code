---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "tests/**"
  - "e2e/**"
  - "src/**/*.ts"
---

# Testing Rules

## TDD Required (superpowers:test-driven-development)
- **Iron Law: No production code without a failing test first.**
- New feature: write test → verify failure → implement → verify pass.
- Existing code changes: check related tests first. Add tests if missing.
- No committing production code without tests.

## Test Data
- Boundary values (0, empty string, null, max).
- Normal values (typical inputs).
- Error cases (wrong types, network failures, unauthorized).

## Unit Tests (vitest)
- Isolated per function/component.
- Mock external dependencies.
- Location: alongside source (`*.test.ts`) or `tests/` directory.

## E2E Tests (Playwright)
- Cover critical user scenarios.
- Location: `e2e/` directory.
- Headless mode for CI compatibility.

## Coverage
- No coverage regression. New code must maintain or exceed current level.
- Coverage report: `npm run test:coverage`.

## Verification (superpowers:verification-before-completion)
- Always show actual test output as evidence before claiming tests pass.
- Never claim "all tests passing" without command output proof.
