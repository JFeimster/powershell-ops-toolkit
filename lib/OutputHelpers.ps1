function Write-ToolkitSection {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Title)

    Write-Host "`n$Title" -ForegroundColor Cyan
    Write-Host ('-' * $Title.Length) -ForegroundColor DarkGray
}

function New-ToolkitResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Status,
        [string]$Message,
        [object]$Data
    )

    [pscustomobject]@{
        Name = $Name
        Status = $Status
        Message = $Message
        Data = $Data
    }
}
