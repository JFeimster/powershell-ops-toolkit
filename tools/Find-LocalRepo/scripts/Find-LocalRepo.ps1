#requires -Version 5.1
Set-StrictMode -Version Latest

function Get-LocalRepoFinderConfig {
    [CmdletBinding()]
    param()

    # Resolve the config from the physical file that defined Find-LocalRepo.
    # This remains stable when the script is dot-sourced from a profile or
    # called from another script/test scope.
    $functionInfo = Get-Command Find-LocalRepo -CommandType Function -ErrorAction Stop
    $sourceFile = $functionInfo.ScriptBlock.File

    if ([string]::IsNullOrWhiteSpace($sourceFile)) {
        throw 'Could not determine the Find-LocalRepo source file.'
    }

    $toolRoot = Split-Path -Parent (Split-Path -Parent $sourceFile)
    $configPath = Join-Path $toolRoot 'config\LocalRepoFinder.psd1'

    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Local Repo Finder config not found: $configPath"
    }

    Import-PowerShellDataFile -LiteralPath $configPath
}

function ConvertTo-GitHubRepoIdentity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InputValue
    )

    $value = $InputValue.Trim()
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw 'Repository input cannot be empty.'
    }

    $owner = $null
    $repo = $null

    # git@github.com:Owner/Repo.git
    if ($value -match '^(?i)git@github\.com:(?<owner>[^/]+)/(?<repo>[^/]+?)(?:\.git)?$') {
        $owner = $Matches.owner
        $repo = $Matches.repo
    }
    # ssh://git@github.com/Owner/Repo.git or https://github.com/Owner/Repo(.git)
    elseif ($value -match '^(?i)(?:https?://|ssh://git@)github\.com[:/](?<owner>[^/]+)/(?<repo>[^/#?]+?)(?:\.git)?(?:[/?#].*)?$') {
        $owner = $Matches.owner
        $repo = $Matches.repo
    }
    # Owner/Repo or Owner/Repo.git
    elseif ($value -match '^(?<owner>[^/\\:]+)/(?<repo>[^/\\]+?)(?:\.git)?$') {
        $owner = $Matches.owner
        $repo = $Matches.repo
    }
    else {
        $repo = $value -replace '(?i)\.git$', ''
        $repo = Split-Path -Leaf $repo
    }

    $repo = $repo.Trim()
    if ([string]::IsNullOrWhiteSpace($repo)) {
        throw "Could not determine repository name from '$InputValue'."
    }

    $repository = if ($owner) { "$owner/$repo" } else { $repo }
    $canonical = if ($owner) { "https://github.com/$owner/$repo" } else { $null }

    [pscustomobject]@{
        Owner        = $owner
        Repo         = $repo
        Repository   = $repository
        CanonicalUrl = $canonical
    }
}

function ConvertTo-GitHubRemoteIdentity {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$Remote
    )

    if ([string]::IsNullOrWhiteSpace($Remote)) { return $null }

    $value = $Remote.Trim()
    $owner = $null
    $repo = $null

    if ($value -match '^(?i)git@github\.com:(?<owner>[^/]+)/(?<repo>[^/]+?)(?:\.git)?$') {
        $owner = $Matches.owner
        $repo = $Matches.repo
    }
    elseif ($value -match '^(?i)(?:https?://|ssh://git@)github\.com[:/](?<owner>[^/]+)/(?<repo>[^/#?]+?)(?:\.git)?(?:[/?#].*)?$') {
        $owner = $Matches.owner
        $repo = $Matches.repo
    }
    elseif ($value -match '^(?i)git://github\.com/(?<owner>[^/]+)/(?<repo>[^/]+?)(?:\.git)?$') {
        $owner = $Matches.owner
        $repo = $Matches.repo
    }

    if (-not $owner -or -not $repo) { return $null }

    [pscustomobject]@{
        Owner        = $owner
        Repo         = $repo
        Repository   = "$owner/$repo"
        CanonicalUrl = "https://github.com/$owner/$repo"
    }
}

function Get-GitOriginUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return $null }

    try {
        $remote = & git -C $Path remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0 -and $remote) {
            return ($remote | Select-Object -First 1).Trim()
        }
    }
    catch { }

    return $null
}

