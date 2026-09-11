@echo off
setlocal

if "%~1"=="" (
  echo Usage: %~nx0 "C:\path\to\site" [port]
  exit /b 1
)

set "SITE_PATH=%~1"
set "PORT=%~2"

if "%PORT%"=="" set "PORT=8000"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-LocalSite.ps1" -Path "%SITE_PATH%" -Port %PORT%
