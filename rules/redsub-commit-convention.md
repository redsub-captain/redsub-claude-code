# Commit Convention

커밋 메시지와 릴리즈 태그의 형식 규칙.

## 기본 형식

```
type: 한국어 설명
```

- **type**: 영어 고정 (Conventional Commits 스펙).
- **설명**: 한국어. 간결하고 명확하게.

## Type 목록

| Type | 의미 | 예시 |
|------|------|------|
| `feat` | 새 기능 | `feat: 사용자 인증 API 추가` |
| `fix` | 버그 수정 | `fix: null 포인터 예외 처리` |
| `refactor` | 리팩토링 (동작 변경 없음) | `refactor: 인증 모듈 구조 개선` |
| `chore` | 빌드, 설정, 버전 등 잡일 | `chore: 의존성 업데이트` |
| `docs` | 문서 | `docs: README 설치 가이드 보완` |
| `test` | 테스트 | `test: 로그인 실패 케이스 추가` |

## 설명 문체

- **서술형 종결**: "~추가", "~수정", "~개선", "~제거".
- **간결하게**: 50자 이내 권장. 핵심만.
- **무엇을 했는지**: "왜"는 커밋 본문에.
- **기술 용어**: API, plugin, hook 등 확립된 영문 기술 용어는 그대로 사용.

```
# 좋은 예
feat: 사용자 프로필 이미지 업로드 추가
fix: 로그인 시 세션 만료 오류 수정
refactor: API 클라이언트 에러 처리 통합

# 나쁜 예
feat: add user profile image upload  ← 영어 설명
fix: 버그 수정                         ← 너무 모호
feat: 사용자가 프로필에서 이미지를 업로드할 수 있도록 기능을 구현했습니다  ← 너무 장황
```

## 커밋 본문 (선택)

복잡한 변경은 빈 줄 후 한국어 본문 추가:

```
refactor: 인증 모듈 구조 개선

- JWT 검증 로직을 미들웨어로 분리
- 토큰 갱신 로직 중복 제거
- 에러 코드 상수화
```

## 릴리즈 전용 형식 (redsub-ship)

`/redsub-ship`이 생성하는 커밋과 태그:

| 단계 | 형식 | 예시 |
|------|------|------|
| Save | `type: 한국어 설명` | `feat: 커밋 컨벤션 가이드 추가` |
| Version bump | `chore: bump version to X.Y.Z` | `chore: bump version to 2.10.0` |
| Merge | `release: vX.Y.Z - 한국어 설명` | `release: v2.10.0 - 커밋 컨벤션 가이드 추가` |
| Tag | `vX.Y.Z 한국어 설명` | `v2.10.0 커밋 컨벤션 가이드 추가` |

- **Version bump**: 유일한 영어 고정 형식. 자동화 스크립트 호환성.
- **Tag 설명에 type prefix 금지**: `v2.4.1 fix: 뭔가 수정` ← 이러면 안 됨.

## 예외

| 형식 | 설명 | 생성자 |
|------|------|--------|
| `wip: session save` | 세션 저장 고정 포맷. 번역 불필요. | /redsub-session-save |
| `chore: bump version to X.Y.Z` | 버전 업데이트 고정 포맷 (영어). | /redsub-ship |

## 안티패턴

| 잘못된 예 | 문제 | 올바른 예 |
|-----------|------|-----------|
| `feat: add /redsub-brainstorm skill` | 영어 설명 | `feat: 브레인스토밍 스킬 추가` |
| `refactor: remove Stitch/designer dependencies` | 영어 설명 | `refactor: Stitch/designer 의존성 제거` |
| `v2.4.1 fix: release notes 수정` | 태그에 type prefix | `v2.4.1 release notes 수정` |
| `fix: 버그 수정` | 모호한 설명 | `fix: 로그인 세션 만료 오류 수정` |
