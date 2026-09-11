Describe 'Export-ProjectContext' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Export-ProjectContext.ps1') }

    It 'defines Export-ProjectContext' {
        Get-Command Export-ProjectContext -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'supports Markdown and Json formats' {
        (Get-Command Export-ProjectContext).Parameters.Keys | Should -Contain 'Format'
    }
}
