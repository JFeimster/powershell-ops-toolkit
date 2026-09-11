function Get-DeploymentStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository
    )

    $status = if (Get-Command Get-ProjectStatus -ErrorAction SilentlyContinue) { Get-ProjectStatus $Repository } else { $null }
    if (-not $status) { throw 'Get-ProjectStatus must be available.' }
    $path = $status.Path

    $localHead = if ($status.HasGit) { (& git -C $path rev-parse HEAD 2>$null) } else { $null }
    $remoteHead = $null
    if ($status.HasGit) {
        $remoteBranch = if ($status.Branch) { "origin/$($status.Branch)" } else { 'origin/HEAD' }
        $remoteHead = (& git -C $path rev-parse $remoteBranch 2>$null)
    }

    $vercelProject = $null; $latestDeployment = $null; $deploymentState = $null
    $metaPath = Join-Path $path '.vercel\project.json'
    if (Test-Path $metaPath) {
        try {
            $meta = Get-Content $metaPath -Raw | ConvertFrom-Json
            $vercelProject = $meta.projectName ?? $meta.projectId
        } catch {}
    }

    if ((Get-Command vercel -ErrorAction SilentlyContinue) -and $vercelProject) {
        try {
            $raw = & vercel ls $vercelProject --json 2>$null
            if ($LASTEXITCODE -eq 0 -and $raw) {
                $json = $raw | ConvertFrom-Json
                $latest = @($json.deployments ?? $json) | Select-Object -First 1
                if ($latest) {
                    $latestDeployment = $latest.url
                    $deploymentState = $latest.state ?? $latest.readyState
                }
            }
        } catch {}
    }

    [pscustomobject]@{
        Repository       = $status.Repository
        Path             = $path
        Branch           = $status.Branch
        LocalHead        = $localHead
        RemoteHead       = $remoteHead
        LocalMatchesRemote = [bool]($localHead -and $remoteHead -and $localHead -eq $remoteHead)
        VercelProject    = $vercelProject
        LatestDeployment = $latestDeployment
        DeploymentState  = $deploymentState
        Note             = if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) { 'Vercel CLI not found; deployment details unavailable.' } elseif (-not $vercelProject) { 'No .vercel project metadata found.' } else { $null }
    }
}