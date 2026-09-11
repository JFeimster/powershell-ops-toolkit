function Find-ContentGap {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Topic,
        [string[]]$Source,
        [int]$MaxMatches = 25
    )

    if (-not (Get-Command Get-ContentInventory -ErrorAction SilentlyContinue)) { throw 'Get-ContentInventory must be available.' }
    $inventory = if ($Source) { @(Get-ContentInventory -Source $Source -Query $Topic) } else { @(Get-ContentInventory -Query $Topic) }

    $tokens = @($Topic.ToLowerInvariant() -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 3 } | Select-Object -Unique)
    $scored = foreach ($item in $inventory) {
        $haystack = "$($item.Title) $($item.Path) $($item.Url)".ToLowerInvariant()
        $hits = @($tokens | Where-Object { $haystack.Contains($_) }).Count
        $score = if ($tokens.Count) { [math]::Round(($hits / $tokens.Count) * 100, 1) } else { 0 }
        [pscustomobject]@{ Score=$score; Title=$item.Title; Type=$item.Type; Path=$item.Path; Url=$item.Url }
    }
    $top = @($scored | Sort-Object Score -Descending | Select-Object -First $MaxMatches)
    $max = if ($top.Count) { [double]$top[0].Score } else { 0 }

    [pscustomobject]@{
        Topic = $Topic
        ExistingMatchCount = $inventory.Count
        HighestSimilarity = $max
        Recommendation = if ($max -ge 80) { 'Likely overlap/cannibalization; differentiate or update existing content.' } elseif ($max -ge 50) { 'Related coverage exists; target a narrower angle and cross-link.' } else { 'Clear content gap candidate.' }
        Matches = $top
    }
}