Describe 'Search-MyStack' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Search-MyStack.ps1') }

    It 'defines Search-MyStack' {
        Get-Command Search-MyStack -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'requires Query' {
        (Get-Command Search-MyStack).Parameters.Keys | Should -Contain 'Query'
    }
}
