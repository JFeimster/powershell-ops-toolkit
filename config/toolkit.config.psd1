@{
    ToolkitName = 'PowerShell Ops Toolkit'
    RegistryFile = 'powershell-ops-toolkit.registry.json'
    DefaultEditor = 'code'
    DefaultBrowserOpen = $false
    StructuredOutput = $true
    PreferReadOnlyIntegrations = $true
    ProfileMarkers = @{
        Start = '# >>> powershell-ops-toolkit >>>'
        End   = '# <<< powershell-ops-toolkit <<<'
    }
}
