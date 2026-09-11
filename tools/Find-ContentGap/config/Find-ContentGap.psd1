@{
    Name = 'Find-ContentGap'
    Version = '1.0.0'
    Enabled = $true
    Category = 'ContentIntelligence'
    DefaultSources = @('ContentInventory','ResourceGrid')
    Signals = @('Duplication','Cannibalization','MissingInternalLinks','AEOOpportunity','TopicGap')
}
