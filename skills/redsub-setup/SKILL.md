---
name: redsub-setup
description: Initial plugin setup. Deploy rules, create CLAUDE.md, check dependencies.
---

# Initial Setup

## Re-run prevention

If `~/.claude-redsub/.setup-done` exists and `--force` was NOT given in `$ARGUMENTS`, print "Already configured. Use --force to re-run." and stop.

## Procedure

### 1. Run setup-core.sh

Execute the core setup script that handles dependency check (SSOT: `config/plugins.json`), rule deployment, permission check (`config/permissions.json`), manifest creation, and completion marker in a single call:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-core.sh" "${CLAUDE_PLUGIN_ROOT}" [--force if given]
```

Parse the JSON output. The result has this structure:
```json
{
  "status": "completed | already_configured",
  "dependencies": {"total": 12, "installed": 12, "missing": []},
  "rules_deployed": 5,
  "permissions": {"total": 16, "registered": 16, "missing": []},
  "manifest_updated": true,
  "version": "X.X.X",
  "claude_md": {"status": "missing | no_markers | has_markers", "template_version": "X.X.X", "template_latest": "X.X.X"}
}
```

If `status` = `"already_configured"`: print the message and stop.

### 2. Install missing plugins (if any)

If `dependencies.missing` is not empty:

Use `AskUserQuestion`:
- question: "누락된 플러그인 [N]개를 자동 설치하시겠습니까?"
- header: "Plugins"
- options: ["Install all (Recommended)", "Skip for now"]

If user chooses install: run each missing plugin install sequentially via Bash:
```bash
claude plugin install <name>@<marketplace>
```
Show progress as each plugin installs. If any single install fails, log the error and continue.

If user chooses skip: continue to the next step.

### 3. Register missing permissions (if any)

If `permissions.missing` is not empty:

Use `AskUserQuestion`:
- question: "플러그인 워크플로우에 필요한 권한 [N]개를 ~/.claude/settings.json에 등록하면, 이후 작업 시 반복적인 Allow 프롬프트가 줄어듭니다. 등록할까요?"
- header: "Permissions"
- options: ["Register all (Recommended)" (register all patterns), "Show details first" (list all patterns then ask again), "Skip" (do not modify permissions)]

If user chooses "Show details first": print all missing patterns, then re-ask with just "Register all" / "Skip".

If user chooses "Register all":
1. Read `~/.claude/settings.json`. If file doesn't exist, start with `{}`.
2. Ensure `permissions.allow` array exists (create if missing).
3. Add only the missing patterns from `permissions.missing` array.
4. Write the updated `settings.json` back using Edit tool (if file was Read) or Write tool (if new).
5. Report: "권한 [N]개 등록 완료."

### 4. CLAUDE.md handling

Based on `claude_md.status` from the JSON result:

**If `"missing"`**: Create `~/.claude/CLAUDE.md` from template.
1. Read `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template`.
2. Write `~/.claude/CLAUDE.md` with markers wrapping the template:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

**If `"no_markers"`**: Existing file without plugin markers.
Use `AskUserQuestion`:
- question: "~/.claude/CLAUDE.md가 이미 존재합니다. 워크플로우 가이드를 어떻게 추가할까요?"
- header: "CLAUDE.md"
- options: ["Append at end (Recommended)", "Prepend at start", "Skip"]

If not "Skip": Read the existing file, then append/prepend the template wrapped with markers.

**If `"has_markers"`**: Existing file with markers.
- If `template_version` = `template_latest`: report "CLAUDE.md 이미 최신 (vX.X.X)" and skip.
- If versions differ: Use `AskUserQuestion`:
  - question: "CLAUDE.md 템플릿을 업데이트할까요? (현재: [template_version or 'legacy'] → 최신: [template_latest]). 사용자 커스텀(Tech Stack, In progress)은 보존됩니다."
  - header: "CLAUDE.md"
  - options: ["Update (Recommended)", "Skip"]
  - If "Update": apply **CLAUDE.md Smart Merge** (see below).

### 5. Summary

```
Setup complete:
- Rules deployed: [rules_deployed] (code-quality, workflow, testing, claude-code-practices, commit-convention)
- Permissions: [registered/total] in ~/.claude/settings.json
- CLAUDE.md: [created / updated / skipped]
- Dependencies: [installed]/[total] installed
- Install manifest: updated
```

If there are still missing plugins (user skipped or some failed), append:
```
Missing plugins ([N]):
  claude plugin install <name>@<marketplace>
  ...
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
3. Combine any found sections into USER_CONFIG (join with blank line). If only one section found, use just that one.
4. If USER_CONFIG is non-empty: in the new template's sub-markers, replace the default content between them with USER_CONFIG.
5. If no sections found: keep the template defaults.

### Case C: No main markers (first install — same as "missing" case above)

Write the template wrapped with main markers:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

Use the **Edit** tool (not Write) when the file was already Read.
