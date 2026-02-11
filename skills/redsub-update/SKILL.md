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
/plugin update redsub-claude-code@redsub-plugins

Note: install-manifest.json is auto-synced on next session start.
```

### 7. Post-update sync (if update was just performed)

If the user has already run `/plugin update` during this session, sync the install manifest immediately:

```bash
PLUGIN_VER=$(python3 -c "import json; print(json.load(open('${CLAUDE_PLUGIN_ROOT}/package.json'))['version'])")
MANIFEST="$HOME/.claude-redsub/install-manifest.json"
if [ -f "$MANIFEST" ]; then
  python3 -c "
import json
with open('$MANIFEST', 'r') as f:
    data = json.load(f)
old_ver = data.get('version', 'unknown')
data['version'] = '$PLUGIN_VER'
with open('$MANIFEST', 'w') as f:
    json.dump(data, f, indent=2)
print(f'install-manifest.json synced: v{old_ver} -> v$PLUGIN_VER')
"
fi
```
