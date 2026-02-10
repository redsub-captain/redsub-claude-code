---
name: deploy
description: 개발계/운영계 배포. 필수 흐름 강제.
disable-model-invocation: true
argument-hint: "[dev|prod]"
---

# 배포 워크플로우

## 입력

`$ARGUMENTS`로 배포 환경을 받습니다: `dev` 또는 `prod`.

## 필수 흐름

### dev (개발계)

1. 현재 브랜치의 코드를 개발 환경에 배포합니다.
2. 배포 명령은 프로젝트의 CLAUDE.md 또는 package.json scripts에 정의된 것을 사용합니다.
3. 배포 후 동작 확인을 안내합니다.

### prod (운영계)

**안전 절차 강제:**

1. **사전 확인**: main 브랜치인지, validate를 통과했는지 확인합니다.
2. **개발계 배포 확인**: "개발계에서 테스트했습니까?" 확인합니다.
3. **사용자 승인**: "운영계에 배포하시겠습니까?" 명시적 승인을 받습니다.
4. **배포 실행**: 승인 후에만 배포를 실행합니다.
5. **결과 확인**: 배포 후 상태를 확인합니다.

## 배포 명령

프로젝트별로 다릅니다. 프로젝트 CLAUDE.md에서 배포 명령을 참조하세요.

일반적인 예시:
- Cloudflare Pages: `npx wrangler pages deploy`
- Firebase Hosting: `firebase deploy --only hosting`

## 주의사항

- **운영계 직접 배포는 반드시 사용자 승인 필요.**
- 개발계를 거치지 않는 운영계 배포는 경고합니다.
- 이 스킬은 `disable-model-invocation: true`로 수동 호출만 가능합니다.
