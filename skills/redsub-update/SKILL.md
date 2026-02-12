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

If user chooses "Update": apply **CLAUDE.md Smart Merge** (see below).

### 4. Report result

```
Updated: vOLD → vNEW
Restart the session to apply changes.
```

---

## CLAUDE.md Smart Merge

Read `~/.claude/CLAUDE.md` and the new template from `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template`.

When replacing content between main markers (`<!-- redsub-claude-code:start -->` / `<!-- redsub-claude-code:end -->`):

### Case A: Sub-markers exist (`<!-- redsub-user:start -->` / `<!-- redsub-user:end -->`)

1. Extract content between `<!-- redsub-user:start -->` and `<!-- redsub-user:end -->` → save as USER_CONFIG.
2. Replace everything between main markers with new template content.
3. In the replaced content, find the sub-markers and replace the default content between them with USER_CONFIG.

### Case B: No sub-markers (legacy migration)

1. In the current content between main markers, look for these sections:
   - `## Tech Stack` → extract heading + all lines until next `##` heading
   - `## In progress` → extract heading + all lines until next `##` heading or end of markers
2. Replace everything between main markers with new template content.
3. If sections were found: in the new template's sub-markers, replace the default content with the extracted sections.
4. If no sections found: keep the template defaults.

### Case C: No main markers (first install)

Write the template wrapped with main markers:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

Use the **Edit** tool (not Write) since the file was already Read.
