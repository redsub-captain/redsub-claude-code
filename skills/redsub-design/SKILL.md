---
name: redsub-design
description: UI/UX screen design via Stitch MCP.
---

# UI/UX Design

> **Language**: Follow the user's Claude Code language setting.

## Prerequisites

Check if `STITCH_API_KEY` is configured:

```bash
echo "${STITCH_API_KEY:+configured}"
```

- **If set** → proceed with Stitch MCP (Steps 1-4 below).
- **If NOT set** → inform user:
  ```
  Stitch API key is not configured. Two options:
  (a) Set up now with /redsub-setup --force
  (b) Use the frontend-design plugin instead (no API key needed)
      → Just describe your desired UI and the frontend-design skill
        will guide you with production-grade implementation.
  ```
  If user chooses (b), stop this skill. The frontend-design plugin will auto-activate on frontend work.

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
