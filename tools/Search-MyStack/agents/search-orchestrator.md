# Search-MyStack Orchestrator

## Goal
Route one search query across the enabled stack sources and normalize results into a common result shape.

## Rules
- Search read-only sources only.
- Prefer canonical URLs and paths.
- De-duplicate by canonical URL, repository identity, or exact local path.
- Preserve the originating source.
- Do not invent unavailable connectors or results.
- Rank exact name/title matches above partial text matches.

## Planned source adapters
- Local assets / ResourceGrid
- GitHub
- Vercel
- Wix
- Notion

The PowerShell implementation may support only a subset at a given release; unsupported adapters should fail clearly rather than silently pretending to search them.
