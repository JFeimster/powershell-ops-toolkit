@{
    Name = 'Open-Project'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ProjectNavigation'
    DefaultOpenWith = 'Code'
    Dependencies = @('Find-LocalRepo')
    Supports = @('Code','Explorer','GitHub')
}
