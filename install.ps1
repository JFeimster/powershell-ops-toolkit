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
        if ((Test-Path $destination) -and $Force) {
            Remove-Item -LiteralPath $destination -Recurse -Force
        }
        Copy-Item -Path $source -Destination $destination -Recurse -Force
    }
}

$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$beginMarker = '# >>> powershell-ops-toolkit >>>'
$endMarker = '# <<< powershell-ops-toolkit <<<'
$escapedRoot = $InstallRoot.Replace("'", "''")
$profileBlock = @"
$beginMarker
`$PowerShellOpsToolkitRoot = '$escapedRoot'
`$PowerShellOpsToolkitModule = Join-Path `$PowerShellOpsToolkitRoot 'modules\PowerShellOpsToolkit\PowerShellOpsToolkit.psd1'
if (Test-Path -LiteralPath `$PowerShellOpsToolkitModule) {
    Import-Module `$PowerShellOpsToolkitModule -Force -ErrorAction Stop
}
$endMarker
"@

$currentProfile = Get-Content -LiteralPath $profilePath -Raw
$pattern = '(?ms)^' + [regex]::Escape($beginMarker) + '.*?^' + [regex]::Escape($endMarker) + '\s*'
if ($currentProfile -match $pattern) {
    $newProfile = [regex]::Replace($currentProfile, $pattern, $profileBlock + [Environment]::NewLine)
    $profileAction = 'UPDATED existing toolkit marker block'
} else {
    $separator = if ([string]::IsNullOrWhiteSpace($currentProfile)) { '' } else { [Environment]::NewLine }
    $newProfile = $currentProfile.TrimEnd() + $separator + $profileBlock + [Environment]::NewLine
    $profileAction = 'ADDED toolkit marker block'
}

if ($PSCmdlet.ShouldProcess($profilePath, 'Wire toolkit module into PowerShell profile')) {
    Set-Content -LiteralPath $profilePath -Value $newProfile -Encoding utf8
}

$modulePath = Join-Path $InstallRoot 'modules\PowerShellOpsToolkit\PowerShellOpsToolkit.psd1'
if (Test-Path -LiteralPath $modulePath) {
    Import-Module $modulePath -Force -ErrorAction Stop
}

Write-Host "Toolkit files staged successfully." -ForegroundColor Green
Write-Host "Profile: $profilePath"
Write-Host "Profile wiring: $profileAction" -ForegroundColor Green
Write-Host "Toolkit module imported into the current PowerShell session." -ForegroundColor Green
