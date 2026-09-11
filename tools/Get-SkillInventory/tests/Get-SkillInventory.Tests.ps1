Describe 'Get-SkillInventory' {
    BeforeAll { . (Join-Path $PSScriptRoot '..\scripts\Get-SkillInventory.ps1') }

    It 'defines Get-SkillInventory' {
        Get-Command Get-SkillInventory -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'accepts SkillsRoot' {
        (Get-Command Get-SkillInventory).Parameters.Keys | Should -Contain 'SkillsRoot'
    }
}
