---
name: redsub-start-work
description: Create feature branch and start working.
---

# Branch Creation

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

## Input

`$ARGUMENTS` provides the branch name.

## Procedure

### 1. Sync latest main

```bash
git fetch origin && git pull origin main
```

Skip fetch/pull if no remote (local-only repo).

### 2. Create branch

```bash
git checkout -b feature/$ARGUMENTS
```

If `$ARGUMENTS` already contains `feature/`, `fix/`, or `chore/` prefix, use as-is.

### 3. Confirm

```
Branch feature/$ARGUMENTS created. Ready to work.
```
