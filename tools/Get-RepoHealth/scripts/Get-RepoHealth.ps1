function Get-RepoHealth {
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

    $issues = [System.Collections.Generic.List[object]]::new()
    $lockfiles = @('package-lock.json','pnpm-lock.yaml','yarn.lock') | Where-Object { Test-Path (Join-Path $path $_) }
    if ($lockfiles.Count -gt 1) { $issues.Add([pscustomobject]@{ Severity='WARN'; Check='Lockfiles'; Message="Multiple lockfiles found: $($lockfiles -join ', ')" }) }
    if (-not (Test-Path (Join-Path $path '.git'))) { $issues.Add([pscustomobject]@{ Severity='WARN'; Check='Git'; Message='No .git directory found.' }) }
    if ((Test-Path (Join-Path $path 'package.json')) -and -not $lockfiles) { $issues.Add([pscustomobject]@{ Severity='INFO'; Check='Lockfiles'; Message='package.json exists but no recognized lockfile was found.' }) }
    foreach ($dir in @('.next','dist','build','coverage')) {
        $p = Join-Path $path $dir
        if (Test-Path $p) { $issues.Add([pscustomobject]@{ Severity='INFO'; Check='Artifacts'; Message="$dir exists locally." }) }
    }
    if (Test-Path (Join-Path $path '.git')) {
        $dirty = (& git -C $path status --porcelain 2>$null)
        if ($dirty) { $issues.Add([pscustomobject]@{ Severity='INFO'; Check='Git'; Message="Working tree has $(@($dirty).Count) changed/untracked item(s)." }) }
        $remote = (& git -C $path remote get-url origin 2>$null)
        if (-not $remote) { $issues.Add([pscustomobject]@{ Severity='WARN'; Check='Git'; Message='No origin remote is configured.' }) }
    }
    if (-not (Test-Path (Join-Path $path '.gitignore'))) { $issues.Add([pscustomobject]@{ Severity='INFO'; Check='GitIgnore'; Message='No .gitignore found.' }) }

    [pscustomobject]@{
        Repository = Split-Path $path -Leaf
        Path       = $path
        Healthy    = (@($issues | Where-Object Severity -eq 'WARN').Count -eq 0)
        Lockfiles  = $lockfiles
        Issues     = @($issues)
        IssueCount = $issues.Count
    }
}