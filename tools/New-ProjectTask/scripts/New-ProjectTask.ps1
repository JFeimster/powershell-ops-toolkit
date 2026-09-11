function New-ProjectTask {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [Parameter(Mandatory)]
        [string]$Title,
        [string]$Body,
        [switch]$Create
    )

    throw 'New-ProjectTask scaffold created; implementation pending.'
}
