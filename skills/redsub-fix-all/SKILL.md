---
name: redsub-fix-all
description: Search and bulk-fix a pattern across the entire codebase.
---

# Bulk Pattern Fix

## Bug Propagation Protocol

버그/오류 발견 시 **동일/유사 패턴 전수 조사**. 한 건 수정으로 끝내지 않는다.
- Grep으로 유사 패턴 검색 → 전체 수정 → 검증
- "하나 고치고 끝"은 버그. 전수 조사 후 리포트
- 동일 코드베이스에서 작동하는 유사 사례 찾기, 차이점 비교

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
