---
name: redsub-execute
description: Execute implementation plan task-by-task with subagent dispatch and 2-stage review.
---

# Plan Execution

Announce: "Using /redsub-execute to implement the plan."

## Input

`$ARGUMENTS`: path to plan document (e.g., `docs/plans/2025-01-15-auth-plan.md`).

## Process

### 1. Load and Review Plan

1. Read the plan file.
2. Review critically — identify concerns, missing context, unclear steps.
3. If concerns: raise with user **before** starting.
4. Create TodoWrite with all tasks from the plan.

### 2. Execute Tasks

For each task:

#### a. Dispatch Implementer (Task tool)

```
Prompt structure for implementer subagent:

Context: [Project description, current state]
Task: [Full task text from plan, verbatim]
Constraints:
- Follow TDD: write failing test first, verify failure, then implement
- Do NOT modify files outside this task's scope
- Commit when done: `type: 한국어 설명` (커밋 컨벤션 따름)
  - 예: `feat: 사용자 인증 API 추가`, `fix: null 포인터 예외 처리`

Expected output:
- What was implemented
- Test results (actual output)
- Files created/modified
- Commit SHA
```

#### b. Spec Compliance Review (Task tool)

```
Prompt structure for spec reviewer subagent:

Plan task (original spec):
[Full task text from plan]

Implementation (what was done):
[Implementer's output summary]

Check:
1. Does implementation match spec exactly?
2. Are all required files created/modified?
3. Do tests cover the spec requirements?
4. Any over-building or under-building?

Output: PASS or FAIL with specific issues.
```

- FAIL → implementer fixes → re-review
- PASS → proceed to code quality review

#### c. Code Quality Review (Task tool)

```
Prompt structure for code quality reviewer subagent:

Review the implementation between commits [base_sha] and [head_sha].

Check:
1. Code clarity and readability
2. Error handling
3. Edge cases covered
4. No security vulnerabilities
5. Follows project conventions (CLAUDE.md)

Output: APPROVED or issues list with severity.
```

- Issues found → implementer fixes → re-review
- APPROVED → mark task complete in TodoWrite

### 3. Between Tasks

- Mark completed task in TodoWrite.
- Start next task immediately (no batch waiting needed).
- If blocked: stop and ask user.

### 4. After All Tasks

1. Run `/redsub-validate` (lint + check + test).
2. Show full diff: `git diff main...HEAD`
3. Report summary:
   ```
   Plan execution complete:
   - Tasks: N/N completed
   - Tests: [actual output]
   - Files changed: [count]
   ```
4. Suggest `/redsub-ship` for release.

## Red Flags

- Never skip spec review (ensures we build what was planned).
- Never start quality review before spec passes (wrong order).
- Never dispatch multiple implementers in parallel (file conflicts).
- Never proceed with unfixed review issues.
- Stop if 3+ fix attempts fail on same issue → question the plan.

## When to Stop

- Blocker: missing dependency, unclear instruction, environment issue.
- Plan has critical gaps.
- Repeated failures on same task (3+).
- Always ask user before abandoning a task.
