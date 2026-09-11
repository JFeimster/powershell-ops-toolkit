function Test-SiteRoutes {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.'
    )

    if (-not (Get-Command Get-SiteRoutes -ErrorAction SilentlyContinue)) { throw 'Get-SiteRoutes must be available.' }
    $routes = @(Get-SiteRoutes $Repository)
    $issues = [System.Collections.Generic.List[object]]::new()

    $duplicates = $routes | Group-Object Route | Where-Object Count -gt 1
    foreach ($d in $duplicates) {
        $issues.Add([pscustomobject]@{ Severity='WARN'; Route=$d.Name; Check='DuplicateRoute'; Message="Route appears $($d.Count) times." })
    }

    foreach ($r in $routes) {
        if (-not (Test-Path -LiteralPath $r.File -PathType Leaf)) {
            $issues.Add([pscustomobject]@{ Severity='ERROR'; Route=$r.Route; Check='MissingFile'; Message="Backing file missing: $($r.File)" })
        }
        if ($r.Route -match '//') {
            $issues.Add([pscustomobject]@{ Severity='WARN'; Route=$r.Route; Check='MalformedRoute'; Message='Route contains a double slash.' })
        }
    }

    [pscustomobject]@{
        RouteCount = $routes.Count
        IssueCount = $issues.Count
        Passed     = ($issues.Count -eq 0)
        Issues     = @($issues)
        Routes     = $routes
    }
}