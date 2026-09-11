function Start-Project {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [switch]$Open,
        [int]$Port
    )

    $path = $Repository
    if (-not (Test-Path -LiteralPath $path -PathType Container) -and (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue)) {
        $m = Find-LocalRepo $Repository | Select-Object -First 1
        if ($m) { $path = $m.Path }
    }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Project not found: $Repository" }
    $path = (Resolve-Path -LiteralPath $path).Path

    $packagePath = Join-Path $path 'package.json'
    if (-not (Test-Path $packagePath)) {
        if (Get-Command Start-LocalSite -ErrorAction SilentlyContinue) { return Start-LocalSite $path }
        throw "No package.json found in $path"
    }

    $pkg = Get-Content $packagePath -Raw | ConvertFrom-Json
    $scriptName = if ($pkg.scripts.dev) { 'dev' } elseif ($pkg.scripts.start) { 'start' } elseif ($pkg.scripts.serve) { 'serve' } else { $null }
    if (-not $scriptName) { throw "No dev/start/serve script found in package.json." }

    if (Test-Path (Join-Path $path 'pnpm-lock.yaml')) { $pm = 'pnpm' }
    elseif (Test-Path (Join-Path $path 'yarn.lock')) { $pm = 'yarn' }
    else { $pm = 'npm' }

    $args = if ($pm -eq 'yarn') { @($scriptName) } else { @('run', $scriptName) }
    if ($Port) { $args += @('--','--port', $Port) }

    $cmd = Get-Command $pm -ErrorAction SilentlyContinue
    if (-not $cmd) { throw "Package manager '$pm' is not available in PATH." }

    if ($PSCmdlet.ShouldProcess($path, "$pm $($args -join ' ')")) {
        Push-Location $path
        try {
            if ($Open) {
                $joined = ($args | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join ' '
                Start-Process pwsh -WorkingDirectory $path -ArgumentList @('-NoExit','-Command',"& '$($cmd.Source)' $joined") | Out-Null
            } else {
                & $cmd.Source @args
            }
        } finally { Pop-Location }
    }
}