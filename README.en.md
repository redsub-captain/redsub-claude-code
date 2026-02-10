**English** | [한국어](README.md)

# redsub-claude-code

A [Claude Code](https://claude.com/claude-code) plugin that automates the entire development workflow for solo developers — from planning to deployment.

It structures the full cycle (plan → branch → code → TDD → review → ship → deploy) using skills, agents, and hooks, and **physically blocks** rule violations.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) v1.0.33 or later
- Node.js (required for `npx` to run MCP servers)

## Installation

### 1. Add marketplace

Run inside Claude Code:

```
/plugin marketplace add redsub-captain/redsub-claude-code
```

### 2. Install plugin

```
/plugin install redsub-claude-code@redsub-plugins
```

### 3. Initial setup

```
/redsub-claude-code:setup
```

This skill will:
- Deploy 5 rules to `~/.claude/rules/`
- Generate a CLAUDE.md template at the project root
- Check TypeScript LSP dependencies
- Verify environment variables (`STITCH_API_KEY`)

## Workflow

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

> All skills use the `/redsub-claude-code:` prefix.
> Example: `/redsub-claude-code:plan`, `/redsub-claude-code:validate`

| Phase | Skill | Description |
|-------|-------|-------------|
| Admin | `:setup` | Initial setup (deploy rules, create CLAUDE.md) |
| Plan | `:plan` | Explore codebase and create work plan (planner agent) |
| Start | `:start-work` | Create feature branch |
| Dev | `:save` | WIP commit |
| | `:explore` | Explore codebase architecture (planner agent) |
| | `:fix-all` | Search and bulk-fix a pattern across the entire codebase |
| Design | `:design` | UI/UX design via Stitch MCP (designer agent) |
| Test | `:test` | TDD: write test → verify fail → implement → pass (developer agent) |
| Validate | `:validate` | `npm run lint && npm run check && npm run test:unit` |
| Review | `:review` | Code review: security/types/perf/DB/tests (reviewer agent) |
| Ship | `:ship` | Enforced Save → Validate → Merge pipeline |
| Deploy | `:deploy` | Dev → verify → user approval → prod |
| Status | `:status` | Git status, recent commits, pending work summary |
| Session | `:session-save` | Save progress to CLAUDE.md + WIP commit |
| Maintain | `:update-check` | Analyze Claude Code updates for plugin compatibility |

## Components

| Type | Count | Details |
|------|-------|---------|
| Skills | 15 | See workflow table above |
| Agents | 5 | developer (Opus), reviewer (Sonnet, read-only), planner (Sonnet, read-only), devops (Opus), designer (Opus, Stitch MCP) |
| Hooks | 7 | Block main commits, validate before merge, auto-format, version check, desktop notifications, context preservation, session end check |
| Rules | 5 | Code quality, database, security, workflow, testing |
| MCP | 3 | context7 (library docs), stitch (UI/UX design), sveltekit (official docs) |
| LSP | 1 | TypeScript (real-time type error diagnostics) |

## Three-Layer Defense (MECE Automation)

MECE (Mutually Exclusive, Collectively Exhaustive) — cover every case, without gaps or overlaps.

Writing "don't do X" in CLAUDE.md alone can't guarantee Claude will follow the rule. This plugin **physically enforces** rules in three layers:

| Layer | Mechanism | Role | Example |
|-------|-----------|------|---------|
| 1. Prevention | **Rules** | Auto-inject rules by file pattern | TypeScript strict rules auto-load when editing `.ts` files |
| 2. Blocking | **Hooks** | Physically block risky actions | `exit 2` blocks direct commits to main branch |
| 3. Procedure | **Skills** | Isolated execution via subagents | `:ship` enforces Save → Validate → Merge order |

## Tech Stack

This plugin is designed for the following tech stack:

SvelteKit 5 / Firebase / TypeScript / Supabase / Cloudflare Pages / Tailwind CSS 4

To use with a different stack, modify the rules, agents, and skills accordingly.

## Environment Variables

| Variable | Purpose | Required |
|----------|---------|----------|
| `STITCH_API_KEY` | Google Stitch MCP (UI/UX design in `:design` skill) | Optional (only `:design` skill is unavailable without it) |

## License

MIT
