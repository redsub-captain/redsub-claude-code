# redsub-claude-code

1인 개발자를 위한 Claude Code 워크플로우 플러그인.

## 설치

```bash
claude plugin install ./redsub-claude-code
```

설치 후 초기 설정:

```
/redsub-claude-code:setup
```

## 워크플로우

```
Plan → Start → Code → Test → Review → Ship → Deploy
```

| 단계 | 스킬 | 설명 |
|------|------|------|
| 관리 | `/setup` | 초기 설정 (rules 배포, CLAUDE.md 생성) |
| 계획 | `/plan` | 작업 계획 수립 |
| 시작 | `/start-work` | feature 브랜치 생성 |
| 개발 | `/save`, `/explore`, `/fix-all` | WIP 커밋, 코드베이스 탐색, 패턴 일괄 수정 |
| 디자인 | `/design` | Stitch MCP로 UI/UX 화면 설계 |
| 테스트 | `/test` | TDD 자동화 |
| 검증 | `/validate` | lint + type check + unit test |
| 리뷰 | `/review` | 코드 리뷰 (보안/타입/성능/DB/테스트) |
| 출시 | `/ship` | Save → Validate → Merge |
| 배포 | `/deploy` | 개발계/운영계 배포 |
| 상태 | `/status` | 프로젝트 현황 |
| 세션 | `/session-save` | 컨텍스트 저장 |
| 유지 | `/update-check` | Claude Code 업데이트 호환성 확인 |

## MECE 자동화

3단계 방어로 워크플로우를 물리적으로 강제합니다:

1. **Rules** — 파일 패턴별 규칙 자동 주입 (`paths:` 조건부 로드)
2. **Hooks** — 위험 행동 물리적 차단 (`exit 2` + LLM 기반 검증)
3. **Skills** — 서브에이전트로 격리 실행, 절차 강제

## 기술 스택

SvelteKit 5 / Firebase / TypeScript / Supabase / Cloudflare Pages / Tailwind CSS 4

## 환경 변수

| 변수 | 용도 |
|------|------|
| `STITCH_API_KEY` | Google Stitch MCP (UI/UX 디자인) |

## 디바이스 간 동기화

```bash
# 변경 후: git commit && git push
# 다른 디바이스: git pull
```

## 라이선스

MIT
