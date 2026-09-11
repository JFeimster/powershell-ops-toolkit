function Get-ChangedFiles {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [switch]$IncludeIgnoredArtifacts
    )

    $path = $Repository
    if (-not (Test-Path -LiteralPath $path -PathType Container) -and (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue)) {
        $m = Find-LocalRepo $Repository | Select-Object -First 1
        if ($m) { $path = $m.Path }
    }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Project not found: $Repository" }
    $path = (Resolve-Path -LiteralPath $path).Path
    if (-not (Test-Path (Join-Path $path '.git'))) { throw "Not a Git repository: $path" }

    $skip = '^(\.next|node_modules|dist|build|coverage|vendor|\.turbo|\.cache)(/|\\)'
    $rows = & git -C $path status --porcelain=v1 2>$null
    foreach ($row in $rows) {
        if ([string]::IsNullOrWhiteSpace($row) -or $row.Length -lt 4) { continue }
        $status = $row.Substring(0,2).Trim()
        $file = $row.Substring(3).Trim()
        if (-not $IncludeIgnoredArtifacts -and $file -match $skip) { continue }
        [pscustomobject]@{
            Status = $status
            Path = $file
            FullPath = Join-Path $path ($file -replace ' -> .*$', '')
            Repository = Split-Path $path -Leaf
        }
    }
}