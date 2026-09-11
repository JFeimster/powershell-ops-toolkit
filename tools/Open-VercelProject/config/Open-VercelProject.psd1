@{
    Name = 'Open-VercelProject'
    Version = '1.0.0'
    Enabled = $true
    Category = 'DeploymentNavigation'
    Targets = @('Dashboard','Production')
    MetadataSources = @('.vercel/project.json','Get-ProjectLinks')
}
