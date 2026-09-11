Describe 'Get-WorkQueue' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-WorkQueue.ps1') }

    It 'defines Get-WorkQueue' {
        Get-Command Get-WorkQueue -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
