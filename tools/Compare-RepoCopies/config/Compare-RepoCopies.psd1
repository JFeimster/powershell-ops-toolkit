@{
    Name = 'Compare-RepoCopies'
    Version = '1.0.0'
    Enabled = $true
    Category = 'RepositoryInspection'
    Dependencies = @('Find-LocalRepo','git')
    CompareFields = @('Path','GitRemote','Branch','LastCommit','Dirty','LastModified','FileCount')
}
