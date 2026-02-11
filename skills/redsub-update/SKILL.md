---
name: redsub-update
description: Check plugin version updates and Claude Code compatibility.
---

# Update Check

> **Language**: Follow the user's Claude Code language setting.

## Procedure

### 1. Current version

Read version from `${CLAUDE_PLUGIN_ROOT}/plugin.json`.

### 2. Latest version (GitHub API)

```bash
curl -s https://api.github.com/repos/redsub-captain/redsub-claude-code/releases/latest | grep '"tag_name"'
```

If no releases, check the `package.json` on the default branch:
```bash
curl -s https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json | grep '"version"'
```

### 3. Compare versions

- If current = latest: "Plugin is up to date (vX.X.X)"
- If current < latest: show update instructions

### 4. Claude Code compatibility

Check Claude Code version:
```bash
claude --version 2>/dev/null || echo "unknown"
```

Compare against minimum required version in plugin.json.

### 5. Dependency check

Verify required official plugins are installed by checking `~/.claude/plugins/installed_plugins.json`:
- superpowers
- code-review
- pr-review-toolkit
- ralph-loop
- security-guidance
- context7
- typescript-lsp

Report missing plugins with install commands.

### 6. Update instructions (if needed)

```
Update available: vCURRENT → vLATEST

To update:
/plugin update redsub-claude-code@redsub-plugins

After update, run /redsub-doctor to verify integrity.
```
