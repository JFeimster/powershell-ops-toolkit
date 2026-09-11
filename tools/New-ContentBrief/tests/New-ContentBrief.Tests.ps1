Describe 'New-ContentBrief' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\New-ContentBrief.ps1') }

    It 'defines New-ContentBrief' {
        Get-Command New-ContentBrief -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'requires Topic' {
        (Get-Command New-ContentBrief).Parameters.Keys | Should -Contain 'Topic'
    }
}
