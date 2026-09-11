# Upgrade from v1

Copy the contents of the `local-site-preview` folder over:

```text
C:\Users\jason\OneDrive\Desktop\JSON\skills\local-site-preview
```

Replace your existing `Start-LocalSite` function in `$PROFILE` with:

```text
profile\PowerShell-Profile-Snippet.ps1
```

Then reload:

```powershell
. $PROFILE
```

Verify:

```powershell
$MySkills
Get-Command Start-LocalSite
```
