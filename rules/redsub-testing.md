# Testing Rules

## TDD Required
- **Iron Law: No production code without a failing test first.**
- New feature: write test → verify failure → implement → verify pass.
- Existing code changes: check related tests first. Add tests if missing.
- No committing production code without tests.

### Red-Green-Refactor Cycle

**RED** — Write ONE failing test:
- Test must fail for the **right reason** (feature missing, NOT syntax error).
- If test passes immediately → you're testing existing behavior. Fix the test.
- If test errors (import, syntax) → fix the error, re-run until it fails correctly.

**GREEN** — Write minimal code to pass:
- Just enough to make the test pass. Nothing more.
- Do NOT add features, refactor, or "improve" beyond the test.
- Run test: verify it passes AND other tests still pass.

**REFACTOR** — Clean up (only after green):
- Remove duplication, improve names, extract helpers.
- Keep all tests green. Do NOT add behavior.

### Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Keep code as reference" | Delete it. Start with test. "Reference" = testing after. |
| "Need to explore first" | Fine. Throw away exploration, then TDD. |
| "TDD will slow me down" | TDD is faster than debugging. |

### Red Flags (STOP and correct)
- Writing code before test.
- Test passes immediately (testing existing behavior).
- Rationalizing "just this once".
- Multiple changes before running tests.

## Test Data
- Boundary values (0, empty string, null, max).
- Normal values (typical inputs).
- Error cases (wrong types, network failures, unauthorized).

## Unit Tests
- Isolated per function/component.
- Mock external dependencies.
- Location: alongside source (`*.test.ts`) or `tests/` directory.
- Use the project's configured test runner (detected via Command Resolution).

## E2E Tests
- Cover critical user scenarios (login, purchase, data CRUD).
- Location: `e2e/` directory.
- TDD: Write failing E2E first → implement → verify pass.
- Focus: critical user flows only. Unit/integration tests cover the rest.
- Playwright MCP tools available for browser automation, screenshots, form input.

## Coverage
- No coverage regression. New code must maintain or exceed current level.

## SSOT Consistency Tests
- **When a canonical source exists (config, constants, types), write a test that verifies consumers stay in sync.**
- Config-driven values: test that runtime reads match the canonical source (e.g., routes file exports match router config).
- Shared types: test that API response shapes match the declared type (snapshot or schema validation).
- i18n: test that all keys used in components exist in translation files.
- If a test duplicates a magic number or string, extract it to a shared fixture or import from the source module.
- **No copy-paste test data**: Test fixtures should derive from or reference the same source as production code.

## Verification (Evidence Gate)
- Always show actual test output as evidence before claiming tests pass.
- Never claim "all tests passing" without command output proof.
