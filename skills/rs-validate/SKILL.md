---
name: rs-validate
description: lint, type check, unit test 실행.
disable-model-invocation: true
---

# 코드 검증

> **언어**: `~/.claude-redsub/language` 파일의 설정(ko/en)에 맞춰 모든 출력을 해당 언어로 작성하세요. 파일이 없으면 `en`을 기본값으로 사용합니다.

## 절차

### 1. 린트

```bash
npm run lint
```

### 2. 타입 체크

```bash
npm run check
```

### 3. 단위 테스트

```bash
npm run test:unit -- --run
```

### 4. 결과

모든 단계를 순차 실행합니다. 하나라도 실패하면 즉시 중단하고 오류를 보고합니다.

**전체 성공 시:**
```
✅ Validation passed
- lint: pass
- type check: pass
- unit test: pass
```

마커 파일이 PostToolUse 훅에 의해 자동 생성됩니다 (`/tmp/.claude-redsub-validated`).
이 마커는 `/rs-ship` 스킬의 merge 단계에서 참조됩니다.

**실패 시:**
```
❌ Validation failed
- [failed step]: [error]
- Fix: [suggestion]
```

> 위 구조를 유지하되, 사용자 언어 설정에 맞춰 작성하세요.
