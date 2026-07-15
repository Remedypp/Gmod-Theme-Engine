@echo off
setlocal
title Aperture Theme Engine Installer

set "INSTALLER=%~dp0installer\theme_engine_installer.ps1"
if not exist "%INSTALLER%" (
    echo Theme Engine installer files are incomplete.
    echo Missing: %INSTALLER%
    pause
    exit /b 1
)

start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File "%INSTALLER%"

endlocal
