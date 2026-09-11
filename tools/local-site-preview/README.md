# Local Site Preview

Portable Agent Skill + PowerShell utility for serving static HTML sites locally.

## Files

```text
local-site-preview/
├── SKILL.md
├── README.md
└── scripts/
    └── Start-LocalSite.ps1
```

## Recommended canonical location

```text
C:\Users\jason\OneDrive\Desktop\JSON\skills\local-site-preview\
```

Copy the contents of this package there.

## PowerShell

Run directly:

```powershell
& "C:\Users\jason\OneDrive\Desktop\JSON\skills\local-site-preview\scripts\Start-LocalSite.ps1" -Path "C:\path\to\site"
```

Custom port:

```powershell
& "C:\Users\jason\OneDrive\Desktop\JSON\skills\local-site-preview\scripts\Start-LocalSite.ps1" -Path "C:\path\to\site" -Port 8001
```

## PowerShell profile shortcut

Add this to `$PROFILE`:

```powershell
function Start-LocalSite {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [int]$Port = 8000
    )

    & "C:\Users\jason\OneDrive\Desktop\JSON\skills\local-site-preview\scripts\Start-LocalSite.ps1" `
        -Path $Path `
        -Port $Port
}
```

Then:

```powershell
Start-LocalSite "C:\path\to\site"
```

## VS Code

The PowerShell script works directly in the VS Code terminal.

For Agent Skills, place or link the entire `local-site-preview` folder into the personal or workspace Agent Skills directory recognized by your VS Code setup. Keep the canonical copy above as the source of truth.

## Codex / ChatGPT / other Agent-Skills-compatible platforms

Upload or copy the complete `local-site-preview` folder or the ZIP package. The important portable entrypoint is `SKILL.md`; the PowerShell helper lives under `scripts/`.

Do not split `SKILL.md` from its `scripts` directory when uploading the skill.
