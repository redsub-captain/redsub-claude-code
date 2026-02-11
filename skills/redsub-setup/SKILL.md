---
name: redsub-setup
description: Initial plugin setup. Deploy rules, create CLAUDE.md, check dependencies.
---

# Initial Setup

> **Language**: Follow the user's Claude Code language setting.

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

Copy the 3 rule files from the plugin to the Claude Code global rules directory.

```bash
mkdir -p ~/.claude/rules
cp ${CLAUDE_PLUGIN_ROOT}/rules/redsub-*.md ~/.claude/rules/
```

### 3. CLAUDE.md handling

Target path: `~/.claude/CLAUDE.md` (global — applies to all projects).

**If `~/.claude/CLAUDE.md` does NOT exist:** create from the plugin's template.
```bash
cp ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template ~/.claude/CLAUDE.md
```

**If `~/.claude/CLAUDE.md` already EXISTS**, ask user how to integrate:
```
~/.claude/CLAUDE.md already exists. How should we add the workflow guide?
(a) Append at end (with markers)
(b) Prepend at start (with markers)
(c) Skip
```

For (a) or (b), Read the existing file first. If markers `<!-- redsub-claude-code:start -->` and `<!-- redsub-claude-code:end -->` already exist, **replace** the content between them with the new template. Otherwise, wrap the template content with markers and append/prepend:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

### 4. Stitch API key (optional)

The `/redsub-design` skill uses [Google Stitch](https://stitch.withgoogle.com) for UI/UX screen design. An API key is required only if the user plans to use this feature.

Check if `STITCH_API_KEY` environment variable is set:

```bash
echo "${STITCH_API_KEY:+configured}"
```

**If not set**, ask user:
```
Stitch API key is not configured.
The /redsub-design skill requires this key for UI/UX screen design.
(If you don't need UI design, the frontend-design plugin works without an API key.)

(a) Set up now
(b) Skip
```

**If user chooses (a)**:

1. Tell user: "Go to https://stitch.withgoogle.com/settings and create an API key."
2. Use AskUserQuestion with two options: "Skip" and "Already configured". The user will use the auto-generated free-text input option to paste their API key. In the question text, clearly state: "API 키를 아래 텍스트 입력란에 붙여넣어 주세요."
3. Read `~/.claude/settings.json`.
4. Add the key to the `env` section (create `env` if it doesn't exist):
   ```json
   {
     "env": {
       "STITCH_API_KEY": "<user-provided-key>"
     },
     ...existing settings
   }
   ```
5. Write the updated settings.json back.
6. Tell user: "Saved. Start a new Claude Code session to activate."

**Do NOT** suggest modifying shell profiles (~/.zshrc, ~/.bashrc) or running shell commands.

**If user chooses (b)**, continue without it and note in the summary.

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
    "~/.claude/rules/redsub-testing.md"
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
- Rules deployed: 3 (code-quality, workflow, testing)
- CLAUDE.md: [created at ~/.claude/CLAUDE.md / markers added / skipped]
- Stitch API: [configured / skipped (optional)]
- Dependencies: [N]/[total] installed
```

**If there are still missing plugins** (user skipped or some failed), append:

```
Missing plugins ([N]):
  claude plugin install <name>@<marketplace>
  ...
```
