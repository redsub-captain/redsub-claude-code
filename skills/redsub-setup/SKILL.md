---
name: redsub-setup
description: Initial plugin setup. Deploy rules, create CLAUDE.md, check dependencies.
---

# Initial Setup

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

## Re-run prevention

If `~/.claude-redsub/.setup-done` exists and `--force` was NOT given in `$ARGUMENTS`, print "Already configured. Use --force to re-run." and stop.

## Procedure

### 1. Language selection

```
Select language / 언어를 선택하세요:
1. English
2. 한국어
```

Save choice:
```bash
mkdir -p ~/.claude-redsub
echo "[en or ko]" > ~/.claude-redsub/language
```

### 2. Dependency plugins check

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

### 3. Deploy rules

Copy rule files from `${CLAUDE_PLUGIN_ROOT}/rules/` to `~/.claude/rules/`:
```bash
mkdir -p ~/.claude/rules
cp ${CLAUDE_PLUGIN_ROOT}/rules/redsub-*.md ~/.claude/rules/
```

### 4. CLAUDE.md handling

If `CLAUDE.md` does NOT exist: create from template.
```bash
cp ${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template CLAUDE.md
```

If `CLAUDE.md` EXISTS, ask user:
```
CLAUDE.md already exists. How should we add the workflow guide?
(a) Append at end (with markers)
(b) Prepend at start (with markers)
(c) Skip
```

For (a) or (b), wrap content with:
```
<!-- redsub-claude-code:start -->
(template content)
<!-- redsub-claude-code:end -->
```

### 5. Environment variables

Check and warn if missing:
- `STITCH_API_KEY` — Required for `/redsub-design` skill (optional)

### 6. Install manifest

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

### 7. Completion marker

```bash
mkdir -p ~/.claude-redsub
date > ~/.claude-redsub/.setup-done
```

### 8. Summary

```
Setup complete:
- Language: [English/한국어]
- Rules deployed: 3
- CLAUDE.md: [created/markers added/skipped]
- Dependencies: [all installed / N missing]
- Stitch API: [configured/not set (optional)]
```
