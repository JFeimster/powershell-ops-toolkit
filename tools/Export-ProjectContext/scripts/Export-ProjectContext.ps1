function Export-ProjectContext {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [ValidateSet('Markdown','Json')]
        [string]$Format = 'Markdown',
        [string]$OutputPath,
        [switch]$PassThru
    )

    $status = if (Get-Command Get-ProjectStatus -ErrorAction SilentlyContinue) { Get-ProjectStatus $Repository } else { $null }
    if (-not $status) { throw 'Get-ProjectStatus must be available to export project context.' }
    $path = $status.Path

    $links = if (Get-Command Get-ProjectLinks -ErrorAction SilentlyContinue) { Get-ProjectLinks $path } else { $null }
    $routes = if (Get-Command Get-SiteRoutes -ErrorAction SilentlyContinue) { @(Get-SiteRoutes $path -ErrorAction SilentlyContinue) } else { @() }
    $changed = if (Get-Command Get-ChangedFiles -ErrorAction SilentlyContinue) { @(Get-ChangedFiles $path -ErrorAction SilentlyContinue) } else { @() }

    $important = @('README.md','package.json','next.config.js','next.config.mjs','next.config.ts','vercel.json','tsconfig.json') |
        ForEach-Object { $p = Join-Path $path $_; if (Test-Path $p) { $_ } }

    $context = [ordered]@{
        generatedAt = (Get-Date).ToString('o')
        repository  = $status.Repository
        path        = $path
        status      = $status
        links       = $links
        importantFiles = @($important)
        routes      = @($routes)
        changedFiles = @($changed)
    }

    if (-not $OutputPath) {
        $ext = if ($Format -eq 'Json') { 'json' } else { 'md' }
        $OutputPath = Join-Path $path ("project-context.$ext")
    }

    if ($Format -eq 'Json') {
        $text = $context | ConvertTo-Json -Depth 8
    } else {
        $lines = @(
            "# Project Context: $($status.Repository)",
            '',
            "Generated: $($context.generatedAt)",
            ('Local path: `{0}`' -f $path),
            "Branch: $($status.Branch)",
            "Git remote: $($status.GitRemote)",
            "Framework: $($status.Framework)",
            "Package manager: $($status.PackageManager)",
            "Clean: $($status.Clean)",
            '',
            '## Links',
            "- GitHub: $($links.GitHub)",
            "- Production: $($links.ProductionUrl)",
            "- Vercel project: $($links.VercelProject)",
            '',
            '## Important files'
        ) + (@($important) | ForEach-Object { "- $_" }) + @('', '## Routes') + (@($routes) | ForEach-Object { "- $($_.Route)" }) + @('', '## Changed files') + (@($changed) | ForEach-Object { "- $($_.Status) $($_.Path)" })
        $text = $lines -join [Environment]::NewLine
    }

    Set-Content -LiteralPath $OutputPath -Value $text -Encoding utf8
    if ($PassThru) { [pscustomobject]@{ Path=$OutputPath; Format=$Format; Context=[pscustomobject]$context } }
    else { Get-Item -LiteralPath $OutputPath }
}
