function Compare-RepoCopies {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository
    )

    if (-not (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue)) {
        throw 'Find-LocalRepo must be loaded before Compare-RepoCopies can run.'
    }

    $matches = @(Find-LocalRepo $Repository -All)
    foreach ($m in $matches) {
        $branch = $lastCommit = $dirty = $fileCount = $null
        if ($m.Path -and (Test-Path -LiteralPath $m.Path -PathType Container)) {
            try { $fileCount = (Get-ChildItem -LiteralPath $m.Path -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count } catch {}
            if ($m.HasGit) {
                $branch = (& git -C $m.Path branch --show-current 2>$null)
                $lastCommit = (& git -C $m.Path log -1 --format='%H|%ad|%s' --date=iso-strict 2>$null)
                $dirty = -not [string]::IsNullOrWhiteSpace(((& git -C $m.Path status --porcelain 2>$null) -join ''))
            }
        }
        [pscustomobject]@{
            Confidence   = $m.Confidence
            Path         = $m.Path
            HasGit       = $m.HasGit
            GitRemote    = $m.GitRemote
            Branch       = $branch
            Dirty        = $dirty
            LastCommit   = $lastCommit
            FileCount    = $fileCount
            LastModified = $m.LastModified
            MatchReason  = $m.MatchReason
        }
    }
}