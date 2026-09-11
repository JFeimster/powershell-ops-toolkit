# New-OpsTool

## Purpose

Create consistent tool scaffolds under the repository `tools/` directory.

## Entry point

`tools/New-OpsTool/scripts/New-OpsTool.ps1`

## Default behavior

Create only the base structure:

- `scripts/`
- `config/`
- `tests/`
- `README.md`
- `SKILL.md`

Do not create optional folders unless requested.

## Extended standard

Optional capability folders:

- `schemas/` for JSON schemas and structured contracts
- `prompts/` for reusable LLM prompts
- `templates/` for reusable output/file templates
- `agents/` for actual agentic workflows or agent instructions
- `fixtures/` for deterministic test data
- `docs/` for advanced documentation
- `examples/` for executable usage examples

Use `-Extended` to create all optional folders, or the corresponding individual switches to create only what the tool needs.

## Safety

- Do not overwrite an existing tool by default.
- `-Force` must be explicit before existing scaffold files may be refreshed.
- Support `-WhatIf` for previewing scaffold creation.
- Keep generated commands read-only by default unless their purpose explicitly requires state changes.

## Examples

```powershell
New-OpsTool 'Open-Project'
New-OpsTool 'Export-ProjectContext' -Schemas -Templates -Docs
New-OpsTool 'Find-ContentGap' -Agents -Prompts -Schemas
New-OpsTool 'Search-MyStack' -Extended -PassThru
```
