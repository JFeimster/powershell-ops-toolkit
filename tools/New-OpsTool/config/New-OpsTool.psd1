@{
    Name = 'New-OpsTool'
    DefaultFolders = @(
        'scripts'
        'config'
        'tests'
    )
    ExtendedFolders = @(
        'schemas'
        'prompts'
        'templates'
        'agents'
        'fixtures'
        'docs'
        'examples'
    )
    RequireVerbNounName = $true
    DefaultEncoding = 'utf8'
}
