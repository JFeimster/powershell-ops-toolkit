# New-OpsTool usage

Create the default scaffold:

```powershell
New-OpsTool 'Open-Project'
```

Create selected capability folders:

```powershell
New-OpsTool 'Export-ProjectContext' -Schemas -Templates -Docs -Examples
```

Create the full extended standard:

```powershell
New-OpsTool 'Find-ContentGap' -Extended
```

The default scaffold contains:

```text
Tool-Name/
├── scripts/
├── config/
├── tests/
├── README.md
└── SKILL.md
```

The extended standard adds:

```text
schemas/
prompts/
templates/
agents/
fixtures/
docs/
examples/
```

`New-OpsTool` refuses to overwrite an existing tool unless `-Force` is supplied. Use `-PassThru` to return a structured object describing the scaffold.
