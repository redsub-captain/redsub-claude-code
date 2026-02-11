# Compatibility Log

Tracks compatibility between this plugin and Claude Code versions.
`/redsub-update` skill auto-checks these.

## Current Status

| Item | Version |
|------|---------|
| Plugin | 2.1.0 |
| Claude Code | (recorded on install) |

## Changelog

### 2.1.0 (Workflow orchestration improvements)
- Active workflow orchestration via UserPromptSubmit hook
- Main branch edit warning via PreToolUse hook
- SessionStart branch safety check
- File Edit/Write Safety rules (parallel edit limit documented)
- Natural language → command mapping (커밋해/릴리즈해/배포해)
- Context-aware command mapping in workflow rules
- Language selection removed (follows Claude Code native language)
- SvelteKit MCP fix (@sveltejs/mcp)
- Stitch API key setup guide in /redsub-setup
- Setup bash command descriptions improved
- 9 hooks (was 7), 10 scripts (was 8)

### 2.0.0 (Major restructure)
- 12 skills (redsub- prefix), 4 agents, 7 hooks, 3 rules
- MCP: stitch, sveltekit (context7 moved to official plugin)
- Removed: 6 duplicate skills, reviewer agent, security/database rules, .lsp.json
- Added: redsub-uninstall, redsub-update, redsub-doctor
- Integrated: superpowers, code-review, pr-review-toolkit, ralph-loop
- Korean → English content migration
- Install manifest + marker system for CLAUDE.md
- Context-aware command mapping

### 1.0.0 (Initial release)
- 15 skills, 5 agents, 10 hooks, 5 rules
- MCP: context7, stitch, sveltekit
- LSP: TypeScript
