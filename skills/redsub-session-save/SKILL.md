---
name: redsub-session-save
description: Save session context for continuation in next session.
---

# Session Save

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

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

### 3. Confirm
```
Session saved:
- CLAUDE.md updated: [yes/no]
- WIP commit: [yes/no]
- Branch: [current branch]
```

## Next session
Read "In progress" section in CLAUDE.md to resume.
