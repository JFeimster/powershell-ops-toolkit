$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $moduleRoot)

$libRoot = Join-Path $repoRoot 'lib'
if (Test-Path $libRoot) {
    Get-ChildItem -Path $libRoot -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}

$toolsRoot = Join-Path $repoRoot 'tools'
if (Test-Path $toolsRoot) {
    Get-ChildItem -Path $toolsRoot -Recurse -Filter '*.ps1' -File |
        Where-Object { $_.FullName -match '[\\/]scripts[\\/]' } |
        Sort-Object FullName |
        ForEach-Object { . $_.FullName }
}

# Individual tools should export their public functions explicitly once migrated.
