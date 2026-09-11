Describe 'Get-ChangedFiles' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-ChangedFiles.ps1') }

    It 'defines Get-ChangedFiles' {
        Get-Command Get-ChangedFiles -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
