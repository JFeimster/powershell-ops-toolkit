Describe 'Get-ProjectStatus' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-ProjectStatus.ps1') }

    It 'defines Get-ProjectStatus' {
        Get-Command Get-ProjectStatus -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'accepts a Repository parameter' {
        (Get-Command Get-ProjectStatus).Parameters.Keys | Should -Contain 'Repository'
    }
}
