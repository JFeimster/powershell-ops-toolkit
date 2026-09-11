Describe 'Open-VercelProject' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Open-VercelProject.ps1') }

    It 'defines Open-VercelProject' {
        Get-Command Open-VercelProject -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'accepts Target' {
        (Get-Command Open-VercelProject).Parameters.Keys | Should -Contain 'Target'
    }
}
