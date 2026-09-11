@{
    Name = 'Export-ProjectContext'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ContextExport'
    DefaultFormat = 'Markdown'
    SupportedFormats = @('Markdown','Json')
    Dependencies = @('Get-ProjectStatus','Get-ProjectLinks','Get-SiteRoutes','Get-ChangedFiles')
}
