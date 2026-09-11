function Open-Project {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository,

        [ValidateSet('Code','Explorer')]
        [string]$OpenWith = 'Code',

        [switch]$GitHub,
        [switch]$PassThru
    )

    $match = $null
    if (Get-Command Find-LocalRepo -ErrorAction SilentlyContinue) {
        $match = Find-LocalRepo $Repository | Select-Object -First 1
    }

    if (-not $match) {
        if (Test-Path -LiteralPath $Repository -PathType Container) {
            $resolved = (Resolve-Path -LiteralPath $Repository).Path
            $match = [pscustomobject]@{ Path = $resolved; Repository = (Split-Path $resolved -Leaf); GitRemote = $null }
        } else {
            throw "No local project found for '$Repository'. Load Find-LocalRepo or provide a valid local directory."
        }
    }

    $path = $match.Path
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Resolved project path does not exist: $path"
    }

    if ($PSCmdlet.ShouldProcess($path, "Open project with $OpenWith")) {
        if ($OpenWith -eq 'Code') {
            $code = Get-Command code -ErrorAction SilentlyContinue
            if ($code) { & $code.Source $path }
            else { throw "VS Code CLI 'code' was not found in PATH." }
        } else {
            Start-Process explorer.exe -ArgumentList @($path)
        }
    }

    if ($GitHub) {
        $remote = $match.GitRemote
        if (-not $remote -and (Test-Path (Join-Path $path '.git'))) {
            $remote = (& git -C $path remote get-url origin 2>$null)
        }
        if ($remote) {
            $url = $remote -replace '^git@github\.com:', 'https://github.com/' -replace '\.git$', ''
            if ($PSCmdlet.ShouldProcess($url, 'Open GitHub repository')) { Start-Process $url }
        }
    }

    if ($PassThru) { $match }
}