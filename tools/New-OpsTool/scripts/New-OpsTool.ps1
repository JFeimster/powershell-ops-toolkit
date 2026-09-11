function New-OpsTool {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidatePattern('^[A-Za-z][A-Za-z0-9]*-[A-Za-z][A-Za-z0-9-]*$')]
        [string]$Name,

        [string]$RepoRoot = (Get-Location).Path,

        [switch]$Schemas,
        [switch]$Prompts,
        [switch]$Templates,
        [switch]$Agents,
        [switch]$Fixtures,
        [switch]$Docs,
        [switch]$Examples,
        [switch]$Extended,
        [switch]$Force,
        [switch]$PassThru
    )

    $resolvedRoot = [System.IO.Path]::GetFullPath($RepoRoot)
    $toolsRoot = Join-Path $resolvedRoot 'tools'
    $toolRoot = Join-Path $toolsRoot $Name

    if (-not (Test-Path $toolsRoot)) {
        throw "Tools directory not found: $toolsRoot"
    }

    if ((Test-Path $toolRoot) -and -not $Force) {
        throw "Tool already exists: $toolRoot. Use -Force only when you intentionally want to refresh scaffold files."
    }

    if ($Extended) {
        $Schemas = $true
        $Prompts = $true
        $Templates = $true
        $Agents = $true
        $Fixtures = $true
        $Docs = $true
        $Examples = $true
    }

    $baseFolders = @('scripts', 'config', 'tests')
    $optionalFolders = [ordered]@{
        schemas   = [bool]$Schemas
        prompts   = [bool]$Prompts
        templates = [bool]$Templates
        agents    = [bool]$Agents
        fixtures  = [bool]$Fixtures
        docs      = [bool]$Docs
        examples  = [bool]$Examples
    }

    $folders = @($baseFolders)
    $folders += $optionalFolders.GetEnumerator() |
        Where-Object Value |
        ForEach-Object Key

    if (-not $PSCmdlet.ShouldProcess($toolRoot, "Create PowerShell Ops Toolkit scaffold for $Name")) {
        return
    }

    New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null
    foreach ($folder in $folders) {
        New-Item -ItemType Directory -Path (Join-Path $toolRoot $folder) -Force | Out-Null
    }

    function Write-ScaffoldFile {
        param(
            [Parameter(Mandatory)][string]$Path,
            [Parameter(Mandatory)][string]$Content
        )

        if ((Test-Path $Path) -and -not $Force) {
            return
        }

        Set-Content -Path $Path -Value $Content -Encoding utf8
    }

    $scriptContent = @"
function $Name {
    [CmdletBinding()]
    param()

    # TODO: implement.
}
"@

    $configContent = @"
@{
    Name    = '$Name'
    Enabled = `$true
}
"@

    $testContent = @"
BeforeAll {
    . "`$PSScriptRoot\..\scripts\$Name.ps1"
}

Describe '$Name' {
    It 'loads successfully' {
        Get-Command '$Name' -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}
"@

    $readmeContent = @"
# $Name

Reusable command in the PowerShell Ops Toolkit.

## Usage

``````powershell
$Name
``````

## Structure

- `scripts/` - implementation
- `config/` - tool configuration
- `tests/` - validation
- `SKILL.md` - tool operating instructions

Optional capability folders are created only when requested by `New-OpsTool` switches or `-Extended`.
"@

    $skillContent = @"
# $Name

## Purpose

Reusable PowerShell Ops Toolkit command for `$Name`.

## Entry point

`scripts/$Name.ps1`

## Requirements

- Target PowerShell 7+.
- Return structured PowerShell objects when applicable.
- Prefer read-only behavior by default.
- Require explicit intent for destructive or external state-changing actions.
- Keep tool-specific configuration under `config/`.
- Add optional folders only when they serve an actual capability.
"@

    Write-ScaffoldFile -Path (Join-Path $toolRoot 'README.md') -Content $readmeContent
    Write-ScaffoldFile -Path (Join-Path $toolRoot 'SKILL.md') -Content $skillContent
    Write-ScaffoldFile -Path (Join-Path $toolRoot "scripts\$Name.ps1") -Content $scriptContent
    Write-ScaffoldFile -Path (Join-Path $toolRoot "config\$Name.psd1") -Content $configContent
    Write-ScaffoldFile -Path (Join-Path $toolRoot "tests\$Name.Tests.ps1") -Content $testContent

    if ($Schemas) {
        $schema = @"
{
  "`$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "$Name tool manifest",
  "type": "object",
  "properties": {
    "name": { "const": "$Name" },
    "version": { "type": "string" },
    "description": { "type": "string" }
  },
  "required": ["name"]
}
"@
        Write-ScaffoldFile -Path (Join-Path $toolRoot 'schemas\tool-manifest.schema.json') -Content $schema
    }

    if ($Prompts) {
        Write-ScaffoldFile -Path (Join-Path $toolRoot 'prompts\README.md') -Content "# Prompts`n`nReusable LLM prompts for $Name belong here.`n"
    }

    if ($Templates) {
        Write-ScaffoldFile -Path (Join-Path $toolRoot 'templates\README.md') -Content "# Templates`n`nReusable output or file templates for $Name belong here.`n"
    }

    if ($Agents) {
        Write-ScaffoldFile -Path (Join-Path $toolRoot 'agents\README.md') -Content "# Agents`n`nAgent-specific instructions or workflows for $Name belong here when the tool actually uses an agentic workflow.`n"
    }

    if ($Fixtures) {
        Write-ScaffoldFile -Path (Join-Path $toolRoot 'fixtures\README.md') -Content "# Fixtures`n`nDeterministic test fixtures for $Name belong here.`n"
    }

    if ($Docs) {
        Write-ScaffoldFile -Path (Join-Path $toolRoot 'docs\usage.md') -Content "# $Name usage`n`nDocument advanced usage, behavior, and edge cases here.`n"
    }

    if ($Examples) {
        Write-ScaffoldFile -Path (Join-Path $toolRoot "examples\$Name.examples.ps1") -Content "# Examples for $Name`n`n$Name`n"
    }

    $result = [pscustomobject]@{
        Name            = $Name
        Path            = $toolRoot
        Extended        = [bool]$Extended
        CreatedFolders  = $folders
        ScriptPath      = Join-Path $toolRoot "scripts\$Name.ps1"
        ConfigPath      = Join-Path $toolRoot "config\$Name.psd1"
        TestPath        = Join-Path $toolRoot "tests\$Name.Tests.ps1"
    }

    if ($PassThru) {
        return $result
    }

    Write-Host "Created: $toolRoot"
    Write-Host "Folders: $($folders -join ', ')"
}
