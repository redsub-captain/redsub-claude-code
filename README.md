[English](README.en.md) | **한국어**

# redsub-claude-code

1인 개발자를 위한 Claude Code **워크플로우 오케스트레이터** 플러그인.

공식 플러그인 13개(superpowers, code-review, pr-review-toolkit, ralph-loop, frontend-design, feature-dev 등)와 **조합**하여 기획부터 배포까지 전체 개발 사이클을 자동화합니다.

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

이 스킬이 하는 일:
- 의존 공식 플러그인 확인 + 미설치 안내
- Rules 3개를 `~/.claude/rules/`에 배포
- CLAUDE.md 템플릿 생성 (기존 파일 시 마커 기반 추가/건너뛰기 선택)
- 설치 매니페스트 생성 (`~/.claude-redsub/install-manifest.json`)

### 업데이트

세션 시작 시 새 버전이 있으면 자동으로 알림이 표시됩니다.

```
/redsub-update
```

marketplace pull → cache 복사 → registry 업데이트까지 자동으로 처리됩니다. 완료 후 새 세션을 시작하면 적용됩니다.

### 삭제

```
/redsub-uninstall
```

## 의존 공식 플러그인

이 플러그인은 아래 공식 플러그인과 조합하여 동작합니다:

| 플러그인 | 마켓플레이스 | 역할 |
|---------|------------|------|
| superpowers | obra/superpowers-marketplace | TDD, 설계, 계획, 서브에이전트, 코드 리뷰 위임 |
| code-review | claude-plugins-official | PR 자동 리뷰 (GitHub 코멘트 게시) |
| pr-review-toolkit | claude-plugins-official | 6개 전문 리뷰 에이전트 (테스트/타입/보안/간소화 등) |
| ralph-loop | claude-plugins-official | 반복 작업 자동화 (TDD, 일괄 수정) |
| security-guidance | claude-plugins-official | 보안 모범 사례 |
| context7 | claude-plugins-official | 라이브러리 최신 문서 조회 |
| typescript-lsp | claude-plugins-official | TypeScript 실시간 타입 진단 |
| frontend-design | claude-plugins-official | UI/UX 구현 가이드 (Stitch 없이도 사용 가능) |
| feature-dev | claude-plugins-official | 구조화된 기능 개발 (`/feature-dev`) |
| code-simplifier | claude-plugins-official | 자율적 코드 간소화 리뷰 |
| claude-md-management | claude-plugins-official | CLAUDE.md 감사 + 세션 학습 (`/revise-claude-md`) |
| firebase | claude-plugins-official | Firebase MCP (Firestore, Auth, Functions) |
| supabase | claude-plugins-official | Supabase MCP (PostgreSQL, Auth, Storage) |

## 워크플로우

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

## 명령어 레퍼런스

### /redsub-start-work [name]

Feature 브랜치를 생성하고 작업을 시작합니다.

**사용 시점:** 새 작업 시작 시.
```
/redsub-start-work user-authentication
```

### /redsub-test [target]

TDD 자동화. Red-Green-Refactor 사이클을 실행합니다.

**사용 시점:** 새 기능 구현 시 테스트 우선, 버그 수정 시 재현 테스트부터.
```
/redsub-test user-authentication
/redsub-test --team user-authentication  # 모듈별 병렬 TDD (Agent Teams)
```

**ralph-loop 연동 (반복):**
```
/ralph-loop "TDD: user-authentication" --completion-promise "ALL TESTS PASSING" --max-iterations 20
```

### /redsub-validate

lint + type check + unit test를 순차 실행합니다. 증거(명령어 출력) 필수.

**사용 시점:** 코드 변경 후, merge 전 필수.
```
/redsub-validate
```

### /redsub-ship [patch|minor|major] [description]

Save → Validate → Review → Version → Merge → Tag → Push 파이프라인을 강제합니다.

**사용 시점:** 기능 완성 후 main에 통합할 때.
```
/redsub-ship minor "사용자 인증 기능 추가"
```

### /redsub-fix-all [pattern]

코드베이스 전체에서 패턴을 검색하여 일괄 수정합니다. Agent Teams가 활성화되어 있으면 실행 모드를 선택할 수 있습니다.

**사용 시점:** 린트 에러, 네이밍 변경, 패턴 일괄 수정.
```
/redsub-fix-all "ESLint errors"                    # 순차 (기본)
/redsub-fix-all --team "ESLint errors"             # 병렬 (Agent Teams)
```

**ralph-loop 연동:**
```
/ralph-loop "Fix all ESLint errors" --completion-promise "LINT CLEAN" --max-iterations 30
```

### /redsub-deploy [dev|prod]

개발계/운영계 배포. 운영계는 사용자 승인 필수.

**사용 시점:** 배포 시.
```
/redsub-deploy dev     # 개발계 먼저
/redsub-deploy prod    # 운영계 (승인 필수)
```

### /redsub-design [screen]

Stitch MCP를 사용한 UI/UX 화면 설계.

**사용 시점:** 새 화면 설계 시.
```
/redsub-design 대시보드 페이지
```

### /redsub-session-save

CLAUDE.md에 진행 상황 저장 + WIP 커밋.

**사용 시점:** 세션 종료 전.
```
/redsub-session-save
```

### /redsub-setup

초기 설정 (의존 플러그인 확인, Rules 배포, CLAUDE.md 생성).

### /redsub-update

플러그인 자동 업데이트. marketplace pull → cache 복사 → registry 업데이트까지 한 번에 처리.

