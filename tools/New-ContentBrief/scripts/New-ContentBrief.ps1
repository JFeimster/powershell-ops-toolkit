function New-ContentBrief {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Topic,
        [string]$PrimaryKeyword,
        [string[]]$SecondaryKeywords,
        [string]$Audience,
        [string]$Offer,
        [string]$Cta
    )

    if (-not $PrimaryKeyword) { $PrimaryKeyword = $Topic }
    $slug = ($PrimaryKeyword.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')
    $gap = if (Get-Command Find-ContentGap -ErrorAction SilentlyContinue) { Find-ContentGap $Topic -ErrorAction SilentlyContinue } else { $null }

    [pscustomobject]@{
        Topic             = $Topic
        WorkingTitle      = $Topic
        PrimaryKeyword    = $PrimaryKeyword
        SecondaryKeywords = @($SecondaryKeywords)
        Slug              = $slug
        Audience          = $Audience
        SearchIntent      = 'Informational / commercial investigation'
        MetaDescription   = "Learn about $PrimaryKeyword, what matters, how it works, and what to do next."
        Outline           = @('Problem / context','What it means','How it works','Practical examples','Common mistakes','Next steps')
        FAQ               = @("What is $PrimaryKeyword?","How does $PrimaryKeyword work?","Who should use $PrimaryKeyword?","What should I do next?")
        Offer             = $Offer
        CTA               = $Cta
        ContentGap        = $gap
        ChatGPTPrompt     = "Create a publish-ready article about '$Topic'. Primary keyword: '$PrimaryKeyword'. Secondary keywords: $($SecondaryKeywords -join ', '). Audience: $Audience. Offer: $Offer. CTA: $Cta. Optimize for SEO, AEO, internal linking, clear examples, and FAQ schema."
    }
}