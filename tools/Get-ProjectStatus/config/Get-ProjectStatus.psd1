@{
    Name = 'Get-ProjectStatus'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ProjectInspection'
    Dependencies = @('git')
    Output = @('Repository','Path','Branch','GitRemote','Clean','Ahead','Behind','Framework','PackageManager','LastCommit')
}
