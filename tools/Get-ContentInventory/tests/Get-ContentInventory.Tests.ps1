Describe 'Get-ContentInventory' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-ContentInventory.ps1') }

    It 'defines Get-ContentInventory' {
        Get-Command Get-ContentInventory -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
