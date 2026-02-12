# Compatibility Matrix

redsub-claude-code와 Claude Code 버전 간 호환성.

## Current

| Component | Version |
|-----------|---------|
| Plugin | 2.11.1 |
| Min Claude Code | 1.0.33 |

## History

| Plugin | Min Claude Code | Notes |
|--------|-----------------|-------|
| 2.x | 1.0.33 | Current |
| 1.x | 1.0.0 | Legacy |

## Breaking Changes

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
