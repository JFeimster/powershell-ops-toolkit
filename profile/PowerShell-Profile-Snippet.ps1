# >>> powershell-ops-toolkit >>>
$PowerShellOpsToolkitRoot = Join-Path $HOME 'OneDrive\Desktop\JSON\skills\powershell-ops-toolkit'
$PowerShellOpsToolkitModule = Join-Path $PowerShellOpsToolkitRoot 'modules\PowerShellOpsToolkit\PowerShellOpsToolkit.psd1'

if (Test-Path $PowerShellOpsToolkitModule) {
    Import-Module $PowerShellOpsToolkitModule -Force -ErrorAction Stop
}
# <<< powershell-ops-toolkit <<<
