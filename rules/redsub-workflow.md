# Workflow Rules

## Branching
- No direct commits to main/master.
- Use branch prefixes: `feature/`, `fix/`, `chore/`.
- Create branches with `/redsub-start-work`.

## Commits
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`.
- WIP commits via `/redsub-session-save`. Final commits with meaningful messages.

## Versioning (Semantic Versioning)
- `patch` (1.0.x): Bug fixes, minor changes.
- `minor` (1.x.0): New features (backward compatible).
- `major` (x.0.0): Breaking changes.
- Version is handled by `/redsub-ship`. Never modify package.json version manually.
- Always bump version when merging to main.

## Merge / Push / Deploy
- No push, merge, or deploy without explicit user instruction.
- `/redsub-validate` must pass before merge.
- `/redsub-ship` enforces: Save → Validate → Review → Version → Merge → Tag → Push.

## Planning
- New features or large changes: use `/brainstorming` → `/writing-plans` (superpowers) before coding.
- No large-scale modifications without a plan.

## Token Optimization
- Prefer Glob/Grep for file discovery. Avoid bulk reads.
- Keep responses concise. No redundant code block repetition.
- Prefer CLI over MCP when equivalent (saves context).

## Context-Aware Command Mapping

When you detect these situations, suggest the appropriate commands:

| Context | Suggested Commands |
|---------|-------------------|
| Session start, no branch | `/redsub-start-work [name]` |
| New feature discussion | `/brainstorming` → `/writing-plans` |
| Writing code | superpowers:test-driven-development principles |
| Tests failing | `/redsub-test [target]` or `/ralph-loop` for iteration |
| Code complete, ready to merge | `/redsub-ship [version]` |
| Before merge, need review | `/review-pr` or `/code-review` |
| Deploy needed | `/redsub-deploy [env]` |
| Bulk fixes needed | `/redsub-fix-all [pattern]` |
| Session ending | `/redsub-session-save` |
| Plugin issues | `/redsub-doctor` |
| UI/UX design needed | `/redsub-design [screen]` |
