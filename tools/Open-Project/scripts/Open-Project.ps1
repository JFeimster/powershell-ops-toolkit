function Open-Project {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Repository,
        [ValidateSet('Code','Explorer')]
        [string]$OpenWith = 'Code'
    )

    throw 'Open-Project scaffold created; implementation pending.'
}
