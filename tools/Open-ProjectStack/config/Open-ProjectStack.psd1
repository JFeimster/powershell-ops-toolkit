@{
    Name = 'Open-ProjectStack'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ProjectNavigation'
    Dependencies = @('Open-Project','Get-ProjectLinks')
    DefaultTargets = @('Local','GitHub','Production','Vercel')
}
