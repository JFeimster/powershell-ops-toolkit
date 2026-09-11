function Get-SiteRoutes {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.'
    )

    $path = $Repository
    if (-not (Test-Path -LiteralPath $path -PathType Container) -and (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue)) {
        $m = Find-LocalRepo $Repository | Select-Object -First 1
        if ($m) { $path = $m.Path }
    }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Project not found: $Repository" }
    $path = (Resolve-Path -LiteralPath $path).Path

    $roots = @(
        @{ Dir = Join-Path $path 'app'; Kind='AppRouter' },
        @{ Dir = Join-Path $path 'src\app'; Kind='AppRouter' },
        @{ Dir = Join-Path $path 'pages'; Kind='PagesRouter' },
        @{ Dir = Join-Path $path 'src\pages'; Kind='PagesRouter' }
    )

    foreach ($root in $roots) {
        if (-not (Test-Path $root.Dir)) { continue }
        $files = Get-ChildItem $root.Dir -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^(page|index)\.(js|jsx|ts|tsx|mdx)$' }
        foreach ($file in $files) {
            $relDir = $file.Directory.FullName.Substring($root.Dir.Length).TrimStart('\','/')
            if ($root.Kind -eq 'AppRouter') {
                $segments = @($relDir -split '[\\/]' | Where-Object { $_ -and $_ -notmatch '^\(.*\)$' })
                $route = '/' + ($segments -join '/')
            } else {
                $rel = $file.FullName.Substring($root.Dir.Length).TrimStart('\','/') -replace '\\','/'
                $route = '/' + ($rel -replace '/?index\.(js|jsx|ts|tsx|mdx)$','' -replace '\.(js|jsx|ts|tsx|mdx)$','')
            }
            if ($route -eq '') { $route = '/' }
            [pscustomobject]@{
                Route = $route
                Router = $root.Kind
                File = $file.FullName
                Dynamic = $route -match '\[[^\]]+\]'
            }
        }
    } | Sort-Object Route -Unique
}