function Get-WixDraftQueue {
    [CmdletBinding()]
    param(
        [string]$SourcePath,
        [object[]]$InputObject,
        [int]$StaleDays = 30
    )

    $items = @()
    if ($InputObject) {
        $items = @($InputObject)
    } elseif ($SourcePath) {
        if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) { throw "Source file not found: $SourcePath" }
        $raw = Get-Content -LiteralPath $SourcePath -Raw
        if ($SourcePath -match '\.json$') { $items = @($raw | ConvertFrom-Json) }
        elseif ($SourcePath -match '\.csv$') { $items = @(Import-Csv -LiteralPath $SourcePath) }
        else { throw 'Supported source formats are JSON and CSV.' }
    } elseif ($env:WIX_DRAFT_EXPORT -and (Test-Path -LiteralPath $env:WIX_DRAFT_EXPORT)) {
        return Get-WixDraftQueue -SourcePath $env:WIX_DRAFT_EXPORT -StaleDays $StaleDays
    } else {
        throw 'Provide -SourcePath or -InputObject. Direct Wix API access is intentionally not assumed by this PowerShell helper.'
    }

    $cutoff = (Get-Date).AddDays(-$StaleDays)
    $results = foreach ($item in $items) {
        $status = [string]($item.status ?? $item.publishStatus ?? $item.state)
        $updatedRaw = $item.updatedDate ?? $item.updatedAt ?? $item.lastUpdated
        $updated = $null
        if ($updatedRaw) {
            $parsed = [datetime]::MinValue
            if ([datetime]::TryParse([string]$updatedRaw, [ref]$parsed)) { $updated = $parsed }
        }
        $title = [string]($item.title ?? $item.name)
        $meta = [string]($item.metaDescription ?? $item.seoDescription)
        $featured = $item.featuredImage ?? $item.image
        $isDraft = $status -match 'draft|unpublished|pending'
        if (-not $isDraft) { continue }
        [pscustomobject]@{
            Title = $title
            Status = $status
            UpdatedAt = $updated
            Stale = [bool]($updated -and $updated -lt $cutoff)
            MissingMetaDescription = [string]::IsNullOrWhiteSpace($meta)
            MissingFeaturedImage = -not [bool]$featured
            Slug = $item.slug
            Id = $item.id ?? $item._id
        }
    }

    $results | Sort-Object @{Expression='Stale';Descending=$true}, UpdatedAt
}