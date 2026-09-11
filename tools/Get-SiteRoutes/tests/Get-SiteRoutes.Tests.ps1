Describe 'Get-SiteRoutes' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-SiteRoutes.ps1') }

    It 'defines Get-SiteRoutes' {
        Get-Command Get-SiteRoutes -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
