Describe 'Get-DeploymentStatus' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-DeploymentStatus.ps1') }

    It 'defines Get-DeploymentStatus' {
        Get-Command Get-DeploymentStatus -CommandType Function | Should -Not -BeNullOrEmpty
    }
}
