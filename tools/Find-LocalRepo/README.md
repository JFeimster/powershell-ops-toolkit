# Local Repo Finder

`Find-LocalRepo` finds and ranks local project folders for a GitHub repository without scanning the whole system drive.

## Install

Extract this folder, then run from PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
& ".\Install-LocalRepoFinder.ps1"
```

The installer copies the tool to:

`C:\Users\jason\OneDrive\Desktop\JSON\skills\local-repo-finder`

and safely adds or updates a marked dot-source block in `$PROFILE.CurrentUserCurrentHost`. It will not create a second `Find-LocalRepo` definition if an unrelated one already exists in the profile.

## Usage

```powershell
Find-LocalRepo "https://github.com/JFeimster/Business-Loan-Affiliate-Hub"
Find-LocalRepo "JFeimster/Business-Loan-Affiliate-Hub"
Find-LocalRepo "Business-Loan-Affiliate-Hub"
Find-LocalRepo "Business-Loan-Affiliate-Hub" -All
Find-LocalRepo "Business-Loan-Affiliate-Hub" -Exact
Find-LocalRepo "Business-Loan-Affiliate-Hub" -CopyPath
Find-LocalRepo "Business-Loan-Affiliate-Hub" -Open
Find-LocalRepo "Business-Loan-Affiliate-Hub" -Open -OpenWith Code
```

Returned objects include:

- `Repository`
- `Owner`
- `Repo`
- `Path`
- `Confidence`
- `GitRemote`
- `HasGit`
- `LastModified`
- `SearchRoot`
- `MatchReason`

A numeric `Score` property is also included for troubleshooting/ranking.

## Ranking

1. `EXACT` — normalized Git `origin` matches the explicitly supplied owner/repo.
2. `HIGH` — exact folder name plus Git metadata, or strong Git repo-name evidence. Repo-name-only queries top out here because no owner was supplied for exact verification.
3. `MEDIUM` — exact folder name without `.git`.
4. `LOW` — fuzzy folder-name match.

Tie-breaking prefers higher score, newer `LastModified`, then shorter path.

## Search roots

Edit only:

`config\LocalRepoFinder.psd1`

The default roots are:

- `C:\Users\jason\Documents\GitHub`
- `C:\Users\jason\OneDrive\Desktop\Moonshine Capital`
- `C:\Users\jason\OneDrive\Desktop\Vercel Projects`
- `C:\Users\jason\OneDrive\Desktop\JSON`
- `C:\Users\jason\Documents\Codex`

The recursive walker prunes dependency/build folders including `node_modules`, `.next`, `dist`, `build`, `.git`, `vendor`, `coverage`, `.turbo`, `.cache`, `.vercel`, `out`, `target`, `bin`, `obj`, and Python virtual/cache directories.
