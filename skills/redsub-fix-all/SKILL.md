---
name: redsub-fix-all
description: Search and bulk-fix a pattern across the entire codebase.
---

# Bulk Pattern Fix

> **Language**: Follow the user's Claude Code language setting.

## Input

`$ARGUMENTS`: pattern description + optional flags (`--team`, `--loop`).

## Modes

### Default (sequential)
Fix all cases one by one in a single session.

### Team mode (`--team`)
Uses superpowers:dispatching-parallel-agents.
> Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

1. Search all cases, partition files by teammate count.
2. Each teammate fixes assigned files in parallel.
3. **No file assigned to multiple teammates** (conflict prevention).
4. Lead runs `/redsub-validate` after completion.

### Loop mode (`--loop`)
```
/ralph-loop "Fix all [pattern]" --completion-promise "LINT CLEAN" --max-iterations 30
```

## Procedure (default)

### 1. Exhaustive search
Grep entire codebase for pattern.

### 2. Track cases
TodoWrite for all cases: file:line, current code, required fix.

### 3. Fix sequentially
Edit each case, mark complete in TodoWrite.

### 4. Validate
```bash
npm run lint && npm run check && npm run test:unit -- --run
```

### 5. Summary
```
Batch fix complete: [pattern]
- Found: M cases in N files
- Fixed: M cases
- Validation: pass/fail
```

## Important
- Complete exhaustive search BEFORE fixing. No gaps.
- Fix every case (MECE).
