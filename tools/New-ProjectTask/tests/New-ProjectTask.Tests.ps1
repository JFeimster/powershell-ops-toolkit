Describe 'New-ProjectTask' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\New-ProjectTask.ps1') }

    It 'defines New-ProjectTask' {
        Get-Command New-ProjectTask -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'requires explicit Create for mutation' {
        (Get-Command New-ProjectTask).Parameters.Keys | Should -Contain 'Create'
    }
}
