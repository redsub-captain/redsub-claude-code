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
type: 한국어 설명
```
- **type**: 영어 고정 (Conventional Commits)
- **설명**: 한국어, 서술형 종결 (~추가, ~수정, ~개선, ~제거), 50자 이내

### Types

| Type | 의미 | 예시 |
|------|------|------|
| `feat` | 새 기능 | `feat: 사용자 인증 API 추가` |
| `fix` | 버그 수정 | `fix: null 포인터 예외 처리` |
| `refactor` | 리팩토링 (동작 변경 없음) | `refactor: 인증 모듈 구조 개선` |
| `chore` | 빌드, 설정, 버전 등 잡일 | `chore: 의존성 업데이트` |
| `docs` | 문서 | `docs: README 설치 가이드 보완` |
| `test` | 테스트 | `test: 로그인 실패 케이스 추가` |

### Release Formats

| Step | Format | Example |
|------|--------|---------|
| Version bump | `chore: bump version to X.Y.Z` | `chore: bump version to 2.12.0` |
| Merge | `release: vX.Y.Z - 한국어 설명` | `release: v2.12.0 - 인증 모듈 추가` |
| Tag | `vX.Y.Z 한국어 설명` (type prefix 없이) | `v2.12.0 인증 모듈 추가` |

## Command Resolution

Determine the project's commands:
1. Check project CLAUDE.md for explicit commands (lint, check, test, version)
2. If not found, read `package.json` scripts and infer
3. Detect package manager: look for lock files (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, default → npm)
4. If ambiguous, ask the user

## Procedure (enforced order)

### 1. Save

Commit pending changes (커밋 컨벤션 따름):
```bash
git add -A
git commit -m "feat: 한국어 설명"
```
- type은 변경 성격에 맞게: `feat`, `fix`, `refactor` 등.
- 예: `feat: 커밋 컨벤션 가이드 추가`, `fix: 세션 저장 오류 수정`

Skip if no changes.

### 2. Validate (with evidence)

Run with Verification Gate principles.
**Show actual command output as evidence.**

Run resolved lint, check, and test commands sequentially.

**Stop immediately on failure.**

### 3. Review (optional)

Suggest code review before merge:
- `/coderabbit:review` — automated code review (coderabbit)

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
git merge --no-ff [feature-branch] -m "release: v[new version] - [한국어 설명]"
```

### 6. Tag

```bash
git tag -a v[new version] -m "v[new version] [한국어 설명 — type prefix 없이]"
```
- 예: `v2.10.0 커밋 컨벤션 가이드 추가` (O)
- 아닌 예: `v2.10.0 feat: 커밋 컨벤션 가이드 추가` (X — type prefix 중복)

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
