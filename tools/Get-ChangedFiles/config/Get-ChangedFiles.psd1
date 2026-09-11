@{
    Name = 'Get-ChangedFiles'
    Version = '1.0.0'
    Enabled = $true
    Category = 'RepositoryInspection'
    Dependencies = @('git')
    IgnorePatterns = @('.next/','node_modules/','dist/','build/','coverage/','.turbo/','.cache/','*.log')
}
