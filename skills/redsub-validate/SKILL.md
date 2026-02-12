---
name: redsub-validate
description: Run lint, type check, and unit tests with evidence.
---

# Code Validation

## Command Resolution

Determine the project's validation commands:
1. Check project CLAUDE.md for explicit commands (lint, check, test)
2. If not found, read `package.json` scripts and infer:
   - Lint: script containing "lint" (e.g., `lint`, `lint:fix`)
   - Type check: script containing "check" (e.g., `check`, `typecheck`)
   - Unit test: script containing "test" (e.g., `test`, `test:unit`)
3. Detect package manager: look for lock files (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, default → npm)
4. If ambiguous, ask the user

## Procedure

Run sequentially. Stop on first failure.

### 1. Lint
```bash
<package-manager> run <lint-script>
```

### 2. Type check
```bash
<package-manager> run <check-script>
```

### 3. Unit tests
```bash
<package-manager> run <test-script>
```

If the test script doesn't include a `--run` flag for watch-mode frameworks (e.g., vitest), append `-- --run`.

### 4. Evidence (superpowers:verification-before-completion)

**Show actual command output.** No claims without evidence.

**On success:**
```
Validation passed (with evidence):
- lint: pass (0 errors, 0 warnings)
- type check: pass (0 errors)
- unit test: pass (N tests, 0 failures)
```

Marker file auto-created by PostToolUse hook (`/tmp/.claude-redsub-validated`).
Referenced by `/redsub-ship` before merge.

**On failure:**
```
Validation failed:
- [step]: [error details]
- Fix: [suggestion]
```
