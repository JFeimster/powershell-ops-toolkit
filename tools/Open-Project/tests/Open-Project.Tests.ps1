Describe 'Open-Project' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..\scripts\Open-Project.ps1'
        . $scriptPath
    }

    It 'defines Open-Project' {
        Get-Command Open-Project -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'supports WhatIf' {
        (Get-Command Open-Project).Parameters.Keys | Should -Contain 'WhatIf'
    }
}
