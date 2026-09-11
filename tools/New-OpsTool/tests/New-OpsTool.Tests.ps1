BeforeAll {
    . "$PSScriptRoot\..\scripts\New-OpsTool.ps1"
}

Describe 'New-OpsTool' {
    It 'loads successfully' {
        Get-Command New-OpsTool -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }

    It 'creates the default scaffold' {
        $root = Join-Path $TestDrive 'repo'
        New-Item -ItemType Directory -Path (Join-Path $root 'tools') -Force | Out-Null

        $result = New-OpsTool 'Open-Project' -RepoRoot $root -PassThru

        Test-Path (Join-Path $result.Path 'scripts\Open-Project.ps1') | Should -BeTrue
        Test-Path (Join-Path $result.Path 'config\Open-Project.psd1') | Should -BeTrue
        Test-Path (Join-Path $result.Path 'tests\Open-Project.Tests.ps1') | Should -BeTrue
        Test-Path (Join-Path $result.Path 'schemas') | Should -BeFalse
    }

    It 'creates the extended scaffold when requested' {
        $root = Join-Path $TestDrive 'extended-repo'
        New-Item -ItemType Directory -Path (Join-Path $root 'tools') -Force | Out-Null

        $result = New-OpsTool 'Export-ProjectContext' -RepoRoot $root -Extended -PassThru

        foreach ($folder in @('schemas','prompts','templates','agents','fixtures','docs','examples')) {
            Test-Path (Join-Path $result.Path $folder) | Should -BeTrue
        }
    }

    It 'refuses to overwrite an existing tool without Force' {
        $root = Join-Path $TestDrive 'duplicate-repo'
        $tool = Join-Path $root 'tools\Open-Project'
        New-Item -ItemType Directory -Path $tool -Force | Out-Null

        { New-OpsTool 'Open-Project' -RepoRoot $root } | Should -Throw
    }
}
