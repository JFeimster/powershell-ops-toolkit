# Default scaffold
New-OpsTool 'Open-Project'

# Only the capabilities the tool actually needs
New-OpsTool 'Export-ProjectContext' -Schemas -Templates -Docs -Examples

# Full extended standard
New-OpsTool 'Find-ContentGap' -Extended

# Return the created scaffold as a PowerShell object
New-OpsTool 'Get-DeploymentStatus' -Schemas -Docs -PassThru |
    Format-List
