@{
    Name = 'Start-Project'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ProjectRuntime'
    Dependencies = @('Find-LocalRepo')
    PreferredScripts = @('dev','start','preview')
    SupportedPackageManagers = @('npm','pnpm','yarn','bun')
}
