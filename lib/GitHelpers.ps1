function Get-NormalizedGitHubIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Value)

    $normalized = $Value.Trim() -replace '\\.git$',''
    $normalized = $normalized -replace '^git@github\.com:','https://github.com/'
    $normalized = $normalized -replace '^ssh://git@github\.com/','https://github.com/'
    $normalized = $normalized -replace '^http://github\.com/','https://github.com/'

    if ($normalized -match '^https://github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)$') {
        return [pscustomobject]@{
            Owner = $Matches.owner
            Repo = $Matches.repo
            Repository = "$($Matches.owner)/$($Matches.repo)"
            CanonicalUrl = "https://github.com/$($Matches.owner)/$($Matches.repo)"
        }
    }

    if ($normalized -match '^(?<owner>[^/]+)/(?<repo>[^/]+)$') {
        return [pscustomobject]@{
            Owner = $Matches.owner
            Repo = $Matches.repo
            Repository = "$($Matches.owner)/$($Matches.repo)"
            CanonicalUrl = "https://github.com/$($Matches.owner)/$($Matches.repo)"
        }
    }

    return [pscustomobject]@{
        Owner = $null
        Repo = $normalized
        Repository = $normalized
        CanonicalUrl = $null
    }
}

function Get-GitOriginUrl {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path (Join-Path $Path '.git'))) { return $null }
    try {
        $value = git -C $Path remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0) { return ($value | Select-Object -First 1).Trim() }
    } catch { }
    return $null
}
