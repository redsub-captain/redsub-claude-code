---
name: redsub-doctor
description: Diagnose and auto-repair plugin integrity.
---

# Doctor

Diagnose plugin health and auto-repair issues.

## Checks

### 1. Legacy rules cleanup

Check for orphaned rules files from previous versions in `~/.claude/rules/`:
```bash
ls ~/.claude/rules/redsub-*.md 2>/dev/null
```

If any `redsub-*.md` files are found, they are leftovers from v2.x (v3.0 no longer deploys rules files).

**Auto-fix**: Remove orphaned files:
```bash
rm -f ~/.claude/rules/redsub-*.md
```

### 2. Manifest consistency

Read `~/.claude-redsub/install-manifest.json`:
- Verify all `files_created` are tracked
- Verify version matches plugin version

**Auto-fix**: Regenerate manifest from current state.

### 3. Dependency plugins

**Read the plugin registry from `${CLAUDE_PLUGIN_ROOT}/config/plugins.json`** — this is the Single Source of Truth (SSOT). Do NOT use a hardcoded list.

For each plugin in the registry, check if it's installed in `~/.claude/plugins/installed_plugins.json`.

**Report**: List missing plugins with install commands constructed from `name` and `marketplace` fields:
```
Missing: <name>
Install: /plugin install <name>@<marketplace>
```

### 4. CLAUDE.md marker integrity

If CLAUDE.md contains `<!-- redsub-claude-code:start -->`:
- Verify matching `<!-- redsub-claude-code:end -->` exists
- Verify content between markers is valid
- Check `<!-- redsub-template-version:X.X.X -->` inside markers:
  - Compare with version in `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template`
  - Report: "Template: current (vX.X.X)" / "Template: outdated (vX.X.X → vY.Y.Y)" / "Template: legacy (no version)"

**Auto-fix**: Re-inject markers if corrupted. For outdated templates, suggest `/redsub-update`.

### 5. Hooks integrity

Verify `${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json` is valid JSON.
Verify all referenced scripts exist and are executable.

**Auto-fix**: Re-set executable permissions on scripts.

### 6. Prefix consistency

Search all plugin files for legacy `/rs-` references:
```bash
grep -r '/rs-' ${CLAUDE_PLUGIN_ROOT}/skills/ ${CLAUDE_PLUGIN_ROOT}/agents/ 2>/dev/null
```

**Report**: List any legacy references found.

## Output

```
Plugin health check:
- Legacy rules: [CLEAN/REMOVED N files]
- Manifest: [OK/FIXED/MISSING]
- Dependencies: [OK/N missing] (12 plugins)
- CLAUDE.md markers: [OK/FIXED/N/A]
- Template version: [current/outdated/legacy]
- Hooks: [OK/FIXED]
- Prefix consistency: [OK/N legacy refs]

Overall: [HEALTHY/REPAIRED/NEEDS ATTENTION]
```

If issues were auto-fixed, summarize what changed.
If issues need manual intervention, provide specific instructions.
