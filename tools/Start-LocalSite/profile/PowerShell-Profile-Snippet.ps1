# ============================================================
# MY SKILLS
# ============================================================

$MySkills = "C:\Users\jason\OneDrive\Desktop\JSON\skills"

# ------------------------------------------------------------
# Local Site Preview
# ------------------------------------------------------------

function Start-LocalSite {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [int]$Port = 0
    )

    $ScriptPath = Join-Path $MySkills "local-site-preview\scripts\Start-LocalSite.ps1"
    & $ScriptPath -Path $Path -Port $Port
}
