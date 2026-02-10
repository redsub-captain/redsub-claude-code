---
name: rs-ship
description: Save → Validate → Version → Merge → Tag → Push → Release 순서 실행.
disable-model-invocation: true
argument-hint: "[patch|minor|major] [description]"
---

# 출시 파이프라인

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 입력

`$ARGUMENTS`로 버전 타입과 출시 설명을 받습니다.

형식: `[patch|minor|major] [설명]`
예시: `minor 사용자 프로필 기능 추가`

버전 타입 생략 시 `patch`를 기본값으로 사용합니다.

## Semantic Versioning

| 타입 | 의미 | 예시 |
|------|------|------|
| patch | 버그 수정, 사소한 변경 | 1.0.0 → 1.0.1 |
| minor | 새 기능 (하위 호환) | 1.0.0 → 1.1.0 |
| major | 호환성 깨지는 변경 | 1.0.0 → 2.0.0 |

## 절차 (순서 강제)

### 1. Save

변경사항을 커밋합니다:
```bash
git add -A
git commit -m "feat: [설명]"
```

변경이 없으면 이 단계를 건너뜁니다.

### 2. Validate

코드 검증을 실행합니다:
```bash
npm run lint && npm run check && npm run test:unit -- --run
```

**실패 시 즉시 중단합니다.** 이후 단계를 진행하지 않습니다.

### 3. Version Bump

`package.json`의 `version` 필드를 업데이트합니다:
```bash
npm version [patch|minor|major] --no-git-tag-version
git add package.json
git commit -m "chore: bump version to [새 버전]"
```

### 4. Merge

사용자에게 확인을 받은 후에만 merge합니다. 사용자 언어에 맞춰 확인 메시지를 작성합니다:
```
Validation passed, version [new version]. Merge to main? (y/n)
```

사용자가 승인하면:
```bash
git checkout main
git merge --no-ff [feature-branch] -m "release: v[새 버전] - [설명]"
```

### 5. Tag

```bash
git tag -a v[새 버전] -m "v[새 버전] [설명]"
```

### 6. Push

사용자에게 push 확인을 받습니다 (사용자 언어에 맞춰):
```
Push main + tags? (y/n)
```

승인 시:
```bash
git push origin main --tags
```

### 7. Release (선택)

GitHub 릴리즈 생성 여부를 확인합니다 (사용자 언어에 맞춰):
```
Create GitHub release? (y/n)
```

승인 시:
```bash
gh release create v[새 버전] --title "v[새 버전]" --generate-notes
```

## 주의사항

- **모든 merge/push/release는 사용자 승인 필수.**
- validate 실패 시 이후 단계로 진행하지 않습니다.
- 이 스킬은 `disable-model-invocation: true`로 수동 호출만 가능합니다.
