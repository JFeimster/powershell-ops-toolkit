# Detection Rules

## Project type
1. `next` dependency → Next.js
2. `vite` dependency → Vite
3. `index.html` → Static HTML
4. Otherwise unsupported

## Package manager
1. `package.json` `packageManager`
2. Lockfile:
   - package-lock.json → npm
   - pnpm-lock.yaml → pnpm
   - yarn.lock → yarn
   - bun.lock / bun.lockb → bun
3. No lockfile → npm

Conflicting lockfiles cause the launcher to stop rather than guess.

## Default ports
- Static HTML → 8000
- Next.js → 3000
- Vite → 5173

Set an explicit port to override.
