[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$InstallRoot = (Join-Path $HOME 'OneDrive\Desktop\JSON\skills\powershell-ops-toolkit'),
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "PowerShell Ops Toolkit installer" -ForegroundColor Cyan
Write-Host "Source:  $repoRoot"
Write-Host "Target:  $InstallRoot"

if (-not (Test-Path $InstallRoot)) {
    if ($PSCmdlet.ShouldProcess($InstallRoot, 'Create toolkit install directory')) {
        New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
    }
}

$items = @('config', 'lib', 'modules', 'profile', 'tools', 'docs', 'examples', 'powershell-ops-toolkit.registry.json', 'README.md')
foreach ($item in $items) {
    $source = Join-Path $repoRoot $item
    if (-not (Test-Path $source)) { continue }

    $destination = Join-Path $InstallRoot $item
    if ($PSCmdlet.ShouldProcess($destination, "Copy $item")) {
        Copy-Item -Path $source -Destination $destination -Recurse -Force:$Force
    }
}

Write-Host "Toolkit files staged successfully." -ForegroundColor Green
Write-Host "Profile wiring is intentionally managed separately in profile\PowerShell-Profile-Snippet.ps1."
