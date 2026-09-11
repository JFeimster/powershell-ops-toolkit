Describe 'Compare-RepoCopies' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Compare-RepoCopies.ps1') }

    It 'defines Compare-RepoCopies' {
        Get-Command Compare-RepoCopies -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
