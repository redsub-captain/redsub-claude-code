---
name: ship
description: Save → Validate → Merge to main 순서 실행.
disable-model-invocation: true
argument-hint: "[description]"
---

# 출시 파이프라인

## 입력

`$ARGUMENTS`로 출시 설명을 받습니다.

## 절차 (순서 강제)

### 1. Save

변경사항을 커밋합니다:
```bash
git add -A
git commit -m "feat: $ARGUMENTS"
```

변경이 없으면 이 단계를 건너뜁니다.

### 2. Validate

코드 검증을 실행합니다:
```bash
npm run lint && npm run check && npm run test:unit -- --run
```

**실패 시 즉시 중단합니다.** merge를 진행하지 않습니다.

### 3. Merge

사용자에게 확인을 받은 후에만 merge합니다:
```
validate 통과. main에 merge하시겠습니까? (y/n)
```

사용자가 승인하면:
```bash
git checkout main
git merge --no-ff [feature-branch]
```

### 주의사항

- **사용자 확인 없이 main merge/push 절대 금지.**
- validate 실패 시 merge 단계로 진행하지 않습니다.
- push는 사용자가 별도로 지시해야 합니다.
- 이 스킬은 `disable-model-invocation: true`로 수동 호출만 가능합니다.
