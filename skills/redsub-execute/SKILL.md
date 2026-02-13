---
name: redsub-execute
description: Execute implementation plan task-by-task with subagent dispatch and 2-stage review.
---

# Plan Execution

Announce: "Using /redsub-execute to implement the plan."

**Invoke superpowers:executing-plans skill first, then apply these additional conventions:**

## Input

`$ARGUMENTS`: path to plan document (e.g., `docs/plans/2025-01-15-auth-plan.md`).

## redsub Conventions

### Subagent Dispatch Model

Instead of superpowers' batch execution model, use subagent dispatch per task:

#### a. Dispatch Implementer (Task tool)

```
Prompt structure for implementer subagent:

Context: [Project description, current state]
Task: [Full task text from plan, verbatim]
Constraints:
- Follow TDD: write failing test first, verify failure, then implement
- Do NOT modify files outside this task's scope
- Commit when done: `type: Korean description` (redsub commit convention)
  - e.g., `feat: 사용자 인증 API 추가`, `fix: null 포인터 예외 처리`

Expected output:
- What was implemented
- Test results (actual output)
- Files created/modified
- Commit SHA
```

#### b. 2-Stage Review

After each implementer completes:

**Stage 1: Spec Compliance Review (Task tool)**
- Does implementation match plan spec exactly?
- Are all required files created/modified?
- Do tests cover the spec requirements?
- Any over-building or under-building?
- Output: PASS or FAIL with specific issues.
- FAIL → implementer fixes → re-review.

**Stage 2: Code Quality Review (Task tool)**
- Code clarity and readability
- Error handling and edge cases
- No security vulnerabilities
- Follows project conventions (CLAUDE.md)
- Output: APPROVED or issues list with severity.
- Issues found → implementer fixes → re-review.

### TodoWrite Integration

- Create TodoWrite with all tasks from the plan at start.
- Mark each task in_progress before dispatching implementer.
- Mark completed only after both review stages pass.
- Start next task immediately (no batch waiting).
- If blocked: stop and ask user.

### Red Flags

- Never skip spec review (ensures we build what was planned).
- Never start quality review before spec passes (wrong order).
- Never dispatch multiple implementers in parallel (file conflicts).
- Never proceed with unfixed review issues.
- Stop if 3+ fix attempts fail on same issue → question the plan.

### Post-Execution

After all tasks complete:

1. Run `/redsub-validate` (lint + check + test).
2. Show full diff: `git diff main...HEAD`
3. Report summary:
   ```
   Plan execution complete:
   - Tasks: N/N completed
   - Tests: [actual output]
   - Files changed: [count]
   ```
4. Recommend `/redsub-ship` for release.

Do NOT use superpowers:finishing-a-development-branch. The redsub workflow uses `/redsub-ship` for the release pipeline.
