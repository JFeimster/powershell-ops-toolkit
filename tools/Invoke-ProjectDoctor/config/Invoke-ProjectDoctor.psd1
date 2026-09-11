@{
    Name = 'Invoke-ProjectDoctor'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ProjectDiagnostics'
    Dependencies = @('Get-ProjectStatus','Get-RepoHealth','Get-ChangedFiles','Get-DeploymentStatus')
    Sections = @('ProjectStatus','RepoHealth','ChangedFiles','Deployment')
}
