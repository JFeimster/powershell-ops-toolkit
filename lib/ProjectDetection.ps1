function Get-ProjectMetadata {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    $resolved = Resolve-ExistingPath -Path $Path
    if (-not $resolved) { throw "Path not found: $Path" }

    $packageJson = Join-Path $resolved 'package.json'
    $framework = $null
    $packageManager = $null

    if (Test-Path (Join-Path $resolved 'pnpm-lock.yaml')) { $packageManager = 'pnpm' }
    elseif (Test-Path (Join-Path $resolved 'yarn.lock')) { $packageManager = 'yarn' }
    elseif (Test-Path (Join-Path $resolved 'package-lock.json')) { $packageManager = 'npm' }

    if (Test-Path $packageJson) {
        try {
            $pkg = Get-Content $packageJson -Raw | ConvertFrom-Json
            $deps = @($pkg.dependencies.PSObject.Properties.Name) + @($pkg.devDependencies.PSObject.Properties.Name)
            if ($deps -contains 'next') { $framework = 'Next.js' }
            elseif ($deps -contains 'vite') { $framework = 'Vite' }
            elseif ($deps -contains 'react') { $framework = 'React' }
        } catch { }
    }

    [pscustomobject]@{
        Path = $resolved
        Name = Split-Path $resolved -Leaf
        HasGit = Test-Path (Join-Path $resolved '.git')
        HasPackageJson = Test-Path $packageJson
        PackageManager = $packageManager
        Framework = $framework
        HasVercelConfig = Test-Path (Join-Path $resolved 'vercel.json')
    }
}
