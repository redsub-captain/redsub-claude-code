---
name: redsub-ship
description: Enforced release pipeline. Save → Validate → Review → Version → Merge → Tag → Push.
---

# Release Pipeline

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

## Commit Convention

### Format
```
type: description
```
- **type**: Conventional Commits keyword (English)
- **description**: concise summary, imperative mood, max 50 chars

### Types

| Type | Meaning | Example |
|------|---------|---------|
| `feat` | New feature | `feat: add user authentication API` |
| `fix` | Bug fix | `fix: handle null pointer exception` |
| `refactor` | Refactoring (no behavior change) | `refactor: restructure auth module` |
| `chore` | Build, config, version, etc. | `chore: update dependencies` |
| `docs` | Documentation | `docs: improve README install guide` |
| `test` | Tests | `test: add login failure test cases` |

### Release Formats

| Step | Format | Example |
|------|--------|---------|
| Version bump | `chore: bump version to X.Y.Z` | `chore: bump version to 2.12.0` |
| Merge | `release: vX.Y.Z - description` | `release: v2.12.0 - add auth module` |
| Tag | `vX.Y.Z description` (no type prefix) | `v2.12.0 add auth module` |

## Command Resolution

Determine the project's commands:
1. Check project CLAUDE.md for explicit commands (lint, check, test, version)
2. If not found, read `package.json` scripts and infer
3. Detect package manager: look for lock files (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, default → npm)
4. If ambiguous, ask the user

## Procedure (enforced order)

### 1. Save

Commit pending changes (following commit convention):
```bash
git add -A
git commit -m "feat: description"
```
- Choose type based on change nature: `feat`, `fix`, `refactor`, etc.
- e.g., `feat: add commit convention guide`, `fix: fix session save error`

Skip if no changes.

### 2. Validate (with evidence)

Run with Verification Gate principles.
**Show actual command output as evidence.**

Run resolved lint, check, and test commands sequentially.

**Stop immediately on failure.**

### 3. Review (optional)

Suggest code review before merge:
- `/superpowers:requesting-code-review` — code review

User may skip.

### 4. Version bump

Update **all 3 version files** (package.json, plugin.json, marketplace.json):

```bash
<package-manager> version [patch|minor|major] --no-git-tag-version
```

Read the new version from `package.json`, then update the other 2 files to match:

```bash
# Read new version
NEW_VER=$(node -p "require('./package.json').version")

# Sync plugin.json
python3 -c "
import json
with open('.claude-plugin/plugin.json','r') as f: d=json.load(f)
d['version']='$NEW_VER'
with open('.claude-plugin/plugin.json','w') as f: json.dump(d,f,indent=2,ensure_ascii=False); f.write('\n')
"

# Sync marketplace.json
python3 -c "
import json
with open('.claude-plugin/marketplace.json','r') as f: d=json.load(f)
d['plugins'][0]['version']='$NEW_VER'
with open('.claude-plugin/marketplace.json','w') as f: json.dump(d,f,indent=2,ensure_ascii=False); f.write('\n')
"

git add package.json .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

#### Sync COMPATIBILITY.md

Update the Plugin version in the "Current" table:

```bash
sed -i '' "s/| Plugin | [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* |/| Plugin | $NEW_VER |/" COMPATIBILITY.md
git add COMPATIBILITY.md
```

#### Sync template version

Update the version comment in `templates/CLAUDE.md.template`:

```bash
sed -i '' "s/<!-- redsub-template-version:.* -->/<!-- redsub-template-version:$NEW_VER -->/" templates/CLAUDE.md.template
git add templates/CLAUDE.md.template
```

```bash
git commit -m "chore: bump version to $NEW_VER"
```

### 5. Merge (user approval required)

Use `AskUserQuestion` tool to get approval:
- question: "v[new version] merge to main?"
- header: "Merge"
- options: ["Merge" (merge and continue), "Skip" (stop pipeline)]

On "Merge":
```bash
git checkout main
git merge --no-ff [feature-branch] -m "release: v[new version] - [description]"
```

### 6. Tag

```bash
git tag -a v[new version] -m "v[new version] [description — no type prefix]"
```
- e.g., `v2.10.0 add commit convention guide` (OK)
- NOT: `v2.10.0 feat: add commit convention guide` (redundant type prefix)

### 7. Push + Release (user approval required)

Use `AskUserQuestion` tool to get approval:
- question: "Push main + tags to remote?"
- header: "Push"
- options: ["Push only" (push, no release), "Push + Release" (push and create GitHub release), "Skip" (no push)]

On "Push only":
```bash
git push origin main --tags
```

On "Push + Release":
```bash
git push origin main --tags
gh release create v[new version] --title "v[new version]" --notes-from-tag
```

## Important

- **All merge/push/release require explicit user approval via AskUserQuestion.**
- Stop immediately if validate fails.
