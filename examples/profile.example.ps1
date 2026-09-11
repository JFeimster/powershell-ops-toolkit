# Example profile wiring for PowerShell Ops Toolkit.
# Keep this block small; command implementations belong in the toolkit itself.

$PowerShellOpsToolkitRoot = Join-Path $HOME 'OneDrive\Desktop\JSON\skills\powershell-ops-toolkit'
$PowerShellOpsToolkitModule = Join-Path $PowerShellOpsToolkitRoot 'modules\PowerShellOpsToolkit\PowerShellOpsToolkit.psd1'

if (Test-Path $PowerShellOpsToolkitModule) {
    Import-Module $PowerShellOpsToolkitModule -Force
}
