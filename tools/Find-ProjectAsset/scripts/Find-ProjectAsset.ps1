function Find-ProjectAsset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Query,

        [string[]]$Roots = @(
            "$HOME\OneDrive\Desktop\JSON",
            "$HOME\OneDrive\Desktop\Moonshine Capital\ResourceGrid"
        ),

        [ValidateSet('json','md','all')]
        [string]$Type = 'all',

        [int]$MaxResults = 100
    )

    $patterns = switch ($Type) {
        'json' { @('*.json') }
        'md'   { @('*.md') }
        default { @('*.json','*.md','*.psd1','*.csv') }
    }

    $skip = '\\(node_modules|\.git|\.next|dist|build|coverage|vendor)\\'
    $results = [System.Collections.Generic.List[object]]::new()

    foreach ($root in $Roots) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        foreach ($pattern in $patterns) {
            Get-ChildItem -LiteralPath $root -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notmatch $skip } |
                ForEach-Object {
                    if ($results.Count -ge $MaxResults) { return }
                    $file = $_
                    try {
                        $matches = Select-String -LiteralPath $file.FullName -Pattern $Query -SimpleMatch -CaseSensitive:$false -ErrorAction Stop
                        foreach ($m in $matches | Select-Object -First 3) {
                            $results.Add([pscustomobject]@{
                                Query      = $Query
                                File       = $file.FullName
                                Extension  = $file.Extension
                                LineNumber = $m.LineNumber
                                Match      = $m.Line.Trim()
                            })
                        }
                    } catch {}
                }
        }
    }
    $results | Select-Object -First $MaxResults
}