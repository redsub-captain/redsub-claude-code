---
name: redsub-ship
description: Enforced release pipeline. Save → Validate → Review → Version → Merge → Tag → Push.
---

# Release Pipeline

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

## Input

`$ARGUMENTS` provides version type and release description.
Format: `[patch|minor|major] [description]`
Default: `patch` if omitted.

## Semantic Versioning

| Type | Meaning | Example |
|------|---------|---------|
| patch | Bug fix, minor change | 1.0.0 → 1.0.1 |
| minor | New feature (backward compatible) | 1.0.0 → 1.1.0 |
| major | Breaking change | 1.0.0 → 2.0.0 |

## Procedure (enforced order)

### 1. Save

Commit pending changes:
```bash
git add -A
git commit -m "feat: [description]"
```
Skip if no changes.

### 2. Validate (with evidence)

Run with superpowers:verification-before-completion principles.
**Show actual command output as evidence.**

```bash
npm run lint && npm run check && npm run test:unit -- --run
```

**Stop immediately on failure.**

### 3. Review (optional)

Suggest code review before merge:
- `/review-pr` — deep analysis (pr-review-toolkit, 6 agents)
- `/code-review` — automated PR review
- `superpowers:requesting-code-review` — plan-vs-implementation

User may skip.

### 4. Version bump

```bash
npm version [patch|minor|major] --no-git-tag-version
git add package.json
git commit -m "chore: bump version to [new version]"
```

### 5. Merge (user approval required)

```
Validation passed, version [new version]. Merge to main? (y/n)
```

On approval:
```bash
git checkout main
git merge --no-ff [feature-branch] -m "release: v[new version] - [description]"
```

### 6. Tag

```bash
git tag -a v[new version] -m "v[new version] [description]"
```

### 7. Push (user approval required)

```
Push main + tags? (y/n)
```

On approval:
```bash
git push origin main --tags
```

### 8. Release (optional)

```
Create GitHub release? (y/n)
```

On approval:
```bash
gh release create v[new version] --title "v[new version]" --generate-notes
```

## Important

- **All merge/push/release require explicit user approval.**
- Stop immediately if validate fails.
