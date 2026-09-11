Describe 'Find-ProjectAsset' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Find-ProjectAsset.ps1') }

    It 'defines Find-ProjectAsset' {
        Get-Command Find-ProjectAsset -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'requires Query' {
        (Get-Command Find-ProjectAsset).Parameters.Keys | Should -Contain 'Query'
    }
}
