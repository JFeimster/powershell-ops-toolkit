Describe 'Get-ProjectLinks' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-ProjectLinks.ps1') }

    It 'defines Get-ProjectLinks' {
        Get-Command Get-ProjectLinks -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
