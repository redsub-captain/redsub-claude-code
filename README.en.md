**English** | [한국어](README.md)

# redsub-claude-code

A **workflow orchestrator** plugin for Claude Code, designed for solo developers.

Works in **combination** with 13 official plugins (superpowers, code-review, pr-review-toolkit, ralph-loop, frontend-design, feature-dev, etc.) to automate the entire development cycle from planning to deployment.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) v1.0.33 or later
- Node.js (required for `npx` to run MCP servers)

## Installation

### 1. Add marketplace

```
/plugin marketplace add redsub-captain/redsub-claude-code
```

### 2. Install plugin

```
/plugin install redsub-claude-code@redsub-plugins
```

### 3. Initial setup

```
/redsub-setup
```

This skill will:
- Check and suggest installing required official plugins
- Deploy 3 rules to `~/.claude/rules/`
- Generate a CLAUDE.md template (marker-based append/prepend/skip if file exists)
- Create install manifest (`~/.claude-redsub/install-manifest.json`)

### Update

A notification is automatically shown at session start when a new version is available.

```
/redsub-update
```

Automatically handles marketplace pull → cache copy → registry update. Start a new session after completion to apply changes.

### Uninstall

```
/redsub-uninstall
```

## Required Official Plugins

This plugin works in combination with these official plugins:

| Plugin | Marketplace | Role |
|--------|-------------|------|
| superpowers | obra/superpowers-marketplace | TDD, design, planning, subagents, code review delegation |
| code-review | claude-plugins-official | Automated PR review (GitHub comment posting) |
| pr-review-toolkit | claude-plugins-official | 6 specialized review agents (test/type/security/simplifier, etc.) |
| ralph-loop | claude-plugins-official | Iterative task automation (TDD, bulk fixes) |
| security-guidance | claude-plugins-official | Security best practices |
| context7 | claude-plugins-official | Latest library documentation lookup |
| typescript-lsp | claude-plugins-official | Real-time TypeScript type diagnostics |
| frontend-design | claude-plugins-official | UI/UX implementation guide (works without Stitch) |
| feature-dev | claude-plugins-official | Structured feature development (`/feature-dev`) |
| code-simplifier | claude-plugins-official | Autonomous code simplification review |
| claude-md-management | claude-plugins-official | CLAUDE.md audit + session learning (`/revise-claude-md`) |
| firebase | claude-plugins-official | Firebase MCP (Firestore, Auth, Functions) |
| supabase | claude-plugins-official | Supabase MCP (PostgreSQL, Auth, Storage) |

## Workflow

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

## Command Reference

### /redsub-start-work [name]

Create a feature branch and start working.

**When to use:** Starting new work.
```
/redsub-start-work user-authentication
```

### /redsub-test [target]

TDD automation. Runs the Red-Green-Refactor cycle.

**When to use:** Test-first for new features, reproduction test first for bug fixes.
```
/redsub-test user-authentication
```

**With ralph-loop (iterative):**
```
/ralph-loop "TDD: user-authentication" --completion-promise "ALL TESTS PASSING" --max-iterations 20
```

### /redsub-validate

Run lint + type check + unit tests sequentially. Evidence (command output) required.

**When to use:** After code changes, required before merge.
```
/redsub-validate
```

### /redsub-ship [patch|minor|major] [description]

Enforced pipeline: Save → Validate → Review → Version → Merge → Tag → Push.

**When to use:** When a feature is complete and ready to integrate into main.
```
/redsub-ship minor "Add user authentication feature"
```

### /redsub-fix-all [pattern]

Search the entire codebase for a pattern and bulk-fix all occurrences.

**When to use:** Lint errors, naming changes, pattern bulk fixes.
```
/redsub-fix-all "ESLint errors"
/redsub-fix-all --team "ESLint errors"    # Parallel (Agent Teams)
```

**With ralph-loop:**
```
/ralph-loop "Fix all ESLint errors" --completion-promise "LINT CLEAN" --max-iterations 30
```

### /redsub-deploy [dev|prod]

Deploy to dev/prod environments. Prod requires explicit user approval.

**When to use:** Deployment time.
```
/redsub-deploy dev     # Dev first
/redsub-deploy prod    # Prod (approval required)
```

### /redsub-design [screen]

UI/UX screen design via Stitch MCP.

**When to use:** Designing new screens.
```
/redsub-design dashboard page
```

### /redsub-session-save

Save progress to CLAUDE.md + WIP commit.

**When to use:** Before ending a session.
```
/redsub-session-save
```

### /redsub-setup

