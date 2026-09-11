@{
    Name = 'Get-WorkQueue'
    Version = '1.0.0'
    Enabled = $true
    Category = 'GitHubWorkManagement'
    Dependencies = @('gh')
    Include = @('Issues','PullRequests')
    SortBy = @('Priority','UpdatedAt')
}
