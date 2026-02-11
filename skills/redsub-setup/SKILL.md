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

Check `~/.claude/plugins/installed_plugins.json` for required plugins:

| Plugin | Purpose |
|--------|---------|
| superpowers | Planning, TDD, subagent-driven development |
| code-review | Automated PR review with GitHub comments |
| pr-review-toolkit | 6 specialized review agents |
| ralph-loop | Iterative development loops |
| security-guidance | Security best practices |
| context7 | Library documentation |
| typescript-lsp | TypeScript real-time diagnostics |

For each missing plugin, show install command:
```
Missing: superpowers
Install: /plugin install superpowers@claude-plugins-official
```

### 2. Deploy rules

Copy the 3 rule files (code quality, workflow, testing) from the plugin to the Claude Code global rules directory. These rules are automatically loaded by Claude Code based on file patterns.

```bash
# Ensure the Claude Code rules directory exists
mkdir -p ~/.claude/rules
# Deploy: redsub-code-quality.md, redsub-workflow.md, redsub-testing.md
cp ${CLAUDE_PLUGIN_ROOT}/rules/redsub-*.md ~/.claude/rules/
```

### 3. CLAUDE.md handling

CLAUDE.md is the project-level instruction file that Claude Code reads on every session. This step sets up the workflow guide.

If `CLAUDE.md` does NOT exist in the current directory: create from the plugin's template.
```bash
# Create CLAUDE.md from template (includes workflow commands, tech stack, principles)
cp ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template CLAUDE.md
```

If `CLAUDE.md` already EXISTS, ask user how to integrate:
```
CLAUDE.md already exists. How should we add the workflow guide?
(a) Append at end (with markers)
(b) Prepend at start (with markers)
(c) Skip
```

For (a) or (b), wrap the template content with markers so it can be updated or removed later:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

### 4. Stitch API key (optional)

The `/redsub-design` skill uses [Google Stitch MCP](https://stitch.googleapis.com) for UI/UX screen design. An API key is required only if the user plans to use this feature.

Check if `STITCH_API_KEY` environment variable is set:

```bash
# Check if the Stitch API key is configured
echo "${STITCH_API_KEY:+configured}"
```

**If not set**, ask user:
```
Stitch API key is not configured.
The /redsub-design skill requires this key for UI/UX screen design.

(a) Set up now — I'll guide you through getting a key
(b) Skip — I'll set it up later
```

**If user chooses (a)**, show the setup guide:
```
1. Go to https://console.cloud.google.com/apis/credentials
2. Create an API key (or use an existing one)
3. Enable the "Generative Language API" for the key
4. Add the key to your shell profile:

   echo 'export STITCH_API_KEY="your-api-key-here"' >> ~/.zshrc
   source ~/.zshrc

After setting the key, restart Claude Code for it to take effect.
```

**If user chooses (b)**, continue without it and note in the summary.

### 5. Install manifest

Create a manifest file that records what was installed. This is used by `/redsub-uninstall` for clean removal and by `/redsub-doctor` for integrity checks.

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

Mark setup as complete. This prevents accidental re-runs (unless `--force` is used).

```bash
# Create the completion marker with timestamp
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
