Describe 'Start-Project' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Start-Project.ps1') }

    It 'defines Start-Project' {
        Get-Command Start-Project -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'accepts Repository and Open parameters' {
        $params = (Get-Command Start-Project).Parameters.Keys
        $params | Should -Contain 'Repository'
        $params | Should -Contain 'Open'
    }
}
