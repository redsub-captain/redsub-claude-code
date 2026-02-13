---
name: redsub-uninstall
description: Clean uninstall of redsub-claude-code plugin using install manifest.
---

# Uninstall

## Procedure

### 1. Read manifest

Read `~/.claude-redsub/install-manifest.json`. If missing, warn and proceed with best-effort cleanup.

### 2. Remove CLAUDE.md markers

For files in `files_modified`, remove content between markers:
```
<!-- redsub-claude-code:start -->
...
<!-- redsub-claude-code:end -->
```

If CLAUDE.md becomes empty after marker removal, delete it.
For files in `files_created`, delete them entirely (only if unmodified since install).

Also remove any orphaned rules files from previous versions:
```bash
rm -f ~/.claude/rules/redsub-*.md
```

### 3. Remove plugin data

```bash
rm -rf ~/.claude-redsub
```

### 4. Remove plugin cache

```bash
# Remove from installed_plugins.json
# The actual cache is managed by Claude Code
```

Inform the user to run:
```
/plugin uninstall redsub-claude-code@redsub-plugins
```

### 5. Summary

```
Uninstall complete:
- CLAUDE.md markers removed: [yes/no]
- Legacy rules cleaned: [yes/no/none found]
- Plugin data removed: yes
- Run '/plugin uninstall redsub-claude-code@redsub-plugins' to complete.
```
