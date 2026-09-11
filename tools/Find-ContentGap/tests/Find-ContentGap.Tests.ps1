Describe 'Find-ContentGap' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Find-ContentGap.ps1') }

    It 'defines Find-ContentGap' {
        Get-Command Find-ContentGap -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'requires Topic' {
        (Get-Command Find-ContentGap).Parameters.Keys | Should -Contain 'Topic'
    }
}
