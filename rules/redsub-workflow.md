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

## File Edit/Write Safety
- **Read before Edit/Write**: Claude Code requires a file to be Read before it can be edited or written to (Write for existing files).
- **New files only**: Only truly new files (that don't exist yet) can use Write without a prior Read.
- **Parallel Edit limit**: Parallel Edit/Write calls fail silently when too many are issued at once (typically 4+), even if all files were Read beforehand. This is a Claude Code platform constraint.
  - **Safe (2-3 files)**: Read A, Read B → Edit A, Edit B (parallel OK)
  - **Unsafe (4+ files)**: Read A..N → Edit A..N (parallel) → first Edit fails, all siblings cascade-fail
- **Bulk edits (4+ files)**: Use one of these strategies instead of parallel Edit:
  1. **Sequential pairs**: Read A → Edit A → Read B → Edit B → ... (safest)
  2. **Subagent delegation**: Use Task tool to delegate bulk edits to a subagent
  3. **Small batches**: Split into groups of 2-3 files, process each batch sequentially

## Token Optimization
- Prefer Glob/Grep for file discovery. Avoid bulk reads.
- Keep responses concise. No redundant code block repetition.
- Prefer CLI over MCP when equivalent (saves context).

## Natural Language → Command Mapping

When the user says these phrases, execute the corresponding process:

| User says | Action | Scope |
|-----------|--------|-------|
| "커밋해" / "commit" | `git add` + `git commit` on feature branch | Local only, no version bump |
| "릴리즈해" / "release" / "ship" | `/redsub-ship` (Save → Validate → Version → Merge → Tag → Push) | Local + Remote, version bump |
| "배포해" / "deploy" | `/redsub-deploy [env]` | Remote deployment |
| "저장해" / "save" | `/redsub-session-save` (CLAUDE.md update + WIP commit) | Local only |
| "검증해" / "validate" | `/redsub-validate` (lint + check + test) | Local only |
| "리뷰해" / "review" | `/review-pr` or `/code-review` | Local analysis |

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
