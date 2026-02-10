---
name: redsub-validate
description: Run lint, type check, and unit tests with evidence.
---

# Code Validation

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

## Procedure

Run sequentially. Stop on first failure.

### 1. Lint
```bash
npm run lint
```

### 2. Type check
```bash
npm run check
```

### 3. Unit tests
```bash
npm run test:unit -- --run
```

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
