function Get-ProjectStatus {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.'
    )

    $path = $Repository
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        if (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue) {
            $match = Find-LocalRepo $Repository | Select-Object -First 1
            if ($match) { $path = $match.Path }
        }
    }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Project not found: $Repository" }
    $path = (Resolve-Path -LiteralPath $path).Path

    $hasGit = Test-Path (Join-Path $path '.git')
    $branch = $remote = $lastCommit = $statusText = $null
    $ahead = $behind = 0
    if ($hasGit) {
        $branch = (& git -C $path branch --show-current 2>$null)
        $remote = (& git -C $path remote get-url origin 2>$null)
        $lastCommit = (& git -C $path log -1 --format='%h %ad %s' --date=short 2>$null)
        $statusText = (& git -C $path status --porcelain 2>$null)
        $counts = (& git -C $path rev-list --left-right --count '@{upstream}...HEAD' 2>$null)
        if ($LASTEXITCODE -eq 0 -and $counts) {
            $parts = ($counts -split '\s+') | Where-Object { $_ -ne '' }
            if ($parts.Count -ge 2) { $behind = [int]$parts[0]; $ahead = [int]$parts[1] }
        }
    }

    $pkg = $null; $framework = $null; $packageManager = $null
    $packagePath = Join-Path $path 'package.json'
    if (Test-Path $packagePath) {
        try { $pkg = Get-Content $packagePath -Raw | ConvertFrom-Json } catch {}
        if (Test-Path (Join-Path $path 'pnpm-lock.yaml')) { $packageManager = 'pnpm' }
        elseif (Test-Path (Join-Path $path 'yarn.lock')) { $packageManager = 'yarn' }
        elseif (Test-Path (Join-Path $path 'package-lock.json')) { $packageManager = 'npm' }
        elseif ($pkg.packageManager) { $packageManager = [string]$pkg.packageManager }
        if ($pkg.dependencies.next -or $pkg.devDependencies.next) { $framework = 'Next.js' }
        elseif ($pkg.dependencies.vite -or $pkg.devDependencies.vite) { $framework = 'Vite' }
        elseif ($pkg.dependencies.react -or $pkg.devDependencies.react) { $framework = 'React' }
        else { $framework = 'Node.js' }
    }

    [pscustomobject]@{
        Repository     = Split-Path $path -Leaf
        Path           = $path
        HasGit         = $hasGit
        Branch         = $branch
        GitRemote      = $remote
        Clean          = if ($hasGit) { [string]::IsNullOrWhiteSpace(($statusText -join '')) } else { $null }
        Ahead          = $ahead
        Behind         = $behind
        LastCommit     = $lastCommit
        Framework      = $framework
        PackageManager = $packageManager
        HasVercel      = Test-Path (Join-Path $path '.vercel')
        HasPackageJson = Test-Path $packagePath
        LastModified   = (Get-Item $path).LastWriteTime
    }
}