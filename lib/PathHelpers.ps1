function Get-ToolkitProjectRoots {
    [CmdletBinding()]
    param([string]$ConfigPath)

    if (-not $ConfigPath) {
        $repoRoot = Split-Path -Parent $PSScriptRoot
        $ConfigPath = Join-Path $repoRoot 'config\project-roots.psd1'
    }

    if (-not (Test-Path $ConfigPath)) {
        throw "Project root config not found: $ConfigPath"
    }

    $config = Import-PowerShellDataFile -Path $ConfigPath
    return $config.ProjectRoots | Where-Object { Test-Path $_ }
}

function Resolve-ExistingPath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path $Path)) { return $null }
    return (Resolve-Path $Path).Path
}
