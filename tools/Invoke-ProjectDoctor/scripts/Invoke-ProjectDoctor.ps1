function Invoke-ProjectDoctor {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [switch]$RunTests
    )

    $status = if (Get-Command Get-ProjectStatus -ErrorAction SilentlyContinue) { Get-ProjectStatus $Repository } else { $null }
    if (-not $status) { throw 'Get-ProjectStatus must be available.' }

    $health = if (Get-Command Get-RepoHealth -ErrorAction SilentlyContinue) { Get-RepoHealth $status.Path } else { $null }
    $copies = if (Get-Command Compare-RepoCopies -ErrorAction SilentlyContinue) { @(Compare-RepoCopies $status.Repository -ErrorAction SilentlyContinue) } else { @() }
    $deployment = if (Get-Command Get-DeploymentStatus -ErrorAction SilentlyContinue) { Get-DeploymentStatus $status.Path -ErrorAction SilentlyContinue } else { $null }
    $tests = @()
    if ($RunTests -and (Get-Command Test-Project -ErrorAction SilentlyContinue) -and $status.HasPackageJson) {
        $tests = @(Test-Project $status.Path)
    }

    $warnings = @()
    if ($status.HasGit -and -not $status.Clean) { $warnings += 'Working tree is dirty.' }
    if ($status.Ahead -gt 0) { $warnings += "Local branch is $($status.Ahead) commit(s) ahead." }
    if ($status.Behind -gt 0) { $warnings += "Local branch is $($status.Behind) commit(s) behind." }
    if ($copies.Count -gt 1) { $warnings += "Multiple local copies detected: $($copies.Count)." }
    if ($health -and -not $health.Healthy) { $warnings += 'Repository health warnings were detected.' }
    if (@($tests | Where-Object Status -eq 'FAIL').Count -gt 0) { $warnings += 'One or more project checks failed.' }

    [pscustomobject]@{
        Repository = $status.Repository
        Path = $status.Path
        Status = $status
        Health = $health
        Copies = $copies
        Deployment = $deployment
        Tests = $tests
        WarningCount = $warnings.Count
        Warnings = $warnings
        Overall = if ($warnings.Count -eq 0) { 'PASS' } else { 'ATTENTION' }
    }
}