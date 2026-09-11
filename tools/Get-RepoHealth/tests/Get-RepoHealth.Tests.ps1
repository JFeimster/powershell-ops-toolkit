Describe 'Get-RepoHealth' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-RepoHealth.ps1') }

    It 'defines Get-RepoHealth' {
        Get-Command Get-RepoHealth -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
