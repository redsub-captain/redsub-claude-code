---
name: redsub-update
description: Check plugin version updates and Claude Code compatibility.
---

# Update Check

> **Language**: Follow the user's Claude Code language setting.

> **IMPORTANT**: All bash commands in this skill MUST be executed sequentially (one at a time), NOT in parallel. Parallel execution causes "Sibling tool call errored" failures.

## Procedure

### 1. Current version

Read version from `${CLAUDE_PLUGIN_ROOT}/package.json`.

```bash
cat ${CLAUDE_PLUGIN_ROOT}/package.json
```

### 2. Latest version (GitHub)

First try GitHub releases API:
```bash
curl -s https://api.github.com/repos/redsub-captain/redsub-claude-code/releases/latest | grep '"tag_name"'
```

If no releases found, check the `package.json` on the default branch:
```bash
curl -s https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json | grep '"version"'
```

### 3. Compare versions

- If current = latest: "Plugin is up to date (vX.X.X)"
- If current < latest: proceed to step 6 for update instructions

### 4. Claude Code compatibility

```bash
claude --version 2>/dev/null || echo "unknown"
```

Compare against minimum required version if specified in plugin metadata.

### 5. Dependency check

Read `~/.claude/plugins/installed_plugins.json` and verify these required plugins are installed:
- superpowers
- code-review
- pr-review-toolkit
- ralph-loop
- security-guidance
- context7
- typescript-lsp

Report missing plugins with install commands:
```
Missing: [plugin-name]
Install: /plugin install [plugin-name]@claude-plugins-official
```

### 6. Update instructions (if needed)

```
Update available: vCURRENT → vLATEST

To update:
1. /plugin → Installed → redsub-claude-code → Update now
2. Start a new session (to apply updated skills/hooks)

Note: install-manifest.json is auto-synced on next session start.
```
