@{
    Name = 'Get-ContentInventory'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ContentInventory'
    SupportedSources = @('Local','Wix','ResourceGrid','YouTube','Notion')
    DefaultFields = @('Title','Type','Url','Source','Status','UpdatedAt')
}
