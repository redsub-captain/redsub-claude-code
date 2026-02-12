# Compatibility Matrix

redsub-claude-code와 Claude Code 버전 간 호환성.

## Current

| Component | Version |
|-----------|---------|
| Plugin | 2.8.0 |
| Min Claude Code | 1.0.33 |

## History

| Plugin | Min Claude Code | Notes |
|--------|-----------------|-------|
| 2.x | 1.0.33 | Current |
| 1.x | 1.0.0 | Legacy |

## Breaking Changes

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
