@{
    Name = 'Get-WixDraftQueue'
    Version = '1.0.0'
    Enabled = $true
    Category = 'WixContentOps'
    DefaultStaleDays = 30
    SupportedInputFormats = @('Json','Csv','InputObject')
    Checks = @('DraftStatus','Stale','MissingMetaDescription','MissingFeaturedImage')
}
