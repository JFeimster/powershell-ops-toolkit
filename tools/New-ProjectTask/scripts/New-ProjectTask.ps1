function New-ProjectTask {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [Parameter(Mandatory)]
        [string]$Title,
        [string]$Body,
        [string[]]$Labels,
        [switch]$Create
    )

    $repoName = $Repository
    if (Test-Path -LiteralPath $Repository -PathType Container) {
        $remote = (& git -C $Repository remote get-url origin 2>$null)
        if ($remote) { $repoName = $remote -replace '^git@github\.com:', '' -replace '^https://github\.com/', '' -replace '\.git$', '' }
    } elseif ($Repository -match '^https?://github\.com/([^/]+)/([^/]+)') {
        $repoName = "$($Matches[1])/$($Matches[2] -replace '\.git$','')"
    }

    if (-not $Body) {
        $Body = @"
## Task
$Title

## Context
Repository: $repoName
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')

## Acceptance Criteria
- [ ] Define implementation details
- [ ] Validate locally
- [ ] Document result
"@
    }

    $preview = [pscustomobject]@{
        Repository = $repoName
        Title      = $Title
        Body       = $Body
        Labels     = @($Labels)
        WillCreate = [bool]$Create
    }

    if (-not $Create) { return $preview }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI 'gh' is required to create an issue." }

    $args = @('issue','create','--repo',$repoName,'--title',$Title,'--body',$Body)
    foreach ($label in $Labels) { $args += @('--label',$label) }
    if ($PSCmdlet.ShouldProcess($repoName, "Create GitHub issue '$Title'")) {
        $url = & gh @args
        if ($LASTEXITCODE -ne 0) { throw 'GitHub issue creation failed.' }
        [pscustomobject]@{ Repository=$repoName; Title=$Title; Url=($url | Select-Object -Last 1); Created=$true }
    }
}