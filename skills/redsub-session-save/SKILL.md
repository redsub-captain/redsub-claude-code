---
name: redsub-session-save
description: Save session context for continuation in next session.
---

# Session Save

## Procedure

### 1. Update CLAUDE.md

Update "In progress" section:
```markdown
## In progress
- Branch: [current branch]
- Task: [current task]
- Next: [next steps]
- Last saved: [date/time]
```

### 2. WIP commit

If uncommitted changes exist:
```bash
git add -A
git commit -m "wip: session save"
```

### 3. Capture session learnings (REQUIRED)

This step is **REQUIRED** — do not skip.

Run `/revise-claude-md` to capture patterns, conventions, and gotchas discovered during this session into CLAUDE.md.

If the claude-md-management plugin is not installed, manually review the session and add any new learnings to CLAUDE.md under appropriate sections (e.g., commands, gotchas, conventions).

After completing this step, create a marker file:
```bash
touch /tmp/.claude-redsub-claude-md-revised
```

### 4. Confirm

```
Session saved:
- CLAUDE.md updated: [yes/no]
- WIP commit: [yes/no]
- Session learnings captured: [yes/no]
- Branch: [current branch]
```

## Next session
Read "In progress" section in CLAUDE.md to resume.
