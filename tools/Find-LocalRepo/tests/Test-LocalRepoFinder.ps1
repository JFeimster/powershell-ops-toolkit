#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

$tests = [System.Collections.Generic.List[object]]::new()
function Add-TestResult([string]$Name, [bool]$Passed, [string]$Detail) {
    $tests.Add([pscustomobject]@{ Test = $Name; Result = $(if ($Passed) { 'PASS' } else { 'FAIL' }); Detail = $Detail })
}

# Real-machine lookups requested by the project brief.
$testRepos = @(
    'JFeimster/Business-Loan-Affiliate-Hub',
    'JFeimster/moonshine-capital-portal',
    'JFeimster/ResourceGrid'
)

$realResults = @{}
foreach ($repo in $testRepos) {
    try {
        $r = @(Find-LocalRepo $repo -All -ErrorAction Stop)
        $realResults[$repo] = $r
        Add-TestResult "Real lookup $repo" ($r.Count -gt 0) "$($r.Count) plausible local match(es)"
    }
    catch {
        Add-TestResult "Real lookup $repo" $false $_.Exception.Message
    }
}

# Deterministic fixture tests validate ranking, duplicates, URL normalization and spaces
# without changing any actual repository. The fixture exists only under %TEMP%.
$tempRoot = Join-Path $env:TEMP ("Local Repo Finder Test " + [guid]::NewGuid().ToString('N'))
$repoName = 'Business-Loan-Affiliate-Hub'
$exactPath = Join-Path $tempRoot "Primary Copy\$repoName"
$mediumPath = Join-Path $tempRoot "Copied Projects\$repoName"
$fuzzyPath = Join-Path $tempRoot "Archive\$repoName-old"

try {
    New-Item -ItemType Directory -Force -Path $exactPath, $mediumPath, $fuzzyPath | Out-Null

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Add-TestResult 'Exact-match detection' $false 'git executable not found on PATH'
        Add-TestResult 'Duplicate detection' $false 'git executable not found on PATH'
        Add-TestResult 'Repo-name-only lookup' $false 'git executable not found on PATH'
        Add-TestResult 'Full GitHub URL lookup' $false 'git executable not found on PATH'
        Add-TestResult 'Paths with spaces' $false 'git executable not found on PATH'
    }
    else {
        & git -C $exactPath init --quiet 2>$null
        & git -C $exactPath remote add origin 'git@github.com:JFeimster/Business-Loan-Affiliate-Hub.git' 2>$null

        $urlResults = @(Find-LocalRepo 'https://github.com/JFeimster/Business-Loan-Affiliate-Hub' -All -SearchRoot $tempRoot -ErrorAction Stop)
        $best = $urlResults | Select-Object -First 1
        Add-TestResult 'Exact-match detection' ($best.Confidence -eq 'EXACT' -and $best.Path -eq $exactPath) "Best=$($best.Confidence) $($best.Path)"
        Add-TestResult 'Duplicate detection' ($urlResults.Count -ge 3) "$($urlResults.Count) ranked plausible copies returned with -All"
        Add-TestResult 'Full GitHub URL lookup' ($urlResults.Count -gt 0 -and $best.Repository -eq 'JFeimster/Business-Loan-Affiliate-Hub') "Normalized repository=$($best.Repository)"
        Add-TestResult 'Paths with spaces' ($best.Path -match '\s') $best.Path

        $nameOnly = @(Find-LocalRepo 'Business-Loan-Affiliate-Hub' -All -SearchRoot $tempRoot -ErrorAction Stop)
        $nameBest = $nameOnly | Select-Object -First 1
        Add-TestResult 'Repo-name-only lookup' ($nameOnly.Count -ge 3 -and $nameBest.Repo -eq $repoName) "$($nameOnly.Count) ranked result(s); best confidence=$($nameBest.Confidence)"
    }
}
catch {
    Add-TestResult 'Fixture execution' $false $_.Exception.Message
}
finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'Local Repo Finder validation' -ForegroundColor Cyan
$tests | Format-Table -AutoSize

$failed = @($tests | Where-Object Result -eq 'FAIL')
if ($failed.Count -gt 0) {
    Write-Warning "$($failed.Count) validation test(s) failed. Review the rows above."
}

$tests
