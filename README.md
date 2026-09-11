# PowerShell Ops Toolkit

Reusable PowerShell helpers and operator tooling for finding, opening, validating, and managing local projects, repositories, deployments, and content workflows.

## Purpose

This repository is the canonical source for small, composable operator tools used across local development, GitHub, Vercel, Wix, Notion, ChatGPT, and related project workflows.

## Structure

```text
powershell-ops-toolkit/
├── README.md
├── LICENSE
├── powershell-ops-toolkit.registry.json
├── install.ps1
├── profile/
├── config/
├── tools/
├── modules/
├── lib/
├── tests/
├── docs/
└── examples/
```

## Design principles

- Keep the PowerShell profile thin.
- Keep each operator command independently reusable.
- Prefer structured PowerShell objects over formatted-only output.
- Reuse shared path, Git, project-detection, and output helpers.
- Avoid scanning irrelevant system directories.
- Default state-changing integrations to preview/read-only unless explicitly authorized.
- Keep configuration separate from implementation.

## Existing tools

- `Start-LocalSite`
- `Find-LocalRepo`

See `powershell-ops-toolkit.registry.json` for the complete roadmap and build priority.

## Configuration

Machine-specific project roots belong in `config/project-roots.psd1`. General toolkit behavior belongs in `config/toolkit.config.psd1`.

## Installation

`install.ps1` is the future single entry point for installing or updating the toolkit and wiring the PowerShell profile. Until individual tools are migrated into this repository, existing installed skills remain authoritative.
