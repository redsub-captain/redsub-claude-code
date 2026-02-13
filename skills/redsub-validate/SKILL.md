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

### 4. SSOT Consistency Checks

When a canonical source exists (config, constants, types), verify consumers stay in sync:
- Config-driven values: verify runtime reads match the canonical source (e.g., routes file exports match router config)
- Shared types: verify API response shapes match the declared type (snapshot or schema validation)
- i18n: verify all keys used in components exist in translation files
- If a test duplicates a magic number or string, extract to shared fixture or import from source module

### 5. Evidence (5-Step Verification Gate)

**No claims without evidence.** Follow this exact sequence:

1. **IDENTIFY**: What command proves this claim?
2. **RUN**: Execute the full command (fresh, complete)
3. **READ**: Check entire output, exit code, failure count
4. **VERIFY**: Does the output support the claim?
5. **CLAIM**: Only then make the claim

Forbidden before verification: "should", "probably", "seems to", or satisfaction expressions ("Great!", "Done!", "Perfect!").

**On success:**
```
Validation passed (with evidence):
- lint: pass (0 errors, 0 warnings)
- type check: pass (0 errors)
- unit test: pass (N tests, 0 failures)
```

**On failure:**
```
Validation failed:
- [step]: [error details]
- Fix: [suggestion]
```
