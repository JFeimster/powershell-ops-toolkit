@{
    Name = 'Test-Project'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ProjectValidation'
    PreferredChecks = @('lint','typecheck','test','build')
    ContinueOnFailure = $true
}
