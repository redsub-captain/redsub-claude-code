---
name: redsub-doctor
description: Diagnose and auto-repair plugin integrity.
---

# Doctor

> **Language**: Follow the user's Claude Code language setting.

Diagnose plugin health and auto-repair issues.

## Checks

### 1. Rules integrity

Verify these files exist in `~/.claude/rules/`:
- `redsub-code-quality.md`
- `redsub-workflow.md`
- `redsub-testing.md`

**Auto-fix**: Re-copy from `${CLAUDE_PLUGIN_ROOT}/rules/`.

### 2. Manifest consistency

Read `~/.claude-redsub/install-manifest.json`:
- Verify all `rules_installed` files exist
- Verify all `files_created` are tracked
- Verify version matches plugin version

**Auto-fix**: Regenerate manifest from current state.

### 3. Dependency plugins

Check `~/.claude/plugins/installed_plugins.json` for required plugins:
- superpowers, code-review, pr-review-toolkit, ralph-loop
- security-guidance, context7, typescript-lsp

**Report**: List missing plugins with install commands.

### 4. CLAUDE.md marker integrity

If CLAUDE.md contains `<!-- redsub-claude-code:start -->`:
- Verify matching `<!-- redsub-claude-code:end -->` exists
- Verify content between markers is valid

**Auto-fix**: Re-inject markers if corrupted.

### 5. Hooks integrity

Verify `${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json` is valid JSON.
Verify all referenced scripts exist and are executable.

**Auto-fix**: Re-set executable permissions on scripts.

### 6. Prefix consistency

Search all plugin files for legacy `/rs-` references:
```bash
grep -r '/rs-' ${CLAUDE_PLUGIN_ROOT}/skills/ ${CLAUDE_PLUGIN_ROOT}/agents/ ${CLAUDE_PLUGIN_ROOT}/rules/ 2>/dev/null
```

**Report**: List any legacy references found.

## Output

```
Plugin health check:
- Rules: [OK/FIXED/MISSING]
- Manifest: [OK/FIXED/MISSING]
- Dependencies: [OK/N missing]
- CLAUDE.md markers: [OK/FIXED/N/A]
- Hooks: [OK/FIXED]
- Prefix consistency: [OK/N legacy refs]

Overall: [HEALTHY/REPAIRED/NEEDS ATTENTION]
```

If issues were auto-fixed, summarize what changed.
If issues need manual intervention, provide specific instructions.