### /redsub-doctor

플러그인 상태 진단 + 자동 복구.

### /redsub-uninstall

매니페스트 기반 깔끔한 삭제.

## 시나리오별 명령어 매핑

### "새 기능을 만들고 싶어"
1. `/brainstorming` — 설계 문서 생성 (superpowers)
2. `/writing-plans` — 2-5분 단위 구현 계획
3. `/redsub-start-work feature-name` — 브랜치 생성
4. `/redsub-test target` — TDD 구현
5. `/redsub-validate` — 검증
6. `/review-pr` — 리뷰 (6개 전문 에이전트 병렬)
7. `/redsub-ship minor "feature description"` — 출시

### "린트 에러가 100개야"
- `/redsub-fix-all "ESLint errors"` — 순차 전수 수정
- `/redsub-fix-all --team "ESLint errors"` — 병렬 팀 수정 (Agent Teams)
- `/ralph-loop "Fix all ESLint errors" --completion-promise "LINT CLEAN"` — 반복 수정

### "배포하고 싶어"
1. `/redsub-validate` — 사전 검증
2. `/redsub-deploy dev` — 개발계 먼저
3. `/redsub-deploy prod` — 운영계 (사용자 승인 필수)

### "코드 리뷰 해줘"
- PR이 있으면 → `/code-review` (GitHub 코멘트 자동 게시)
- 심층 분석 → `/review-pr` (6개 전문 에이전트 병렬)
- 계획 대비 검증 → superpowers:requesting-code-review

### "복잡한 기능을 개발해야 해"
1. `/feature-dev user-authentication` — 구조화된 기능 개발 시작
2. 자동으로 Agent 팀이 설계 → 구현 → 테스트 단계를 수행
3. `/redsub-ship minor "기능 설명"` — 출시

### "CLAUDE.md를 정리하고 싶어"
```
/revise-claude-md
```
CLAUDE.md 품질 감사 + 세션 중 발견한 패턴/규칙 반영. 세션 종료 전 `/redsub-session-save`가 자동으로 실행합니다.

### "플러그인이 이상해"
```
/redsub-doctor
```
규칙/훅/매니페스트/의존 플러그인 자동 진단 + 복구.

## 삭제된 스킬 → 대체 안내

| 삭제된 스킬 | 대체 명령어 |
|------------|-----------|
| /rs-review | /code-review 또는 /review-pr |
| /rs-save | /commit |
| /rs-plan | /brainstorming → /writing-plans |
| /rs-explore | /brainstorming |
| /rs-status | git status |
| /rs-update-check | /redsub-update |

## 구성 요소

| 종류 | 수량 | 내용 |
|------|------|------|
| Skills | 12개 | 위 명령어 레퍼런스 참조 |
| Agents | 4개 | developer (Opus), planner (Sonnet, 읽기 전용), devops (Opus), designer (Opus, Stitch MCP) |
| Hooks | 9개 | 워크플로우 오케스트레이터, main 커밋/merge 차단 (버전 일치 검증 포함), main 편집 경고, 자동 포맷 + 편집 추적, validate 마커 생성, 버전/플러그인/CLAUDE.md 체크, 데스크톱 알림, 컨텍스트 보존 + 학습 리마인더, 세션 종료 3중 체크 |
| Rules | 3개 | 코드 품질 (보안/DB 통합), 워크플로우 (맥락 자동 감지), 테스트 (TDD Iron Law) |
| MCP | 2개 | stitch (UI/UX 설계), sveltekit (공식 문서) |

## 3단계 방어

| 단계 | 수단 | 역할 | 예시 |
|------|------|------|------|
| 1. 예방 | **Rules** | 파일 패턴별 규칙 자동 주입 | `.ts` 수정 시 TypeScript strict 규칙 자동 로드 |
| 2. 차단 | **Hooks** | 위험 행동 물리적 차단 | main 직접 커밋 시 `exit 2`로 차단 |
| 3. 절차 | **Skills** | 파이프라인 순서 강제 | `/redsub-ship`이 Save→Validate→Merge 순서 강제 |

## 기술 스택

SvelteKit 5 / Firebase / TypeScript / Supabase / Cloudflare Pages / Tailwind CSS 4

다른 스택에서 사용하려면 rules, agents, skills의 내용을 수정하세요.

## 환경 변수

| 변수 | 용도 | 필수 여부 |
|------|------|----------|
| `STITCH_API_KEY` | Google Stitch MCP (`/redsub-design` 스킬) | 선택 |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Agent Teams 병렬 실행 (`/redsub-fix-all`, `/redsub-test`) | 선택 |

### Stitch API Key 설정 (선택)

`/redsub-design` 스킬로 UI/UX 화면을 설계하려면 Stitch API 키가 필요합니다. Stitch 없이도 **frontend-design** 플러그인으로 UI 구현 가이드를 받을 수 있으므로, 화면 디자인 생성이 필요하지 않다면 건너뛰어도 됩니다.

`/redsub-setup`을 실행하면 API 키 입력과 저장을 자동으로 처리합니다.

수동 설정이 필요한 경우:
1. [stitch.withgoogle.com/settings](https://stitch.withgoogle.com/settings)에서 API 키 생성
2. `~/.claude/settings.json`의 `env` 섹션에 추가:
   ```json
   {
     "env": {
       "STITCH_API_KEY": "your-api-key-here"
     }
   }
   ```
3. Claude Code 새 세션 시작

## 라이선스

MIT
