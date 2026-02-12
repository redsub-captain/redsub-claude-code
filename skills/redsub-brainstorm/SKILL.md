---
name: redsub-brainstorm
description: Collaborative design through Socratic dialogue. Turn rough ideas into validated designs.
---

# Design Brainstorming

Announce: "Using /redsub-brainstorm to explore the design."

## Process

### 1. Understand the Idea

- Check current project state (CLAUDE.md, package.json, existing code).
- Ask clarifying questions **one at a time** (never multiple questions in one message).
- Prefer multiple-choice (AskUserQuestion) over open-ended questions.
- Understand: purpose, constraints, success criteria, target users.

### 2. Explore Approaches

- Present **2-3 approaches** with trade-offs.
- Recommend a lead option with rationale.
- Apply YAGNI ruthlessly — cut anything not essential.
- Consider: complexity, performance, maintainability, cost.

### 3. Present the Design

- Break into small sections (**200-300 words** each).
- After each section, ask for validation before continuing.
- Cover: architecture, components, data flow, error handling, testing strategy.
- Use diagrams (ASCII/mermaid) when helpful.

### 4. Document

Save validated design:

```bash
mkdir -p docs/plans
# File: docs/plans/YYYY-MM-DD-<topic>-design.md
```

Structure:
```markdown
# [Feature] Design
## Goal
## Approach
## Components
## Data Flow
## Error Handling
## Testing Strategy
## Open Questions
```

Commit the design document.

### 5. Implementation Handoff

Ask: "Ready for implementation planning?"
- Yes → suggest `/redsub-plan`
- Not yet → continue refining

## Principles

- **One question at a time** — don't overwhelm.
- **Multiple choice preferred** — reduce decision fatigue.
- **YAGNI** — cut everything non-essential.
- **Explore alternatives** — never jump to the first idea.
- **Incremental validation** — validate each section before moving on.
- **Be flexible** — adapt when user steers differently.
