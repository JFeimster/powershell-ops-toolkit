Describe 'Invoke-ProjectDoctor' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Invoke-ProjectDoctor.ps1') }

    It 'defines Invoke-ProjectDoctor' {
        Get-Command Invoke-ProjectDoctor -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