function Get-LocalRepoCandidateDirectories {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$SearchRoots,

        [Parameter(Mandatory)]
        [string]$RepoName,

        [Parameter(Mandatory)]
        [string[]]$ExcludedDirectories
    )

    $excluded = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($name in $ExcludedDirectories) { [void]$excluded.Add($name) }

    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $results = [System.Collections.Generic.List[object]]::new()

    foreach ($root in $SearchRoots) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }

        $queue = [System.Collections.Generic.Queue[System.IO.DirectoryInfo]]::new()
        try { $queue.Enqueue([System.IO.DirectoryInfo]::new($root)) } catch { continue }

        while ($queue.Count -gt 0) {
            $dir = $queue.Dequeue()
            if ($excluded.Contains($dir.Name)) { continue }

            $hasGit = Test-Path -LiteralPath (Join-Path $dir.FullName '.git')
            $nameExact = $dir.Name.Equals($RepoName, [System.StringComparison]::OrdinalIgnoreCase)
            $nameFuzzy = -not $nameExact -and $dir.Name.IndexOf($RepoName, [System.StringComparison]::OrdinalIgnoreCase) -ge 0

            # Every Git repo is a candidate because a clone can be renamed locally.
            if ($hasGit -or $nameExact -or $nameFuzzy) {
                if ($seen.Add($dir.FullName)) {
                    $results.Add([pscustomobject]@{
                        Directory  = $dir
                        SearchRoot = $root
                        HasGit     = $hasGit
                        NameExact  = $nameExact
                        NameFuzzy  = $nameFuzzy
                    })
                }
            }

            try {
                foreach ($child in $dir.EnumerateDirectories()) {
                    if (-not $excluded.Contains($child.Name)) {
                        $queue.Enqueue($child)
                    }
                }
            }
            catch {
                # Access denied / transient filesystem errors are skipped deliberately.
            }
        }
    }

    $results
}

function Get-LocalRepoRankedMatches {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Identity,

        [Parameter(Mandatory)]
        [string[]]$SearchRoots,

        [Parameter(Mandatory)]
        [string[]]$ExcludedDirectories
    )

    $candidates = Get-LocalRepoCandidateDirectories -SearchRoots $SearchRoots -RepoName $Identity.Repo -ExcludedDirectories $ExcludedDirectories
    $matches = [System.Collections.Generic.List[object]]::new()

    foreach ($candidate in $candidates) {
        $gitRemote = $null
        $remoteIdentity = $null
        if ($candidate.HasGit) {
            $gitRemote = Get-GitOriginUrl -Path $candidate.Directory.FullName
            $remoteIdentity = ConvertTo-GitHubRemoteIdentity -Remote $gitRemote
        }

        $confidence = 'LOW'
        $score = 100
        $reason = 'Partial/fuzzy folder-name match'

        $remoteRepoMatches = $remoteIdentity -and $remoteIdentity.Repo.Equals($Identity.Repo, [System.StringComparison]::OrdinalIgnoreCase)
        $remoteOwnerMatches = $Identity.Owner -and $remoteIdentity -and $remoteIdentity.Owner.Equals($Identity.Owner, [System.StringComparison]::OrdinalIgnoreCase)
        $remoteExact = [bool]($Identity.Owner -and $remoteRepoMatches -and $remoteOwnerMatches)

        if ($remoteExact) {
            $confidence = 'EXACT'
            $score = 400
            $reason = "Exact GitHub origin match: $($remoteIdentity.Repository)"
        }
        elseif ($candidate.NameExact -and $candidate.HasGit) {
            $confidence = 'HIGH'
            $score = 300

            if ($remoteRepoMatches) {
                if ($Identity.Owner -and $remoteIdentity.Owner -and -not $remoteOwnerMatches) {
                    $reason = "Folder and repo name match, but Git origin owner is '$($remoteIdentity.Owner)' instead of '$($Identity.Owner)'"
                }
                elseif (-not $Identity.Owner) {
                    $reason = "Folder name and Git origin repo match '$($Identity.Repo)'; owner was not supplied, so exact owner/repo verification is not possible"
                }
                else {
                    $reason = "Folder name and Git origin repo match '$($Identity.Repo)'; owner could not be verified exactly"
                }
                $score += 20
            }
            elseif ($gitRemote -and $remoteIdentity) {
                $requested = if ($Identity.Owner) { "$($Identity.Owner)/$($Identity.Repo)" } else { $Identity.Repo }
                $reason = "Folder name matches '$($Identity.Repo)', but Git origin points to '$($remoteIdentity.Repository)' instead of '$requested'"
            }
            elseif ($gitRemote) {
                $reason = "Folder name matches '$($Identity.Repo)' and .git exists, but origin '$gitRemote' is not a recognized GitHub repository URL"
            }
            else {
                $reason = "Folder name matches '$($Identity.Repo)' and .git exists, but origin is missing or unreadable"
            }
        }
        elseif ($candidate.NameExact) {
            $confidence = 'MEDIUM'
            $score = 200
            if ($Identity.Owner) {
                $reason = "Folder name matches '$($Identity.Repo)', but no .git metadata exists; requested GitHub identity '$($Identity.Owner)/$($Identity.Repo)' cannot be verified"
            }
            else {
                $reason = "Folder name matches '$($Identity.Repo)', but no .git metadata exists; GitHub identity cannot be verified"
            }
        }
        elseif ($candidate.HasGit -and $remoteRepoMatches) {
            $confidence = 'HIGH'
            $score = 280
            if ($Identity.Owner -and $remoteIdentity.Owner -and -not $remoteOwnerMatches) {
                $reason = "Local folder is renamed and Git origin repo matches '$($Identity.Repo)', but origin owner is '$($remoteIdentity.Owner)' instead of '$($Identity.Owner)'"
            }
            elseif ($Identity.Owner) {
                $reason = "Local folder name differs, but Git origin identifies requested repo '$($Identity.Owner)/$($Identity.Repo)'"
            }
            else {
                $reason = "Local folder name differs, but Git origin repo name matches '$($Identity.Repo)'; owner was not supplied"
            }
        }
        elseif ($candidate.NameFuzzy) {
            $confidence = 'LOW'
            $score = 100
            if ($gitRemote -and $remoteIdentity) {
                $reason = "Folder name partially matches '$($Identity.Repo)', but Git origin points to '$($remoteIdentity.Repository)'"
            }
            elseif ($candidate.HasGit -and $gitRemote) {
                $reason = "Folder name partially matches '$($Identity.Repo)', but Git origin '$gitRemote' is not a recognized GitHub repository URL"
            }
            elseif ($candidate.HasGit) {
                $reason = "Folder name partially matches '$($Identity.Repo)' and .git exists, but origin is missing or unreadable"
            }
            else {
                $reason = "Folder name partially matches '$($Identity.Repo)'; no .git metadata exists for verification"
            }
        }
        else {
            # A Git repo unrelated by remote and unrelated by name is not plausible.
            continue
        }

        if ($candidate.NameExact) { $score += 10 }
        if ($candidate.HasGit) { $score += 5 }

        $lastModified = $candidate.Directory.LastWriteTime
        $repositoryValue = if ($Identity.Owner) { "$($Identity.Owner)/$($Identity.Repo)" } elseif ($remoteIdentity) { $remoteIdentity.Repository } else { $Identity.Repo }
        $ownerValue = if ($Identity.Owner) { $Identity.Owner } elseif ($remoteIdentity) { $remoteIdentity.Owner } else { $null }

        $obj = [pscustomobject]@{
            PSTypeName   = 'LocalRepoFinder.Match'
            Repository   = $repositoryValue
            Owner        = $ownerValue
            Repo         = $Identity.Repo
            Path         = $candidate.Directory.FullName
            Confidence   = $confidence
            GitRemote    = $gitRemote
            HasGit       = [bool]$candidate.HasGit
            LastModified = $lastModified
            SearchRoot   = $candidate.SearchRoot
            MatchReason  = $reason
            Score        = $score
        }

        $defaultDisplay = [System.Management.Automation.PSPropertySet]::new(
            'DefaultDisplayPropertySet',
            [string[]]@('Confidence', 'Path', 'GitRemote', 'LastModified')
        )
        $standardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplay)
        $obj | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $standardMembers -Force
        $matches.Add($obj)
    }

    $matches | Sort-Object @{ Expression = 'Score'; Descending = $true }, @{ Expression = 'LastModified'; Descending = $true }, @{ Expression = { $_.Path.Length }; Ascending = $true }
}

