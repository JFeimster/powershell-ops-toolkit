function Open-GitHubRepo {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository,
        [switch]$PassThru
    )

    $url = $null
    if ($Repository -match '^https?://github\.com/[^/]+/[^/]+') {
        $url = ($Repository -replace '\.git$', '')
    } elseif (Test-Path -LiteralPath $Repository -PathType Container) {
        $remote = (& git -C $Repository remote get-url origin 2>$null)
        if ($remote) { $url = $remote -replace '^git@github\.com:', 'https://github.com/' -replace '\.git$', '' }
    } elseif ($Repository -match '^[^/]+/[^/]+$') {
        $url = "https://github.com/$Repository"
    } elseif (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue) {
        $m = Find-LocalRepo $Repository | Select-Object -First 1
        if ($m.GitRemote) { $url = $m.GitRemote -replace '^git@github\.com:', 'https://github.com/' -replace '\.git$', '' }
    }
    if (-not $url) { throw "Could not resolve a GitHub URL for '$Repository'." }
    if ($PSCmdlet.ShouldProcess($url,'Open GitHub repository')) { Start-Process $url }
    if ($PassThru) { $url }
}