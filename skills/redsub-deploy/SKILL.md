---
name: redsub-deploy
description: Deployment workflow for dev/prod environments.
---

# Deployment

## Input

`$ARGUMENTS`: `dev` or `prod`.

## Command Resolution

Determine the project's deploy commands:
1. Check project CLAUDE.md for explicit deploy commands
2. If not found, read `package.json` scripts for deploy-related scripts (e.g., `deploy`, `deploy:dev`, `deploy:prod`)
3. If ambiguous, ask the user

## Dev deployment

1. Deploy current branch to dev environment.
2. Use resolved deploy commands.
3. Guide user to verify functionality.

## Prod deployment (safety enforced)

### 1. Pre-checks
- Verify on `main` branch
- Run `/redsub-validate` if not already validated in this session

### 2. Dev confirmation
Use `AskUserQuestion` tool:
- question: "Dev 환경에서 테스트를 완료했나요?"
- header: "Dev test"
- options: ["Yes, tested" (proceed to next step), "No, skip" (warn and continue)]

### 3. User approval
Use `AskUserQuestion` tool:
- question: "PRODUCTION에 배포하시겠습니까?"
- header: "Deploy"
- options: ["Deploy to prod" (execute deployment), "Cancel" (stop pipeline)]

### 4. Execute
Only after approval. Use resolved deploy commands.

### 5. Verify deployment status.

## Important
- **Prod deployment ALWAYS requires explicit user approval.**
- Warn if deploying to prod without prior dev testing.
