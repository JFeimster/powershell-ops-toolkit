@{
    Name = 'Get-DeploymentStatus'
    Version = '1.0.0'
    Enabled = $true
    Category = 'DeploymentInspection'
    Sources = @('Git','GitHub','VercelMetadata','VercelCli')
    Fields = @('Branch','LocalHead','RemoteHead','VercelDeployment','ProductionUrl','InSync')
}
