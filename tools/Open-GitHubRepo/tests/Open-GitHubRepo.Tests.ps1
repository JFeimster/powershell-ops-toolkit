Describe 'Open-GitHubRepo' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Open-GitHubRepo.ps1') }

    It 'defines Open-GitHubRepo' {
        Get-Command Open-GitHubRepo -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
