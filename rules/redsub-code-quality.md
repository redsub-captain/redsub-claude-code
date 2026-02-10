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

## Security (merged from security-guidance)
- Never hardcode secrets. Use env vars.
- Validate all user input at system boundaries.
- Supabase: RLS required on all tables.
- Firestore: Security Rules must restrict access.
- No dynamic code execution, no innerHTML with user data, no unparameterized SQL.

## Environment Variables
- When adding new env vars, update simultaneously:
  1. `.env` (local)
  2. `apphosting.yaml` (deployment)
  3. Related documentation

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
