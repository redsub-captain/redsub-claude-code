---
name: redsub-update
description: Check plugin version updates and Claude Code compatibility.
---

# Plugin Auto-Update

> **Language**: Follow the user's Claude Code language setting.

> **IMPORTANT**: All bash commands in this skill MUST be executed sequentially (one at a time), NOT in parallel. Parallel execution causes "Sibling tool call errored" failures.

## Procedure

### 1. Current version

Read version from `${CLAUDE_PLUGIN_ROOT}/package.json`.

### 2. Latest version (GitHub)

```bash
curl -s https://api.github.com/repos/redsub-captain/redsub-claude-code/releases/latest | grep '"tag_name"'
```

If no releases found, fallback:
```bash
curl -s https://raw.githubusercontent.com/redsub-captain/redsub-claude-code/main/package.json | grep '"version"'
```

### 3. Compare versions

- If current = latest → report "Up to date (vX.X.X)" and skip to step 6.
- If current < latest → proceed to step 4.

### 4. Auto-update

Execute these commands **sequentially** (one at a time):

#### 4a. Pull latest from marketplace repo

```bash
git -C ~/.claude/plugins/marketplaces/redsub-plugins pull origin main
```

If this fails (e.g. merge conflicts), reset and retry:
```bash
git -C ~/.claude/plugins/marketplaces/redsub-plugins fetch origin main && git -C ~/.claude/plugins/marketplaces/redsub-plugins reset --hard origin/main
```

#### 4b. Read new version from pulled repo

```bash
cat ~/.claude/plugins/marketplaces/redsub-plugins/package.json
```

Extract the `version` field. Let this be `NEW_VERSION`.

#### 4c. Create new cache directory and copy files

```bash
mkdir -p ~/.claude/plugins/cache/redsub-plugins/redsub-claude-code/NEW_VERSION
```

```bash
rsync -a --exclude='.git' ~/.claude/plugins/marketplaces/redsub-plugins/ ~/.claude/plugins/cache/redsub-plugins/redsub-claude-code/NEW_VERSION/
```

#### 4d. Get git commit SHA

```bash
git -C ~/.claude/plugins/marketplaces/redsub-plugins rev-parse HEAD
```

Save this as `COMMIT_SHA`.

#### 4e. Update installed_plugins.json

Read `~/.claude/plugins/installed_plugins.json`.

Find the `"redsub-claude-code@redsub-plugins"` entry and update:
- `installPath` → `~/.claude/plugins/cache/redsub-plugins/redsub-claude-code/NEW_VERSION` (use full absolute path with $HOME expanded)
- `version` → `NEW_VERSION`
- `lastUpdated` → current ISO timestamp
- `gitCommitSha` → `COMMIT_SHA`

Write the updated JSON back using the Edit tool. **Do NOT use Write** (the file was already Read).

### 5. Verify update

Read `~/.claude/plugins/cache/redsub-plugins/redsub-claude-code/NEW_VERSION/package.json` and confirm the version matches.

### 6. Claude Code compatibility

```bash
claude --version 2>/dev/null || echo "unknown"
```

### 7. Report result

If update was performed:
```
Updated: vOLD → vNEW
Restart the session to apply changes.
```

If already up to date:
```
Up to date: vX.X.X
```
