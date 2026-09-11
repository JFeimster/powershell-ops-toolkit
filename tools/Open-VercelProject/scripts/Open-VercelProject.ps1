function Open-VercelProject {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository,
        [ValidateSet('Dashboard','Production')]
        [string]$Target = 'Dashboard',
        [switch]$PassThru
    )

    $links = if (Get-Command Get-ProjectLinks -ErrorAction SilentlyContinue) { Get-ProjectLinks $Repository } else { $null }
    if (-not $links) { throw 'Get-ProjectLinks must be available.' }

    $url = $null
    if ($Target -eq 'Production') {
        $url = $links.ProductionUrl
        if (-not $url -and $links.VercelProject) { $url = "https://$($links.VercelProject).vercel.app" }
    } else {
        if ($links.VercelProject) { $url = "https://vercel.com/dashboard?search=$([uri]::EscapeDataString([string]$links.VercelProject))" }
        else { $url = 'https://vercel.com/dashboard' }
    }

    if (-not $url) { throw "No Vercel target could be resolved for '$Repository'." }
    if ($PSCmdlet.ShouldProcess($url, "Open Vercel $Target")) { Start-Process $url }
    if ($PassThru) { $url }
}