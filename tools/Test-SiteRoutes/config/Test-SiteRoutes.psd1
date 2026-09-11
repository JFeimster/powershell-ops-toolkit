@{
    Name = 'Test-SiteRoutes'
    Version = '1.0.0'
    Enabled = $true
    Category = 'NextJsValidation'
    Checks = @('DuplicateRoutes','MissingFiles','MissingMetadata','DeadInternalLinks','InvalidContentContracts')
}
