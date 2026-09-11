Describe 'Get-WixDraftQueue' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-WixDraftQueue.ps1') }

    It 'defines Get-WixDraftQueue' {
        Get-Command Get-WixDraftQueue -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'accepts StaleDays' {
        (Get-Command Get-WixDraftQueue).Parameters.Keys | Should -Contain 'StaleDays'
    }
}