Initial setup (check dependency plugins, deploy rules, create CLAUDE.md).

### /redsub-update

Auto-update plugin. Handles marketplace pull → cache copy → registry update in one step.

### /redsub-doctor

Diagnose plugin health + auto-repair.

### /redsub-uninstall

Manifest-based clean removal.

## Scenario → Command Mapping

### "I want to build a new feature"
1. `/brainstorming` — Generate design document (superpowers)
2. `/writing-plans` — Create 2-5 min implementation tasks
3. `/redsub-start-work feature-name` — Create branch
4. `/redsub-test target` — TDD implementation
5. `/redsub-validate` — Validation
6. `/review-pr` — Review (6 specialized agents in parallel)
7. `/redsub-ship minor "feature description"` — Ship it

### "I have 100 lint errors"
- `/redsub-fix-all "ESLint errors"` — Sequential exhaustive fix
- `/redsub-fix-all --team "ESLint errors"` — Parallel team fix (Agent Teams)
- `/ralph-loop "Fix all ESLint errors" --completion-promise "LINT CLEAN"` — Iterative fix

### "I want to deploy"
1. `/redsub-validate` — Pre-validation
2. `/redsub-deploy dev` — Dev first
3. `/redsub-deploy prod` — Prod (user approval required)

### "Review my code"
- If there's a PR → `/code-review` (auto-post GitHub comments)
- Deep analysis → `/review-pr` (6 specialized agents in parallel)
- Plan-vs-implementation → superpowers:requesting-code-review

### "I need to build a complex feature"
1. `/feature-dev user-authentication` — Start structured feature development
2. Agent team automatically handles design → implementation → testing
3. `/redsub-ship minor "feature description"` — Ship it

### "I want to clean up CLAUDE.md"
```
/revise-claude-md
```
CLAUDE.md quality audit + captures patterns/conventions discovered during the session. `/redsub-session-save` runs this automatically before session end.

### "The plugin seems broken"
```
/redsub-doctor
```
Auto-diagnoses rules/hooks/manifest/dependency plugins + repairs.

## Removed Skills → Replacements

| Removed Skill | Replacement |
|--------------|-------------|
| /rs-review | /code-review or /review-pr |
| /rs-save | /commit |
| /rs-plan | /brainstorming → /writing-plans |
| /rs-explore | /brainstorming |
| /rs-status | git status |
| /rs-update-check | /redsub-update |

## Components

| Type | Count | Details |
|------|-------|---------|
| Skills | 12 | See command reference above |
| Agents | 4 | developer (Opus), planner (Sonnet, read-only), devops (Opus), designer (Opus, Stitch MCP) |
| Hooks | 9 | Workflow orchestrator, main commit/merge guard (version consistency check), main edit warning, auto-format + edit tracking, validate marker creation, version/plugin/CLAUDE.md freshness check, desktop notifications, context preservation + learning reminder, session end triple-check |
| Rules | 3 | Code quality (security/DB merged), workflow (context-aware mapping), testing (TDD Iron Law) |
| MCP | 2 | stitch (UI/UX design), sveltekit (official docs) |

## Three-Layer Defense

| Layer | Mechanism | Role | Example |
|-------|-----------|------|---------|
| 1. Prevention | **Rules** | Auto-inject rules by file pattern | TypeScript strict rules auto-load when editing `.ts` files |
| 2. Blocking | **Hooks** | Physically block risky actions | `exit 2` blocks direct commits to main branch |
| 3. Procedure | **Skills** | Enforce pipeline order | `/redsub-ship` enforces Save → Validate → Merge order |

## Tech Stack

SvelteKit 5 / Firebase / TypeScript / Supabase / Cloudflare Pages / Tailwind CSS 4

To use with a different stack, modify the rules, agents, and skills.

## Environment Variables

| Variable | Purpose | Required |
|----------|---------|----------|
| `STITCH_API_KEY` | Google Stitch MCP (`/redsub-design` skill) | Optional |

### Setting Up Stitch API Key (Optional)

The `/redsub-design` skill requires a Stitch API key for UI/UX screen design. You can still get UI implementation guidance via the **frontend-design** plugin without Stitch, so skip this if you don't need screen design generation.

Running `/redsub-setup` handles API key input and storage automatically.

For manual setup:
1. Create an API key at [stitch.withgoogle.com/settings](https://stitch.withgoogle.com/settings)
2. Add to `~/.claude/settings.json` under the `env` section:
   ```json
   {
     "env": {
       "STITCH_API_KEY": "your-api-key-here"
     }
   }
   ```
3. Start a new Claude Code session

## License

MIT
