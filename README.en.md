**English** | [한국어](README.md)

# redsub-claude-code

A **workflow orchestrator** plugin for Claude Code, designed for solo developers.

Works in **combination** with 12 official plugins (superpowers, coderabbit, commit-commands, ralph-loop, frontend-design, feature-dev, etc.) to automate the entire development cycle from planning to deployment.

## What's New in v3.0

- **Zero Rules** — ~96% reduction in session start tokens (~11,800 → ~500)
- **superpowers hybrid** — Core methodology (TDD, debugging, brainstorming) delegated to superpowers; redsub skills are thin wrappers
- **coderabbit integration** — AI code review with 40+ static analyzers
- **One-step setup** — Single `/redsub-setup` run = everything configured (zero user input)

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

**One command does everything automatically:**
- Auto-registers 12 dependency plugins
- Auto-registers permission patterns
- Creates/updates minimal CLAUDE.md template
- Creates install manifest
- Cleans up legacy rules files (when upgrading from v2.x)

### Update

A notification is shown at session start when a new version is available.

```
/redsub-update
```

If dependency plugins are missing after update:
```
/redsub-doctor        # Diagnose + auto-install
/redsub-setup --force # Or full re-setup
```

### Uninstall

```
/redsub-uninstall
```

## Required Official Plugins

All 12 plugins are auto-registered when you run `/redsub-setup`:

| Plugin | Role |
|--------|------|
| superpowers | TDD/brainstorming/debugging/verification (v4.3.0+) |
| coderabbit | AI code review (40+ static analyzers) |
| commit-commands | Commit/push/PR automation (/commit, /commit-push-pr) |
| ralph-loop | Iterative task automation (TDD, bulk fixes) |
| frontend-design | UI/UX implementation guide |
| feature-dev | Structured feature development (/feature-dev) |
| code-simplifier | Autonomous code simplification review |
| context7 | Latest library documentation lookup |
| playwright | E2E browser test automation |
| security-guidance | Security best practices |
| claude-md-management | CLAUDE.md audit + session learning |
| claude-code-setup | Analyze codebase → recommend Claude Code automations |

## Workflow

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

## Command Reference

### /redsub-start-work [name]

Create a feature branch and start working.

```
/redsub-start-work user-authentication
```

### /redsub-brainstorm

Collaborative design through Socratic dialogue. Based on superpowers:brainstorming.

```
/redsub-brainstorm
```

### /redsub-plan

Create 2-5 minute implementation tasks. Based on superpowers:writing-plans.

```
/redsub-plan
```

### /redsub-execute

Execute plan tasks sequentially with subagent 2-stage review. Based on superpowers:executing-plans.

```
/redsub-execute
```

### /redsub-validate

Run lint + type check + unit tests. Includes SSOT consistency checks and 5-step evidence gate.

```
/redsub-validate
```

### /redsub-ship [patch|minor|major] [description]

Enforced pipeline: Save → Validate → Review → Version → Merge → Tag → Push.

```
/redsub-ship minor "Add user authentication"
```

### /redsub-fix-all [pattern]

Search the entire codebase for a pattern and bulk-fix all occurrences.

```
/redsub-fix-all "ESLint errors"
```

### /redsub-deploy [dev|prod]

Deploy to dev/prod environments. Prod requires explicit user approval.

```
/redsub-deploy dev
/redsub-deploy prod
```

### /redsub-session-save

Save progress to CLAUDE.md + WIP commit.

### /redsub-setup

Initial setup (auto-register plugins/permissions, create CLAUDE.md).

### /redsub-update

Auto-update plugin.

### /redsub-doctor

Diagnose plugin health + auto-repair + legacy rules cleanup.

### /redsub-uninstall

Manifest-based clean removal.

## Scenario Guide

### "I want to build a new feature"
1. `/redsub-brainstorm` — Generate design document
2. `/redsub-plan` — Create 2-5 min implementation tasks
3. `/redsub-start-work feature-name` — Create branch
4. `/redsub-execute` — TDD implementation from plan
5. `/redsub-validate` — Validation
6. `/redsub-ship minor "feature description"` — Ship it

### "Review my code"
- coderabbit automatically reviews with 40+ static analyzers

### "I need to build a complex feature"
1. `/feature-dev user-authentication` — Structured feature development
2. `/redsub-ship minor "feature description"` — Ship it

### "The plugin seems broken"
```
/redsub-doctor
```

## Removed Skills → Replacements

| Removed Skill | Replacement |
|--------------|-------------|
| /rs-review | coderabbit (automatic) |
| /rs-save | /commit |
| /rs-plan | /redsub-brainstorm → /redsub-plan |
| /redsub-test | /redsub-validate |
| /redsub-design | frontend-design (automatic) |
| /review-pr | coderabbit (automatic) |
| /code-review | coderabbit (automatic) |

## Components

| Type | Count | Details |
|------|-------|---------|
| Skills | 13 | See command reference above |
| Agents | 3 | developer (Opus), planner (Sonnet, read-only), devops (Opus) |
| Hooks | 5 | Workflow orchestrator, main commit guard, auto-format, version check, session end check |
| Rules | 0 | All content moved into skills (on-demand loading) |
| MCP | 0 | Per-project install |

## Architecture

| Layer | Mechanism | Role |
|-------|-----------|------|
| Blocking | **Hooks** | Block direct commits to main (`exit 2`) |
| Procedure | **Skills** | Enforce pipeline order (`/redsub-ship`) |
| Methodology | **superpowers** | TDD, debugging, brainstorming (on-demand) |
| Quality | **coderabbit** | Static analysis-based code review |

## Framework Independent

This plugin is a **workflow engine**. It does not depend on any specific framework.
Framework-specific tools (SvelteKit MCP, Firebase MCP, etc.) are installed per-project as needed.

## License

MIT
