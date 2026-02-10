[English](README.en.md) | **한국어**

# redsub-claude-code

기획부터 배포까지, 1인 개발자의 전체 개발 워크플로우를 자동화하는 [Claude Code](https://claude.com/claude-code) 플러그인입니다.

계획 수립 → 브랜치 생성 → 코딩 → TDD → 코드 리뷰 → 출시 → 배포까지의 과정을 스킬, 에이전트, 훅으로 구조화하고, 규칙 위반을 물리적으로 차단합니다.

## 전제 조건

- [Claude Code](https://claude.com/claude-code) v1.0.33 이상
- Node.js (MCP 서버용 `npx` 실행에 필요)

## 설치

### 1. 마켓플레이스 등록

Claude Code 안에서 실행합니다:

```
/plugin marketplace add redsub-captain/redsub-claude-code
```

### 2. 플러그인 설치

```
/plugin install redsub-claude-code@redsub-plugins
```

### 3. 초기 설정

```
/redsub-claude-code:rs-setup
```

이 스킬이 하는 일:
- Rules 5개를 `~/.claude/rules/`에 배포
- CLAUDE.md 템플릿을 프로젝트 루트에 생성
- TypeScript LSP 의존성 확인
- 환경변수 확인 (`STITCH_API_KEY`)

## 워크플로우

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

> 모든 스킬은 `rs-` 접두사를 사용합니다.
> 예: `/rs-plan`, `/rs-validate` (전체 이름: `/redsub-claude-code:rs-plan`)

| 단계 | 스킬 | 설명 |
|------|------|------|
| 관리 | `/rs-setup` | 초기 설정 (rules 배포, CLAUDE.md 생성) |
| 계획 | `/rs-plan` | 코드베이스 탐색 후 작업 계획 수립 (planner 에이전트) |
| 시작 | `/rs-start-work` | feature 브랜치 생성 |
| 개발 | `/rs-save` | WIP 커밋 |
| | `/rs-explore` | 코드베이스 아키텍처 탐색 (planner 에이전트) |
| | `/rs-fix-all` | 패턴을 코드베이스 전체에서 검색하여 일괄 수정 |
| 디자인 | `/rs-design` | Stitch MCP로 UI/UX 화면 설계 (designer 에이전트) |
| 테스트 | `/rs-test` | TDD: 테스트 작성 → 실패 확인 → 구현 → 통과 (developer 에이전트) |
| 검증 | `/rs-validate` | `npm run lint && npm run check && npm run test:unit` |
| 리뷰 | `/rs-review` | 보안/타입/성능/DB/테스트 관점 코드 리뷰 (reviewer 에이전트) |
| 출시 | `/rs-ship` | Save → Validate → Merge 순서 강제 |
| 배포 | `/rs-deploy` | 개발계 → 동작 확인 → 사용자 승인 → 운영계 |
| 상태 | `/rs-status` | git 상태, 최근 커밋, 미완료 작업 요약 |
| 세션 | `/rs-session-save` | CLAUDE.md에 진행 상황 저장 + WIP 커밋 |
| 유지 | `/rs-update-check` | Claude Code 업데이트 시 플러그인 호환성 분석 |

## 구성 요소

| 종류 | 수량 | 내용 |
|------|------|------|
| Skills | 15개 | 위 워크플로우 테이블 참조 |
| Agents | 5개 | developer (Opus), reviewer (Sonnet, 읽기 전용), planner (Sonnet, 읽기 전용), devops (Opus), designer (Opus, Stitch MCP) |
| Hooks | 7개 | main 커밋 차단, merge 전 validate 검증, 자동 포맷, 버전 체크, 데스크톱 알림, 컨텍스트 보존, 세션 종료 확인 |
| Rules | 5개 | 코드 품질, 데이터베이스, 보안, 워크플로우, 테스트 |
| MCP | 3개 | context7 (라이브러리 문서), stitch (UI/UX 설계), sveltekit (공식 문서) |
| LSP | 1개 | TypeScript (실시간 타입 에러 진단) |

## 3단계 방어 (MECE 자동화)

MECE(Mutually Exclusive, Collectively Exhaustive) — 빠짐없이, 겹침 없이 모든 케이스를 커버하는 원칙.

CLAUDE.md에 "~하지 마세요"라고 써놓는 것만으로는 Claude가 규칙을 어길 수 있습니다. 이 플러그인은 3단계로 **물리적으로** 강제합니다:

| 단계 | 수단 | 역할 | 예시 |
|------|------|------|------|
| 1. 예방 | **Rules** | 파일 패턴별 규칙 자동 주입 | `.ts` 파일 수정 시 TypeScript strict 규칙 자동 로드 |
| 2. 차단 | **Hooks** | 위험 행동 물리적 차단 | main 브랜치 직접 커밋 시 `exit 2`로 차단 |
| 3. 절차 | **Skills** | 서브에이전트로 격리 실행 | `/rs-ship`이 Save→Validate→Merge 순서 강제 |

## 기술 스택

이 플러그인은 아래 기술 스택을 전제로 설계되었습니다:

SvelteKit 5 / Firebase / TypeScript / Supabase / Cloudflare Pages / Tailwind CSS 4

다른 스택에서 사용하려면 rules, agents, skills의 내용을 수정하세요.

## 환경 변수

| 변수 | 용도 | 필수 여부 |
|------|------|----------|
| `STITCH_API_KEY` | Google Stitch MCP (`:design` 스킬에서 UI/UX 화면 설계) | 선택 (없으면 `:design` 스킬만 사용 불가) |

## 라이선스

MIT
