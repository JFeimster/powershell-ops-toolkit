[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$PassThru
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name Pester)) {
    throw "Pester is required. Install with: Install-Module Pester -Scope CurrentUser"
}

$toolTests = Join-Path $RepoRoot 'tools'
$config = New-PesterConfiguration
$config.Run.Path = $toolTests
$config.Run.PassThru = $true
$config.Output.Verbosity = 'Detailed'
$config.Filter.Tag = @()

$result = Invoke-Pester -Configuration $config

$summary = [pscustomobject]@{
    Result       = $result.Result
    TotalCount   = $result.TotalCount
    PassedCount  = $result.PassedCount
    FailedCount  = $result.FailedCount
    SkippedCount = $result.SkippedCount
    Duration     = $result.Duration
}

$summary | Format-List

if ($PassThru) { $result }
if ($result.FailedCount -gt 0) { exit 1 }
