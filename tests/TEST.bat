@echo off
REM Hadrian test suite - double-click to run every tier against the local stack
REM and open the report. Start the stack first: scripts\local-stack\START-SERVER.bat
REM
REM From a terminal you can pass options, e.g.:   tests\TEST.bat --tier static,compile
title Hadrian tests
cd /d "%~dp0\.."
if not exist "tests\node_modules\@playwright\test" (
    echo Installing test dependencies...
    call npm --prefix tests install --no-audit --no-fund
)
node tests\run.mjs --open %*
echo.
pause
