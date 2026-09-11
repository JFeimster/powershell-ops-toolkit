# Compare-RepoCopies

## Purpose
Compare multiple local copies of the same repository and rank which copy is most likely canonical/current.

## Entry point
`scripts/Compare-RepoCopies.ps1`

## Dependencies
Use Find-LocalRepo with all plausible matches, then inspect Git state without modifying repositories.
