---
name: redsub-plan
description: Create bite-sized implementation plan with TDD structure. Each task 2-5 minutes.
---

# Implementation Planning

Announce: "Using /redsub-plan to create the implementation plan."

## Input

`$ARGUMENTS`: feature name or design document path.

If a design doc exists (`docs/plans/*.md`), read it first.

## Plan Document Structure

```markdown
# [Feature] Implementation Plan

> Execute with `/redsub-execute` task-by-task.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]

## Task 1: [Component Name]
**Files:** [exact paths to create/modify]
### Step 1: Write failing test
[Complete test code]
### Step 2: Verify failure
[Exact command + expected output]
### Step 3: Implement
[Complete implementation code]
### Step 4: Verify pass
[Exact command + expected output]
### Step 5: Commit
`git add <files> && git commit -m "feat: <description>"`
```

## Task Granularity

Each task = **2-5 minutes** of work. One focused action:
- One test + one function
- One component + its test
- One API endpoint + its test

If a task feels bigger → split it.

## Requirements

Every task MUST include:
- **Exact file paths** (not "add validation to the form")
- **Complete code** (not "implement the logic")
- **Exact commands** with expected output
- **TDD structure**: failing test → verify → implement → verify → commit

## Principles

- **DRY**: No code duplication across tasks.
- **YAGNI**: Only what's needed now.
- **TDD**: Every task starts with a failing test.
- **Frequent commits**: One commit per task.
- **Zero context assumed**: Another engineer should be able to execute this plan.

## Output

Save plan to: `docs/plans/YYYY-MM-DD-<feature>-plan.md`

Commit the plan document.

## Execution Handoff

After plan is written, ask:

"Ready to execute? Options:"
1. **This session** → `/redsub-execute` (subagent dispatch, recommended)
2. **Later** → Plan saved, execute whenever ready
