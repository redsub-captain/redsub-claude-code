---
name: redsub-deploy
description: Deployment workflow for dev/prod environments.
---

# Deployment

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

## Input

`$ARGUMENTS`: `dev` or `prod`.

## Dev deployment

1. Deploy current branch to dev environment.
2. Use deploy commands from CLAUDE.md or package.json scripts.
3. Guide user to verify functionality.

## Prod deployment (safety enforced)

### 1. Pre-checks
- Verify on `main` branch
- Verify validate marker exists

### 2. Dev confirmation
Ask: "Have you tested on dev environment?"

### 3. User approval
Ask: "Deploy to PRODUCTION? (y/n)"

### 4. Execute
Only after approval. Use project-specific deploy commands.
- Cloudflare Pages: `npx wrangler pages deploy`
- Firebase Hosting: `firebase deploy --only hosting`

### 5. Verify deployment status.

## Important
- **Prod deployment ALWAYS requires explicit user approval.**
- Warn if deploying to prod without prior dev testing.
