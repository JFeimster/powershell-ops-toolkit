# Architecture

## Source of truth

This GitHub repository is the canonical source for toolkit code and documentation.

Local installed copies may live under:

```text
C:\Users\jason\OneDrive\Desktop\JSON\skills\powershell-ops-toolkit
```

Individual legacy skills may continue to exist separately while tools are migrated.

## Layers

### `tools/`
Public operator commands. Each tool should eventually own its scripts, config, tests, README, and SKILL documentation.

### `lib/`
Shared implementation helpers that should not become public commands unless there is a clear operator use case.

### `modules/PowerShellOpsToolkit/`
The consolidated PowerShell module loader and manifest. This is the long-term import surface for the toolkit.

### `config/`
Machine/project root configuration and general toolkit defaults.

### `profile/`
Minimal profile loader snippets. The PowerShell profile should not contain full command implementations.

### `tests/`
Cross-tool unit/integration tests and reusable fixtures.

### `docs/`
Operator documentation, architecture, and contribution rules.

### `examples/`
Safe example configuration and profile snippets.

## Command contract

Public commands should generally:

1. accept repo URL, owner/repo, repo name, or path when applicable;
2. reuse shared discovery rather than re-scan independently;
3. return structured PowerShell objects;
4. keep concise default output;
5. expose explicit switches for state-changing actions;
6. avoid destructive behavior by default;
7. avoid whole-drive scans;
8. preserve existing working infrastructure unless a material problem exists.

## Integration rule

Read-only discovery can be automatic. GitHub writes, deploys, publishing, file deletion, or other external state changes should require an explicit action from the operator.
