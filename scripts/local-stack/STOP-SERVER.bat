@echo off
REM Hadrian local stack - stop Apache and MySQL.
REM MySQL is shut down gracefully so InnoDB does not have to recover next start.
title Hadrian local stack - stopping
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0down.ps1"
echo.
pause
