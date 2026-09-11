Describe 'Open-ProjectStack' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Open-ProjectStack.ps1') }

    It 'defines Open-ProjectStack' {
        Get-Command Open-ProjectStack -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
