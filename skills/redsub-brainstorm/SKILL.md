---
name: redsub-brainstorm
description: Collaborative design through Socratic dialogue. Turn rough ideas into validated designs.
---

# Design Brainstorming

Announce: "Using /redsub-brainstorm to explore the design."

**Invoke superpowers:brainstorming skill first, then apply these additional conventions:**

## redsub Conventions

### Interaction Style

- **Socratic dialogue**: One question at a time, never multiple questions in one message.
- **AskUserQuestion preferred**: Use multiple-choice (AskUserQuestion tool) over open-ended questions whenever possible. Reduce decision fatigue.

### YAGNI Enforcement

- Apply YAGNI ruthlessly at every decision point.
- Consider: complexity, performance, maintainability, **cloud cost**.
- When user proposes something non-essential, push back with rationale before accepting.

### Design Document Output

Save validated design to:

```bash
mkdir -p docs/plans
# File: docs/plans/YYYY-MM-DD-<topic>-design.md
```

Document structure:
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

### Implementation Handoff

Instead of superpowers' default handoff, use the redsub workflow:

Ask: "Ready for implementation planning?"
- Yes → suggest `/redsub-plan`
- Not yet → continue refining

Do NOT suggest git worktrees or superpowers:writing-plans directly. The redsub workflow uses `/redsub-plan` as the next step.
