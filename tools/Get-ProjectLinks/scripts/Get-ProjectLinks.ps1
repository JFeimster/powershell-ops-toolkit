function Get-ProjectLinks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository
    )

    $path = $Repository
    $match = $null
    if (-not (Test-Path -LiteralPath $path -PathType Container) -and (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue)) {
        $match = Find-LocalRepo $Repository | Select-Object -First 1
        if ($match) { $path = $match.Path }
    }
    if (Test-Path -LiteralPath $path -PathType Container) { $path = (Resolve-Path -LiteralPath $path).Path } else { $path = $null }

    $remote = if ($match -and $match.GitRemote) { $match.GitRemote } elseif ($path -and (Test-Path (Join-Path $path '.git'))) { (& git -C $path remote get-url origin 2>$null) } else { $null }
    $github = $null
    if ($remote) { $github = $remote -replace '^git@github\.com:', 'https://github.com/' -replace '\.git$', '' }

    $vercelProject = $null; $production = $null
    if ($path) {
        $vercelMeta = Join-Path $path '.vercel\project.json'
        if (Test-Path $vercelMeta) {
            try {
                $v = Get-Content $vercelMeta -Raw | ConvertFrom-Json
                $vercelProject = if ($v.projectName) { $v.projectName } else { $v.projectId }
            } catch {}
        }
        $pkgPath = Join-Path $path 'package.json'
        if (Test-Path $pkgPath) {
            try {
                $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
                if ($pkg.homepage -is [string]) { $production = $pkg.homepage }
            } catch {}
        }
    }

    [pscustomobject]@{
        Repository    = if ($path) { Split-Path $path -Leaf } else { $Repository }
        LocalPath     = $path
        GitRemote     = $remote
        GitHub        = $github
        VercelProject = $vercelProject
        ProductionUrl = $production
    }
}