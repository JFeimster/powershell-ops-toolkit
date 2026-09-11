@{
    Name = 'Get-RepoHealth'
    Version = '1.0.0'
    Enabled = $true
    Category = 'RepositoryValidation'
    Checks = @('GitMetadata','OriginRemote','Lockfiles','BuildArtifacts','EnvExample','WorkspaceRoot','Scripts')
}
