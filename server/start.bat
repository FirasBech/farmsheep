@echo off
title FarmSheep Server
echo.
echo  Starting FarmSheep Server...
echo  Press Ctrl+C to stop.
echo.

if not exist ".env" (
    echo  [ERROR] .env not found. Run setup.bat first.
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo  [ERROR] node_modules not found. Run setup.bat first.
    pause
    exit /b 1
)

node index.js
pause
