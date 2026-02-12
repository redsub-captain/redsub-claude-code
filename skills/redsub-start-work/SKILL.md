---
name: redsub-start-work
description: Create feature branch and start working.
---

# Branch Creation

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

## Optional: Worktree Isolation (`--worktree`)

If `$ARGUMENTS` contains `--worktree`:

### 1. Detect worktree directory

Check in priority order:
1. `.worktrees/` exists → use it
2. `worktrees/` exists → use it
3. CLAUDE.md mentions worktree directory → use it
4. Ask user: `.worktrees/` (project-local, hidden) or skip

### 2. Safety verification (project-local only)

```bash
git check-ignore -q .worktrees 2>/dev/null
```

If NOT ignored: add `.worktrees/` to `.gitignore` and commit.

### 3. Create worktree

```bash
git worktree add <worktree-dir>/$BRANCH_NAME -b $BRANCH_NAME
cd <worktree-dir>/$BRANCH_NAME
```

### 4. Project setup

Auto-detect from project files:
- `package.json` → `npm install` (or pnpm/yarn from lock file)
- `Cargo.toml` → `cargo build`
- `requirements.txt` → `pip install -r requirements.txt`
- `go.mod` → `go mod download`

### 5. Verify clean baseline

Run project tests. Report ready or report failures + ask whether to proceed.
