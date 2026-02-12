---
name: redsub-update
description: Check plugin version updates and Claude Code compatibility.
---

# Plugin Auto-Update

## Procedure

### 1. Run update-core.sh

Execute the core update script that handles all internal operations (version check, git pull, cache creation, installed_plugins.json update) in a single call:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-core.sh" "${CLAUDE_PLUGIN_ROOT}"
```

Parse the JSON output. The result has this structure:
```json
{
  "status": "up_to_date | updated | error",
  "old_version": "X.X.X",
  "new_version": "X.X.X",
  "template_changed": true,
  "template_old": "X.X.X",
  "template_new": "X.X.X",
  "message": ""
}
```

### 2. Handle result

- If `status` = `"error"`: report the `message` and stop.
- If `status` = `"up_to_date"`: report "Up to date (vX.X.X)" and stop.
- If `status` = `"updated"`: proceed to step 3.

### 3. Template sync (if template_changed = true)

If `template_changed` is `false`, skip to step 4.

Use `AskUserQuestion`:
- question: "CLAUDE.md 템플릿이 업데이트됐습니다 (현재: [template_old or 'legacy'] → 최신: [template_new]). 갱신할까요?"
- header: "Template"
- options:
  - "Update (Recommended)" — 사용자 커스텀(Tech Stack, In progress)을 보존하면서 템플릿을 업데이트합니다
  - "Skip" — 현재 CLAUDE.md를 유지합니다

If user chooses "Update", run the merge script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/merge-template.sh" "${CLAUDE_PLUGIN_ROOT}" merge
```

Parse the JSON output and report the result.

### 4. Report result

```
Updated: vOLD → vNEW
Restart the session to apply changes.
```
