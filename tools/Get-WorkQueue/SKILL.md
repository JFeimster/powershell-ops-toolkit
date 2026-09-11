# Get-WorkQueue

## Purpose
Surface the current GitHub execution queue for a repository.

## Entry point
`scripts/Get-WorkQueue.ps1`

## Behavior
Read issues and pull requests, preserve source metadata, and return a sortable object set. Do not modify GitHub state unless explicitly requested by another command.
