Describe 'Test-Project' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Test-Project.ps1') }

    It 'defines Test-Project' {
        Get-Command Test-Project -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'accepts Repository' {
        (Get-Command Test-Project).Parameters.Keys | Should -Contain 'Repository'
    }
}
