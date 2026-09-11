function Get-ContentInventory {
    [CmdletBinding()]
    param(
        [string[]]$Source = @(
            "$HOME\OneDrive\Desktop\JSON",
            "$HOME\OneDrive\Desktop\Moonshine Capital\ResourceGrid"
        ),
        [string]$Query,
        [int]$MaxResults = 500
    )

    $skip = '\\(node_modules|\.git|\.next|dist|build|coverage|vendor)\\'
    $rows = [System.Collections.Generic.List[object]]::new()

    foreach ($root in $Source) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        $files = if (Test-Path -LiteralPath $root -PathType Leaf) { @(Get-Item -LiteralPath $root) } else {
            @(Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch $skip -and $_.Extension -in '.json','.md','.csv' })
        }

        foreach ($file in $files) {
            if ($rows.Count -ge $MaxResults) { break }
            try {
                $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
                if ($Query -and $text -notmatch [regex]::Escape($Query)) { continue }
                $title = $file.BaseName
                $url = $null
                $type = $file.Extension.TrimStart('.')
                if ($file.Extension -eq '.json') {
                    try {
                        $json = $text | ConvertFrom-Json -ErrorAction Stop
                        if ($json.title) { $title = [string]$json.title }
                        elseif ($json.name) { $title = [string]$json.name }
                        if ($json.url) { $url = [string]$json.url }
                        elseif ($json.link) { $url = [string]$json.link }
                        if ($json.type) { $type = [string]$json.type }
                    } catch {}
                }
                $rows.Add([pscustomobject]@{ Title=$title; Type=$type; Path=$file.FullName; Url=$url; LastModified=$file.LastWriteTime })
            } catch {}
        }
    }
    $rows | Sort-Object LastModified -Descending | Select-Object -First $MaxResults
}