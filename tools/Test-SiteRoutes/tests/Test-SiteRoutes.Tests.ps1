Describe 'Test-SiteRoutes' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Test-SiteRoutes.ps1') }

    It 'defines Test-SiteRoutes' {
        Get-Command Test-SiteRoutes -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
