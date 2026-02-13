---
name: redsub-fix-all
description: Search and bulk-fix a pattern across the entire codebase.
---

# Bulk Pattern Fix

## Bug Propagation Protocol

On any bug/error, **exhaustively search for identical/similar patterns**. Never fix just one.
- Grep for similar patterns → fix all → verify
- "Fix one and done" is a bug. Exhaustive search then report
- Find similar cases in the same codebase, compare differences

## Input

`$ARGUMENTS`: pattern description + optional flags (`--team`, `--loop`).

## Modes

### Explicit flags (skip AskUserQuestion)

- `--team` in `$ARGUMENTS` → directly use Team mode.
- `--loop` in `$ARGUMENTS` → directly use Loop mode.

### No flag: check Agent Teams availability

If neither `--team` nor `--loop` was passed, check the environment:

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:+enabled}"
```

**If enabled** → use `AskUserQuestion` tool:
- question: "Select execution mode."
- header: "Mode"
- options: ["Sequential (Recommended)" (safe, predictable), "Agent Teams" (parallel teammates — faster but uses more tokens), "Loop" (ralph-loop iteration — suited for lint-style fixes)]

**If not enabled** → use Sequential mode without asking.

### Sequential mode (default)
Fix all cases one by one in a single session.

### Team mode (`--team` or user choice)
Uses parallel agent dispatch (redsub-claude-code-practices rule).
> Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

1. Search all cases, partition files by teammate count.
2. Each teammate fixes assigned files in parallel.
3. **No file assigned to multiple teammates** (conflict prevention).
4. Lead runs `/redsub-validate` after completion.

### Loop mode (`--loop` or user choice)
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

Run `/redsub-validate` (uses Command Resolution to detect project commands).

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
