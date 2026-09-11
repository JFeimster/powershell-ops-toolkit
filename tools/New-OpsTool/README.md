# New-OpsTool

Scaffold new tools for the PowerShell Ops Toolkit using a consistent structure.

## Default scaffold

```text
Tool-Name/
├── scripts/
├── config/
├── tests/
├── README.md
└── SKILL.md
```

## Extended standard

Optional capability folders are created only when needed:

```text
schemas/
prompts/
templates/
agents/
fixtures/
docs/
examples/
```

Create all extended folders with `-Extended`, or add them individually with switches.

## Examples

```powershell
New-OpsTool 'Open-Project'
New-OpsTool 'Export-ProjectContext' -Schemas -Templates
New-OpsTool 'Find-ContentGap' -Agents -Prompts -Schemas
New-OpsTool 'Search-MyStack' -Extended
```

## Safety

The command refuses to overwrite an existing tool unless `-Force` is explicitly supplied. It supports `-WhatIf` through `SupportsShouldProcess` and `-PassThru` for structured output.

## Entry point

```text
scripts/New-OpsTool.ps1
```
