function Get-SkillInventory {
    [CmdletBinding()]
    param(
        [string]$SkillsRoot = "$HOME\OneDrive\Desktop\JSON\skills"
    )

    if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) { throw "Skills root not found: $SkillsRoot" }

    $rows = foreach ($dir in Get-ChildItem -LiteralPath $SkillsRoot -Directory -ErrorAction Stop) {
        $scriptsDir = Join-Path $dir.FullName 'scripts'
        $scriptFiles = if (Test-Path $scriptsDir) { @(Get-ChildItem -LiteralPath $scriptsDir -Filter '*.ps1' -File -ErrorAction SilentlyContinue) } else { @() }
        $commands = foreach ($file in $scriptFiles) {
            try {
                $text = Get-Content -LiteralPath $file.FullName -Raw
                [regex]::Matches($text, '(?im)^\s*function\s+([A-Za-z0-9_-]+)') | ForEach-Object { $_.Groups[1].Value }
            } catch {}
        }
        [pscustomobject]@{
            Skill = $dir.Name
            Path = $dir.FullName
            HasReadme = Test-Path (Join-Path $dir.FullName 'README.md')
            HasSkillMd = Test-Path (Join-Path $dir.FullName 'SKILL.md')
            HasScripts = $scriptFiles.Count -gt 0
            ScriptCount = $scriptFiles.Count
            Commands = @($commands | Select-Object -Unique)
        }
    }

    $allCommands = @($rows | ForEach-Object { $_.Commands } | Where-Object { $_ })
    $dupes = @($allCommands | Group-Object | Where-Object Count -gt 1 | Select-Object -ExpandProperty Name)

    foreach ($row in $rows) {
        $row | Add-Member -NotePropertyName DuplicateCommands -NotePropertyValue @($row.Commands | Where-Object { $_ -in $dupes }) -Force
        $row
    }
}