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

- **If set** → proceed with Stitch MCP (Steps 1-4 below).
- **If NOT set** → use `AskUserQuestion` tool:
  - question: "Stitch API key가 설정되지 않았습니다. 어떻게 하시겠습니까?"
  - header: "Stitch API"
  - options: ["Set up now" (run /redsub-setup --force to configure), "Use frontend-design" (no API key needed, frontend-design plugin will handle UI work)]

  If user chooses "Use frontend-design", stop this skill. The frontend-design plugin will auto-activate on frontend work.

## Input

`$ARGUMENTS`: screen description.

## Procedure

### 1. Check Stitch project
Create if needed.

### 2. Design screen
Generate via Stitch MCP. Device: `DESKTOP` default, or `MOBILE` if specified.

### 3. SvelteKit implementation guide
- Route structure
- Component decomposition
- Tailwind CSS 4 styling
- Runes: $state, $derived, $effect, $props

### 4. Output
```
Design: [screen]
- Stitch: Project [name], Screen [ID]
- Route: src/routes/[path]/+page.svelte
- Components: [breakdown]
```

## Important
- Design ONLY. No code writing.
- Requires `STITCH_API_KEY` (or use frontend-design plugin as alternative).
