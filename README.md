[English](README.en.md) | **한국어**

# redsub-claude-code

1인 개발자를 위한 Claude Code **워크플로우 오케스트레이터** 플러그인.

공식 플러그인 12개(superpowers, coderabbit, commit-commands, ralph-loop, frontend-design, feature-dev 등)와 **조합**하여 기획부터 배포까지 전체 개발 사이클을 자동화합니다.

## v3.0 주요 변경

- **Rules 전면 제거** — 세션 시작 토큰 ~96% 절감 (~11,800 → ~500)
- **superpowers 하이브리드** — 핵심 방법론(TDD, 디버깅, 브레인스토밍)은 superpowers에 위임, redsub 스킬은 thin wrapper
- **coderabbit 통합** — 40+ 정적 분석기 기반 AI 코드 리뷰
- **원스텝 설치** — `/redsub-setup` 한 번 실행 = 모든 설정 완료 (사용자 입력 0회)

## 전제 조건

- [Claude Code](https://claude.com/claude-code) v1.0.33 이상
- Node.js (MCP 서버용 `npx` 실행에 필요)

## 설치

### 1. 마켓플레이스 등록

```
/plugin marketplace add redsub-captain/redsub-claude-code
```

### 2. 플러그인 설치

```
/plugin install redsub-claude-code@redsub-plugins
```

### 3. 초기 설정

```
/redsub-setup
```

**한 번의 실행으로 모든 것을 자동 처리:**
- 의존 플러그인 12개 자동 등록
- 권한 패턴 자동 등록
- CLAUDE.md 최소 템플릿 생성/업데이트
- 설치 매니페스트 생성
- 레거시 rules 파일 자동 정리 (v2.x 업그레이드 시)

### 업데이트

세션 시작 시 새 버전이 있으면 자동으로 알림이 표시됩니다.

```
/redsub-update
```

업데이트 후 의존 플러그인이 누락되었다면:
```
/redsub-doctor        # 진단 + 자동 설치
/redsub-setup --force # 또는 전체 재설정
```

### 삭제

```
/redsub-uninstall
```

## 의존 공식 플러그인

`/redsub-setup` 실행 시 아래 12개 플러그인이 자동 등록됩니다:

| 플러그인 | 역할 |
|---------|------|
| superpowers | TDD/브레인스토밍/디버깅/검증 (v4.3.0+) |
| coderabbit | AI 코드 리뷰 (40+ 정적분석기) |
| commit-commands | 커밋/푸시/PR 자동화 (/commit, /commit-push-pr) |
| ralph-loop | 반복 작업 자동화 (TDD, 일괄 수정) |
| frontend-design | UI/UX 구현 가이드 |
| feature-dev | 구조화된 기능 개발 (/feature-dev) |
| code-simplifier | 자율적 코드 간소화 리뷰 |
| context7 | 라이브러리 최신 문서 조회 |
| playwright | E2E 브라우저 테스트 자동화 |
| security-guidance | 보안 모범 사례 |
| claude-md-management | CLAUDE.md 감사 + 세션 학습 |
| claude-code-setup | 프로젝트 분석 → Claude Code 자동화 추천 |

## 워크플로우

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

## 명령어 레퍼런스

### /redsub-start-work [name]

Feature 브랜치를 생성하고 작업을 시작합니다.

```
/redsub-start-work user-authentication
```

### /redsub-brainstorm

소크라틱 대화를 통한 설계 문서 생성. superpowers:brainstorming 기반.

```
/redsub-brainstorm
```

### /redsub-plan

2-5분 단위 구현 계획 생성. superpowers:writing-plans 기반.

```
/redsub-plan
```

### /redsub-execute

계획 기반 태스크 순차 실행 + 서브에이전트 2단계 리뷰. superpowers:executing-plans 기반.

```
/redsub-execute
```

### /redsub-validate

lint + type check + unit test 순차 실행. SSOT 일관성 검증 + 5단계 증거 게이트 포함.

```
/redsub-validate
```

### /redsub-ship [patch|minor|major] [description]

Save → Validate → Review → Version → Merge → Tag → Push 파이프라인을 강제합니다.

```
/redsub-ship minor "사용자 인증 기능 추가"
```

### /redsub-fix-all [pattern]

코드베이스 전체에서 패턴을 검색하여 일괄 수정합니다.

```
/redsub-fix-all "ESLint errors"
```

### /redsub-deploy [dev|prod]

개발계/운영계 배포. 운영계는 사용자 승인 필수.

```
/redsub-deploy dev
/redsub-deploy prod
```

### /redsub-session-save

CLAUDE.md에 진행 상황 저장 + WIP 커밋.

### /redsub-setup

초기 설정 (플러그인/권한 자동 등록, CLAUDE.md 생성).

### /redsub-update

플러그인 자동 업데이트.

### /redsub-doctor

플러그인 상태 진단 + 자동 복구 + 레거시 rules 정리.

### /redsub-uninstall

매니페스트 기반 깔끔한 삭제.

## 시나리오별 가이드

### "새 기능을 만들고 싶어"
1. `/redsub-brainstorm` — 설계 문서 생성
2. `/redsub-plan` — 2-5분 단위 구현 계획
3. `/redsub-start-work feature-name` — 브랜치 생성
4. `/redsub-execute` — 계획 기반 TDD 구현
5. `/redsub-validate` — 검증
6. `/redsub-ship minor "feature description"` — 출시

### "코드 리뷰 해줘"
- coderabbit이 자동으로 40+ 정적분석기 기반 리뷰 수행

### "복잡한 기능을 개발해야 해"
1. `/feature-dev user-authentication` — 구조화된 기능 개발
2. `/redsub-ship minor "기능 설명"` — 출시

### "플러그인이 이상해"
```
/redsub-doctor
```

## 삭제된 스킬 → 대체 안내

| 삭제된 스킬 | 대체 |
|------------|------|
| /rs-review | coderabbit (자동) |
| /rs-save | /commit |
| /rs-plan | /redsub-brainstorm → /redsub-plan |
| /redsub-test | /redsub-validate |
| /redsub-design | frontend-design (자동) |
| /review-pr | coderabbit (자동) |
| /code-review | coderabbit (자동) |

## 구성 요소

| 종류 | 수량 | 내용 |
|------|------|------|
| Skills | 13개 | 위 명령어 레퍼런스 참조 |
| Agents | 3개 | developer (Opus), planner (Sonnet, 읽기 전용), devops (Opus) |
| Hooks | 5개 | 워크플로우 오케스트레이터, main 커밋 차단, 자동 포맷, 버전 체크, 세션 종료 체크 |
| Rules | 0개 | 모든 콘텐츠를 스킬 내부로 이동 (온디맨드 로드) |
| MCP | 0개 | 프로젝트별 설치 |

## 아키텍처

| 계층 | 수단 | 역할 |
|------|------|------|
| 차단 | **Hooks** | main 직접 커밋 차단 (`exit 2`) |
| 절차 | **Skills** | 파이프라인 순서 강제 (`/redsub-ship`) |
| 방법론 | **superpowers** | TDD, 디버깅, 브레인스토밍 (온디맨드) |
| 품질 | **coderabbit** | 정적분석 기반 코드 리뷰 |

## 프레임워크 독립

이 플러그인은 **워크플로우 엔진**입니다. 특정 프레임워크에 의존하지 않습니다.
프레임워크별 도구(SvelteKit MCP, Firebase MCP 등)는 프로젝트 필요에 따라 개별 설치하세요.

## 라이선스

MIT
