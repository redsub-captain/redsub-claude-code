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

For missing plugins, check marketplaces first:

**Step A — Marketplace registration:**
Read the `marketplaces` array from `config/plugins.json`. Check if each is registered. If not, show registration commands FIRST:
```
The following marketplaces need to be registered first:
/plugin marketplace add <marketplace-name>
```

**Step B — Plugin installation:**
For each missing plugin, construct the install command from `name` and `marketplace` fields:
```
Missing plugins (install all at once):
/plugin install <name>@<marketplace>
...
```

**Step C — Re-run:**
```
After installing, re-run: /redsub-setup --force
```

### 2. Deploy rules

Copy the 3 rule files from the plugin to the Claude Code global rules directory.

```bash
mkdir -p ~/.claude/rules
cp ${CLAUDE_PLUGIN_ROOT}/rules/redsub-*.md ~/.claude/rules/
```

### 3. CLAUDE.md handling

If `CLAUDE.md` does NOT exist: create from the plugin's template.
```bash
cp ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template CLAUDE.md
```

If `CLAUDE.md` already EXISTS, ask user how to integrate:
```
CLAUDE.md already exists. How should we add the workflow guide?
(a) Append at end (with markers)
(b) Prepend at start (with markers)
(c) Skip
```

For (a) or (b), wrap the template content with markers:
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
2. Use AskUserQuestion to ask the user to paste their API key.
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

Create `~/.claude-redsub/install-manifest.json`:
```json
{
  "version": "2.0.0",
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

### 6. Completion marker

```bash
mkdir -p ~/.claude-redsub
date > ~/.claude-redsub/.setup-done
```

### 7. Summary

```
Setup complete:
- Rules deployed: 3
- CLAUDE.md: [created/markers added/skipped]
- Dependencies: [all installed / N missing]
- Stitch API: [configured/not set (optional)]
```
