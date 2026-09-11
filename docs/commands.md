# Command Catalog

The canonical roadmap is stored in `powershell-ops-toolkit.registry.json`.

## Existing

- `Start-LocalSite`
- `Find-LocalRepo`

## Priority build queue

1. `Open-Project`
2. `Get-ProjectStatus`
3. `Start-Project`
4. `Compare-RepoCopies`
5. `Export-ProjectContext`
6. `Get-DeploymentStatus`

## Planned command families

### Project discovery and navigation
- `Find-LocalRepo`
- `Open-Project`
- `Open-ProjectStack`
- `Open-GitHubRepo`
- `Open-VercelProject`

### Project health and execution
- `Get-ProjectStatus`
- `Start-Project`
- `Test-Project`
- `Get-RepoHealth`
- `Invoke-ProjectDoctor`
- `Get-ChangedFiles`

### Deployment and platform context
- `Get-ProjectLinks`
- `Get-DeploymentStatus`
- `Get-WorkQueue`

### Site and content operations
- `Get-SiteRoutes`
- `Test-SiteRoutes`
- `Get-ContentInventory`
- `Find-ContentGap`
- `New-ContentBrief`
- `Get-WixDraftQueue`

### Registry and toolkit operations
- `Find-ProjectAsset`
- `Export-ProjectContext`
- `Get-SkillInventory`
- `Search-MyStack`

Each public command should return structured objects whenever possible and use formatted output only as a convenience layer.
