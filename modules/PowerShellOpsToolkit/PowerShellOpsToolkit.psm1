$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $moduleRoot)

$libRoot = Join-Path $repoRoot 'lib'
if (Test-Path $libRoot) {
    Get-ChildItem -Path $libRoot -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}

$toolsRoot = Join-Path $repoRoot 'tools'
$publicFunctions = [System.Collections.Generic.List[string]]::new()

if (Test-Path $toolsRoot) {
    Get-ChildItem -Path $toolsRoot -Directory | Sort-Object Name | ForEach-Object {
        $toolName = $_.Name
        $scriptPath = Join-Path $_.FullName "scripts\$toolName.ps1"

        if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
            return
        }

        if ($toolName -eq 'Start-LocalSite') {
            $startLocalSiteScript = $scriptPath
            function Start-LocalSite {
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory = $true, Position = 0)]
                    [string]$Path,
                    [Parameter(Position = 1)]
                    [ValidateRange(0, 65535)]
                    [int]$Port = 0
                )

                & $script:startLocalSiteScript -Path $Path -Port $Port
            }
            $publicFunctions.Add('Start-LocalSite')
            return
        }

        . $scriptPath
        if (Get-Command $toolName -CommandType Function -ErrorAction SilentlyContinue) {
            $publicFunctions.Add($toolName)
        }
    }
}

if ($publicFunctions.Count -gt 0) {
    Export-ModuleMember -Function ($publicFunctions | Sort-Object -Unique)
}
