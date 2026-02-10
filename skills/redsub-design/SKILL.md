---
name: redsub-design
description: UI/UX screen design via Stitch MCP.
---

# UI/UX Design

> **Language**: Read `~/.claude-redsub/language` (ko/en). Default to `en` if not found.

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
- Requires `STITCH_API_KEY`.
