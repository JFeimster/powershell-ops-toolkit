function Search-MyStack {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Query,
        [string[]]$Source = @('LocalAssets','GitHub'),
        [int]$MaxResults = 100
    )

    $results = [System.Collections.Generic.List[object]]::new()

    if ('LocalAssets' -in $Source -and (Get-Command Find-ProjectAsset -ErrorAction SilentlyContinue)) {
        foreach ($r in @(Find-ProjectAsset -Query $Query -MaxResults $MaxResults -ErrorAction SilentlyContinue)) {
            $results.Add([pscustomobject]@{
                Source = 'LocalAssets'
                Name = Split-Path $r.File -Leaf
                Path = $r.File
                Url = $null
                Detail = $r.Match
                Score = 100
            })
        }
    }

    if ('GitHub' -in $Source -and (Get-Command gh -ErrorAction SilentlyContinue)) {
        try {
            $json = & gh search repos $Query --limit $MaxResults --json fullName,url,description,updatedAt 2>$null
            if ($LASTEXITCODE -eq 0 -and $json) {
                foreach ($repo in @($json | ConvertFrom-Json)) {
                    $results.Add([pscustomobject]@{
                        Source = 'GitHub'
                        Name = $repo.fullName
                        Path = $null
                        Url = $repo.url
                        Detail = $repo.description
                        Score = 80
                    })
                }
            }
        } catch {}
    }

    $results |
        Sort-Object @{Expression='Score';Descending=$true}, @{Expression='Name';Descending=$false} |
        Select-Object -First $MaxResults
}