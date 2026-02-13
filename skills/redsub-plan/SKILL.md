---
name: redsub-plan
description: Create bite-sized implementation plan with TDD structure. Each task 2-5 minutes.
---

# Implementation Planning

Announce: "Using /redsub-plan to create the implementation plan."

**Invoke superpowers:writing-plans skill first, then apply these additional conventions:**

## Input

`$ARGUMENTS`: feature name or design document path.

If a design doc exists (`docs/plans/*.md`), read it first.

## redsub Conventions

### Task Granularity

Each task = **2-5 minutes** of work. One focused action:
- One test + one function
- One component + its test
- One API endpoint + its test

If a task feels bigger, split it.

### TDD Structure in Every Task

Every task MUST follow this exact structure:

1. **Write failing test** — complete test code, not pseudo-code
2. **Verify failure** — exact command + expected failure output
3. **Implement** — complete implementation code, not "add the logic"
4. **Verify pass** — exact command + expected pass output
5. **Commit** — `type: description` (redsub commit convention)

### Plan Document Header

Override superpowers' default header with redsub's:

```markdown
# [Feature] Implementation Plan

> Execute with `/redsub-execute` task-by-task.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
```

### Zero Context Assumed

Another engineer (or subagent) should be able to execute this plan with zero codebase context:
- **Exact file paths** (not "add validation to the form")
- **Complete code** (not "implement the logic")
- **Exact commands** with expected output
- Reference existing files/patterns when relevant

### Principles

- **DRY**: No code duplication across tasks.
- **YAGNI**: Only what's needed now.
- **Frequent commits**: One commit per task, following redsub commit convention (`type: description`).

### Output

Save plan to: `docs/plans/YYYY-MM-DD-<feature>-plan.md`

Commit the plan document.

### Execution Handoff

Instead of superpowers' default handoff (worktrees, parallel sessions), use the redsub workflow:

"Ready to execute? Options:"
1. **This session** → `/redsub-execute` (subagent dispatch, recommended)
2. **Later** → Plan saved, execute whenever ready

Do NOT suggest git worktrees or superpowers:subagent-driven-development directly. The redsub workflow uses `/redsub-execute` as the next step.
