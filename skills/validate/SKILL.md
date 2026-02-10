---
name: validate
description: lint, type check, unit test 실행.
disable-model-invocation: true
---

# 코드 검증

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
✅ 검증 통과
- lint: 통과
- type check: 통과
- unit test: 통과
```

마커 파일이 PostToolUse 훅에 의해 자동 생성됩니다 (`/tmp/.claude-redsub-validated`).
이 마커는 `/ship` 스킬의 merge 단계에서 참조됩니다.

**실패 시:**
```
❌ 검증 실패
- [실패한 단계]: [오류 내용]
- 수정 방안: [제안]
```
