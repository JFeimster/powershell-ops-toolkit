function Open-ProjectStack {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository,
        [switch]$NoCode,
        [switch]$NoBrowser,
        [switch]$PassThru
    )

    $links = if (Get-Command Get-ProjectLinks -ErrorAction SilentlyContinue) {
        Get-ProjectLinks $Repository
    } else { $null }

    if (-not $NoCode -and (Get-Command Open-Project -ErrorAction SilentlyContinue)) {
        Open-Project $Repository -OpenWith Code
    }

    if (-not $NoBrowser -and $links) {
        foreach ($url in @($links.GitHub, $links.ProductionUrl)) {
            if ($url -and $PSCmdlet.ShouldProcess($url, 'Open in browser')) { Start-Process $url }
        }
        if ($links.VercelProject) {
            $vurl = "https://vercel.com/dashboard?search=$([uri]::EscapeDataString([string]$links.VercelProject))"
            if ($PSCmdlet.ShouldProcess($vurl, 'Open Vercel dashboard search')) { Start-Process $vurl }
        }
    }

    if ($PassThru) { $links }
}