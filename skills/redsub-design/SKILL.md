---
name: redsub-design
description: UI/UX screen design via Stitch MCP.
---

# UI/UX Design

## Prerequisites

Check if `STITCH_API_KEY` is configured:

```bash
echo "${STITCH_API_KEY:+configured}"
```

- **If set** → Stitch 워크플로우 (Steps 1-5)
- **If NOT set** → use `AskUserQuestion` tool:
  - question: "Stitch API key가 설정되지 않았습니다. 어떻게 하시겠습니까?"
  - header: "Stitch API"
  - options: ["Set up now" (run /redsub-setup --force to configure), "Use frontend-design" (no API key needed, frontend-design plugin will handle UI work)]

  If user chooses "Use frontend-design" → Fallback 워크플로우로 전환.

## Input

`$ARGUMENTS`: screen description.

## Stitch 워크플로우 (STITCH_API_KEY 있을 때)

### 1. Stitch 프로젝트 확인

- `mcp__stitch__list_projects` → 기존 프로젝트 확인
- 없으면 `mcp__stitch__create_project` (프로젝트명 = 앱 이름)

### 2. 스크린 디자인

- `mcp__stitch__generate_screen_from_text` — 새 스크린 생성
  - deviceType: `DESKTOP` (기본), `MOBILE` if specified
  - modelId: `GEMINI_3_PRO` (기본)
- `mcp__stitch__get_screen` — 생성된 스크린 확인 및 리뷰
- 필요 시 `mcp__stitch__generate_variants` — 변형 탐색
  - variantCount: 1-5 (기본 3)
  - creativeRange: `REFINE` (미세조정) / `EXPLORE` (탐색, 기본) / `REIMAGINE` (재창조)
  - aspects: `LAYOUT`, `COLOR_SCHEME`, `IMAGES`, `TEXT_FONT`, `TEXT_CONTENT`
- 필요 시 `mcp__stitch__edit_screens` — 기존 스크린 수정

### 3. 디자인 가이드 업데이트

- 프로젝트의 `docs/design-guide.md` 확인 (없으면 `${CLAUDE_PLUGIN_ROOT}/templates/design-guide.template.md`에서 생성)
- 새 스크린 정보 추가 (Stitch Project/Screen ID, 디자인 결정사항)
- 첫 디자인이면 Brand Identity (색상/서체/간격) 결정 기록
- 공통 컴포넌트 패턴 기록

### 4. SvelteKit 구현 가이드

- Route structure (`src/routes/[path]/+page.svelte`)
- Component decomposition
- Tailwind CSS 4 styling
- Runes: `$state`, `$derived`, `$effect`, `$props`

### 5. Output

```
Design: [screen description]
- Stitch: Project [name], Screen [ID]
- Route: src/routes/[path]/+page.svelte
- Components: [breakdown]
- Design Guide: docs/design-guide.md updated
```

## Fallback 워크플로우 (Stitch 없을 때 — frontend-design 플러그인)

### 1. frontend-design 플러그인 활성화

- frontend-design 플러그인이 자동으로 UI 디자인 작업 처리
- Stitch 없이도 높은 품질의 UI 코드 생성 가능

### 2. 디자인 가이드 관리

- 프로젝트의 `docs/design-guide.md` 확인 (없으면 `${CLAUDE_PLUGIN_ROOT}/templates/design-guide.template.md`에서 생성)
- 컴포넌트/색상/서체 결정사항 기록
- Stitch 없이도 디자인 가이드는 동일하게 관리

### 3. SvelteKit 구현

- frontend-design 플러그인이 직접 코드 생성
- 디자인 가이드 준수 확인

### 4. Output

```
Design: [screen description]
- Method: frontend-design plugin
- Route: src/routes/[path]/+page.svelte
- Components: [breakdown]
- Design Guide: docs/design-guide.md updated
```

## Important

- Design ONLY. No code writing.
- Requires `STITCH_API_KEY` (or use frontend-design plugin as alternative).
- 디자인 가이드(`docs/design-guide.md`)는 양쪽 워크플로우 모두에서 관리.
