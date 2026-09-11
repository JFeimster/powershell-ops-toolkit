# Contributing

## Keep tools small

Add a new command only when it solves a recurring operator problem. Prefer composing existing helpers over creating overlapping discovery logic.

## Naming

Use approved PowerShell verbs and clear singular nouns where practical, for example:

- `Get-ProjectStatus`
- `Find-LocalRepo`
- `Open-Project`
- `Test-Project`

## Tool structure

When a tool is added under `tools/`, use this pattern:

```text
tools/<CommandName>/
├── scripts/
│   └── <CommandName>.ps1
├── config/
├── tests/
├── README.md
└── SKILL.md
```

Only create subfolders that the tool actually needs.

## Behavior

- Return objects, not text-only output.
- Use `Write-Verbose` for diagnostic noise.
- Avoid hard-coding machine-specific values outside configuration files.
- Do not scan the entire system drive.
- Preserve unrelated profile content.
- Make install/profile wiring idempotent.
- Require explicit switches or authorization for destructive/state-changing behavior.

## Validation

Before considering a tool complete, test:

- normal input;
- paths containing spaces;
- missing paths/dependencies;
- duplicate results where applicable;
- structured output through `Select-Object` and `ConvertTo-Json`;
- PowerShell 7 behavior.

Update `powershell-ops-toolkit.registry.json` when implementation status changes.
