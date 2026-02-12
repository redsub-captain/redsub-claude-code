---
name: redsub-setup
description: Initial plugin setup. Deploy rules, create CLAUDE.md, check dependencies.
---

# Initial Setup

## Re-run prevention

If `~/.claude-redsub/.setup-done` exists and `--force` was NOT given in `$ARGUMENTS`, print "Already configured. Use --force to re-run." and stop.

## Procedure

### 1. Dependency plugins check

**Read the plugin registry from `${CLAUDE_PLUGIN_ROOT}/config/plugins.json`** — this is the Single Source of Truth (SSOT). Do NOT use a hardcoded list.

For each plugin in the registry, check if it's installed in `~/.claude/plugins/installed_plugins.json`.

Count installed vs total.

**If there are missing plugins:**

1. Check marketplaces from `config/plugins.json`. If any marketplace is not registered, register them automatically:
   ```bash
   claude plugin marketplace add <marketplace-name> <marketplace-url>
   ```

2. Show missing plugin count and ask user:
   - AskUserQuestion: "누락된 플러그인 [N]개를 자동 설치하시겠습니까?"
   - Options: "Install all (Recommended)" / "Skip for now"

3. **If user chooses install**: install each missing plugin automatically via Bash:
   ```bash
   claude plugin install <name>@<marketplace>
   ```
   Run installs sequentially (one at a time). Show progress as each plugin installs. If any single install fails, log the error and continue with the remaining plugins.

4. **If user chooses skip**: continue to the next step without blocking. Record the count for the summary.

### 2. Deploy rules

Copy the 4 rule files from the plugin to the Claude Code global rules directory.

```bash
mkdir -p ~/.claude/rules
cp ${CLAUDE_PLUGIN_ROOT}/rules/redsub-*.md ~/.claude/rules/
```

### 3. Configure permissions

Auto-register recommended permission patterns in `~/.claude/settings.json` to reduce repetitive "Allow" prompts during plugin usage.

**Read the permission registry from `${CLAUDE_PLUGIN_ROOT}/config/permissions.json`** — this is the Single Source of Truth (SSOT). Do NOT hardcode patterns.

Collect all `patterns` arrays from every category into a single flat list.

**Show the user what will be added** using `AskUserQuestion`:
- question: "플러그인 워크플로우에 필요한 권한 [N]개를 ~/.claude/settings.json에 등록하면, 이후 작업 시 반복적인 Allow 프롬프트가 줄어듭니다. 등록할까요?"
- header: "Permissions"
- options: ["Register all (Recommended)" (register all patterns), "Show details first" (list all patterns then ask again), "Skip" (do not modify permissions)]

**If user chooses "Show details first"**: print all patterns grouped by category (use category `description_ko`), then ask again with just "Register all" / "Skip".

**If user chooses "Register all"**:

1. Read `~/.claude/settings.json`. If file doesn't exist, start with `{}`.
2. Ensure `permissions.allow` array exists (create if missing).
3. Merge: add only patterns that are NOT already present in the existing `permissions.allow` array. Use exact string matching for deduplication.
4. Write the updated `settings.json` back.
5. Report: "권한 [N]개 등록 완료. (기존 중복 [M]개 스킵)"

**If user chooses "Skip"**: continue without modifying permissions. Note in the summary.

### 4. CLAUDE.md handling

Target path: `~/.claude/CLAUDE.md` (global — applies to all projects).

**If `~/.claude/CLAUDE.md` does NOT exist:** create from the plugin's template, wrapped with markers.
Read the template version from the first line of `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template` (format: `<!-- redsub-template-version:X.X.X -->`).
Write `~/.claude/CLAUDE.md` with markers wrapping the template content:
```
<!-- redsub-claude-code:start -->
(content of ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template, including the version comment)
<!-- redsub-claude-code:end -->
```

**If `~/.claude/CLAUDE.md` already EXISTS**, use `AskUserQuestion` tool:
- question: "~/.claude/CLAUDE.md가 이미 존재합니다. 워크플로우 가이드를 어떻게 추가할까요?"
- header: "CLAUDE.md"
- options: ["Append at end (Recommended)" (append with markers at end of file), "Prepend at start" (prepend with markers at start of file), "Skip" (do not modify existing file)]

For "Append" or "Prepend", Read the existing file first. If markers `<!-- redsub-claude-code:start -->` and `<!-- redsub-claude-code:end -->` already exist, **replace** the content between them with the new template. Otherwise, wrap the template content with markers and append/prepend:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

### 5. Install manifest

Target: `~/.claude-redsub/install-manifest.json`

```bash
mkdir -p ~/.claude-redsub
```

**If the file already exists**, Read it first then update `version`, `installed_at`, and merge arrays using path-based deduplication (add new entries only if no existing entry has the same path).

**If the file does NOT exist**, create it.

Read the plugin version from `${CLAUDE_PLUGIN_ROOT}/package.json` (SSOT). Do NOT hardcode the version.

Schema:
```json
{
  "version": "<from package.json>",
  "installed_at": "ISO-8601",
  "files_created": [],
  "files_modified": [],
  "rules_installed": [
    "~/.claude/rules/redsub-code-quality.md",
    "~/.claude/rules/redsub-workflow.md",
    "~/.claude/rules/redsub-testing.md",
    "~/.claude/rules/redsub-claude-code-practices.md"
  ]
}
```

Track any files created or modified during this setup run in the corresponding arrays.

### 6. Completion marker

```bash
mkdir -p ~/.claude-redsub
date > ~/.claude-redsub/.setup-done
```

### 7. Summary

```
Setup complete:
- Rules deployed: 4 (code-quality, workflow, testing, claude-code-practices)
- Permissions: [N registered / skipped] in ~/.claude/settings.json
- CLAUDE.md: [created at ~/.claude/CLAUDE.md / markers added / skipped]
- Dependencies: [N]/[total] installed
```

**If there are still missing plugins** (user skipped or some failed), append:

```
Missing plugins ([N]):
  claude plugin install <name>@<marketplace>
  ...
```

**Note**: Framework-specific plugins (SvelteKit, Firebase, Supabase, etc.) are installed per-project as needed, not globally.
