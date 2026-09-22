@echo off
REM Hadrian local stack - start MySQL + Apache and open the site.
REM Double-click this file. Safe to run twice; anything already running is left alone.
title Hadrian local stack - starting
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0up.ps1"
if errorlevel 1 (
    echo.
    echo Something went wrong - see the messages above.
    pause
    exit /b 1
)
echo.
echo Opening http://localhost:8088/ ...
start "" "http://localhost:8088/"
echo.
echo The server keeps running after this window closes.
echo To stop it, run STOP-SERVER.bat
echo.
pause
