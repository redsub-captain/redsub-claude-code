---
paths:
  - "src/**/*.ts"
  - "src/**/*.svelte"
  - "src/**/*.js"
---

# Code Quality Rules

## TypeScript
- Strict mode required. No `any` type.
- Omit explicit types when inference is sufficient.

## SvelteKit 5
- Use Runes API: `$state`, `$derived`, `$effect`, `$props`.
- No legacy reactivity (`$:`, `export let`).
- Server-only logic in `+server.ts` or `src/lib/server/` only.
- Server data in `+page.ts` load functions must use `+page.server.ts`.

## Security
→ `security-guidance` plugin handles detailed rules. Key reminders: no hardcoded secrets, validate user input at boundaries.

## Environment Variables
- When adding new env vars, update simultaneously:
  1. `.env` (local)
  2. `apphosting.yaml` (deployment)
  3. Related documentation

## Single Source of Truth (SSOT)
- **Every piece of data has exactly one canonical source.** All consumers read from it.
- Config values (API URLs, feature flags, limits) → one config file or env var. Never scatter across files.
- Business logic (pricing rules, validation, permissions) → one module. Other files import, never re-implement.
- Type definitions → define once, re-export. Never redeclare the same shape in multiple files.
- UI strings → i18n files only. No inline text in components.
- Constants (error codes, status enums, route paths) → one constants file per domain.
- **Review checkpoint**: When editing a value, search for duplicates (`Grep`). If found elsewhere, refactor to single source before proceeding.
- **Violation = bug**: Treating duplicated data sources as bugs, not style issues.

## Strings
- No hardcoded strings. Use i18n keys or constants.
- Includes error messages and UI text.

## Styling
- Tailwind CSS 4 utility-first. Minimize custom CSS.
- Use `clsx` or `cn` for conditional class props.

## Database (merged from database rules)
- Supabase: Always use RLS. Test policies in SQL editor first.
- Firestore: Keep documents small. Use subcollections for large data.
- Index frequently queried fields.
