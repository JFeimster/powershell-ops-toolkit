# Tests

Cross-tool validation belongs here.

Planned structure:

```text
tests/
├── unit/
├── integration/
└── fixtures/
```

Create those subfolders as real tests are added rather than committing empty directories.

## Expectations

Tests should cover:

- structured object output;
- paths containing spaces;
- missing dependencies and missing paths;
- duplicate local repositories;
- Git remote normalization;
- config loading;
- PowerShell profile/module loading;
- read-only defaults for external integrations.

Individual tool-specific tests may also live with the tool under `tools/<CommandName>/tests/`.
