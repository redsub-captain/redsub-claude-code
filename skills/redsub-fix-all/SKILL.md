---
name: redsub-fix-all
description: Search and bulk-fix a pattern across the entire codebase.
---

# Bulk Pattern Fix

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
- question: "실행 모드를 선택하세요."
- header: "Mode"
- options: ["Sequential (Recommended)" (순차 수정 — 안전, 예측 가능), "Agent Teams" (병렬 teammate — 빠르지만 토큰 더 소비), "Loop" (ralph-loop 반복 — lint 스타일 수정에 적합)]

**If not enabled** → use Sequential mode without asking.

### Sequential mode (default)
Fix all cases one by one in a single session.

### Team mode (`--team` or user choice)
Uses superpowers:dispatching-parallel-agents.
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
