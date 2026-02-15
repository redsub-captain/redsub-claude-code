# Compatibility Matrix

redsub-claude-code와 Claude Code 버전 간 호환성.

## Current

| Component | Version |
|-----------|---------|
| Plugin | 3.3.0 |
| Min Claude Code | 1.0.33 |

## History

| Plugin | Min Claude Code | Notes |
|--------|-----------------|-------|
| 3.x | 1.0.33 | Current |
| 2.x | 1.0.33 | Legacy |
| 1.x | 1.0.0 | Legacy |

## Breaking Changes

### 3.2.0
- **coderabbit 의존성 제거**: 코드 리뷰를 `superpowers:requesting-code-review`로 대체 (12개 → 11개)
- **플러그인 업데이트 알림**: 세션 시작 시 claude-plugins-official 업데이트 자동 확인

### 3.0.0
- **Rules 전면 제거**: 5개 Rules 파일 삭제 → 고유 콘텐츠를 관련 스킬 내부로 이동
  - `redsub-testing.md` → `/redsub-validate` SKILL.md
  - `redsub-commit-convention.md` → `/redsub-ship` SKILL.md
  - `redsub-code-quality.md` → `/redsub-fix-all` SKILL.md
  - `redsub-workflow.md` → `workflow-orchestrator.sh` (기존)
  - `redsub-claude-code-practices.md` → `/redsub-validate` SKILL.md
- **superpowers 하이브리드 복원**: v2.8.0에서 내재화했던 superpowers를 의존성으로 복원
  - `/redsub-brainstorm` → superpowers:brainstorming 기반 thin wrapper
  - `/redsub-plan` → superpowers:writing-plans 기반 thin wrapper
  - `/redsub-execute` → superpowers:executing-plans 기반 thin wrapper
- **의존 플러그인 변경**: code-review, pr-review-toolkit 제거 → superpowers 추가 (12개)
- **Hooks 축소**: 9개 → 5개 (warn-main-edit, validate-marker, notify-attention, pre-compact-context 제거)
- **CLAUDE.md 최소화**: ~60줄 → ~15줄 템플릿 (세션 시작 토큰 ~96% 절감)
- **원스텝 설치**: `/redsub-setup` 실행 시 사용자 입력 0회 (플러그인/권한 자동 등록)
- **삭제된 스크립트**: warn-main-edit.sh, validate-marker.sh, notify-attention.sh, pre-compact-context.sh
- **업그레이드**: v2.x에서 업그레이드 시 `/redsub-doctor`로 레거시 rules 파일 자동 정리

### 2.9.0
- designer agent 제거 → frontend-design 플러그인 사용
- `/redsub-design` 스킬 제거 → frontend-design 플러그인 사용
- design-guide template 제거 (프로젝트별 관리)
- Stitch MCP 의존성 완전 제거 (프로젝트 레벨로 이동)
- CLAUDE.md 템플릿: 제목 변경, Tech Stack 섹션 제거, Cost 원칙 확대
- completion-check.sh Stop hook 버그 수정 (pipefail + svelte-count 불일치)

### 2.8.0
- superpowers 의존성 제거 (내재화)
- 신규 스킬: `/redsub-brainstorm`, `/redsub-plan`, `/redsub-execute`
- 신규 의존: `claude-code-setup`, `commit-commands`
- "커밋해" 매핑 변경: `git add + git commit` → `/commit` (commit-commands)
- `/brainstorming` → `/redsub-brainstorm`, `/writing-plans` → `/redsub-plan`

### 2.0.0
- Skill prefix: `/rs-*` → `/redsub-*`
- context7 → official plugin으로 이동
- reviewer agent 제거 (pr-review-toolkit 사용)

## Changelog

→ [GitHub Releases](https://github.com/redsub-captain/redsub-claude-code/releases)