function Find-LocalRepo {
    <#
    .SYNOPSIS
    Finds the best local folder matching a GitHub repository.

    .EXAMPLE
    Find-LocalRepo 'https://github.com/JFeimster/Business-Loan-Affiliate-Hub'

    .EXAMPLE
    Find-LocalRepo 'JFeimster/Business-Loan-Affiliate-Hub' -All

    .EXAMPLE
    Find-LocalRepo 'Business-Loan-Affiliate-Hub' -CopyPath
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Repository', 'Url')]
        [string]$InputObject,

        [switch]$All,
        [switch]$Exact,
        [switch]$Open,
        [switch]$CopyPath,

        [ValidateSet('Explorer', 'Code')]
        [string]$OpenWith = 'Explorer',

        [string[]]$SearchRoot
    )

    process {
        $identity = ConvertTo-GitHubRepoIdentity -InputValue $InputObject
        $config = Get-LocalRepoFinderConfig
        $roots = if ($SearchRoot) { $SearchRoot } else { [string[]]$config.SearchRoots }
        $excluded = [string[]]$config.ExcludedDirectories

        $results = @(Get-LocalRepoRankedMatches -Identity $identity -SearchRoots $roots -ExcludedDirectories $excluded)

        if ($Exact) {
            $results = @($results | Where-Object Confidence -eq 'EXACT')
        }

        if ($results.Count -eq 0) {
            Write-Error "No plausible local match found for '$($identity.Repository)' under the configured project roots."
            return
        }

        $selected = if ($All) { $results } else { @($results[0]) }
        $best = $results[0]

        if ($CopyPath) {
            if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
                Set-Clipboard -Value $best.Path
            }
            else {
                throw 'Set-Clipboard is not available in this PowerShell session.'
            }
        }

        if ($Open) {
            if ($OpenWith -eq 'Code') {
                $code = Get-Command code -ErrorAction SilentlyContinue
                if (-not $code) { throw "VS Code command 'code' was not found on PATH." }
                & $code.Source $best.Path
            }
            else {
                Start-Process explorer.exe -ArgumentList @($best.Path)
            }
        }

        $selected
    }
}
