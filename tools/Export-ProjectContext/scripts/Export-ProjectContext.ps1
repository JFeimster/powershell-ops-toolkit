function Export-ProjectContext {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Repository = '.',
        [ValidateSet('Markdown','Json')]
        [string]$Format = 'Markdown'
    )

    throw 'Export-ProjectContext scaffold created; implementation pending.'
}
