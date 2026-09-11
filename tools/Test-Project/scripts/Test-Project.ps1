function Test-Project {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [switch]$StopOnFailure
    )

    $path = $Repository
    if (-not (Test-Path -LiteralPath $path -PathType Container) -and (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue)) {
        $m = Find-LocalRepo $Repository | Select-Object -First 1
        if ($m) { $path = $m.Path }
    }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Project not found: $Repository" }
    $path = (Resolve-Path -LiteralPath $path).Path

    $packagePath = Join-Path $path 'package.json'
    if (-not (Test-Path $packagePath)) { throw "No package.json found in $path" }
    $pkg = Get-Content $packagePath -Raw | ConvertFrom-Json

    if (Test-Path (Join-Path $path 'pnpm-lock.yaml')) { $pm = 'pnpm' }
    elseif (Test-Path (Join-Path $path 'yarn.lock')) { $pm = 'yarn' }
    else { $pm = 'npm' }

    $order = @('lint','typecheck','test','build')
    $results = foreach ($name in $order) {
        if (-not $pkg.scripts.$name) { continue }
        Push-Location $path
        try {
            $output = & $pm $(if ($pm -eq 'yarn') { $name } else { 'run' }) $(if ($pm -eq 'yarn') { $null } else { $name }) 2>&1
            $code = $LASTEXITCODE
        } finally { Pop-Location }
        [pscustomobject]@{
            Check   = $name
            Status  = if ($code -eq 0) { 'PASS' } else { 'FAIL' }
            ExitCode = $code
            Output  = ($output -join [Environment]::NewLine)
        }
        if ($StopOnFailure -and $code -ne 0) { break }
    }
    $results
}