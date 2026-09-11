function Get-WorkQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository,
        [int]$Limit = 50
    )

    $repoName = $Repository
    if (Test-Path -LiteralPath $Repository -PathType Container) {
        $remote = (& git -C $Repository remote get-url origin 2>$null)
        if ($remote) { $repoName = ($remote -replace '^git@github\.com:', '' -replace '^https://github\.com/', '' -replace '\.git$', '') }
    } elseif ($Repository -match 'github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?$') {
        $repoName = "$($Matches[1])/$($Matches[2])"
    }

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI 'gh' is required for Get-WorkQueue." }

    $issuesJson = & gh issue list --repo $repoName --state open --limit $Limit --json number,title,labels,assignees,updatedAt,url 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Unable to read issues for $repoName. Check gh authentication and repository access." }
    $prsJson = & gh pr list --repo $repoName --state open --limit $Limit --json number,title,labels,updatedAt,url,isDraft,reviewDecision 2>$null

    $items = @()
    if ($issuesJson) {
        $items += (ConvertFrom-Json $issuesJson) | ForEach-Object {
            $labels = @($_.labels | ForEach-Object name)
            $priority = if ($labels -match 'priority[: -]?1|urgent|critical|high') { 1 } elseif ($labels -match 'priority[: -]?2|medium') { 2 } else { 3 }
            [pscustomobject]@{ Type='Issue'; Number=$_.number; Title=$_.title; Priority=$priority; Labels=($labels -join ', '); UpdatedAt=$_.updatedAt; Url=$_.url }
        }
    }
    if ($prsJson) {
        $items += (ConvertFrom-Json $prsJson) | ForEach-Object {
            $labels = @($_.labels | ForEach-Object name)
            $priority = if ($_.reviewDecision -eq 'CHANGES_REQUESTED') { 1 } elseif ($_.isDraft) { 3 } else { 2 }
            [pscustomobject]@{ Type='PR'; Number=$_.number; Title=$_.title; Priority=$priority; Labels=($labels -join ', '); UpdatedAt=$_.updatedAt; Url=$_.url }
        }
    }
    $items | Sort-Object Priority, @{Expression={[datetime]$_.UpdatedAt}; Descending=$true}
}