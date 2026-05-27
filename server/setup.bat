@echo off
title FarmSheep Server Setup
echo.
echo  FarmSheep Server - First-Time Setup
echo  =====================================
echo.

:: Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] Node.js is not installed.
    echo  Download it from: https://nodejs.org  (LTS version)
    echo.
    pause
    exit /b 1
)
echo  [OK] Node.js found:
node --version

:: Install dependencies
echo.
echo  Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo  [ERROR] npm install failed.
    pause
    exit /b 1
)
echo  [OK] Dependencies installed.

:: Create uploads directory
if not exist "uploads" mkdir uploads
echo  [OK] uploads/ directory ready.

:: Copy .env.example to .env if not already present
if not exist ".env" (
    copy ".env.example" ".env" >nul
    echo  [OK] Created .env from template.
    echo.
    echo  *** ACTION REQUIRED ***
    echo  Edit .env and fill in:
    echo    SERVER_URL   - your PC's local IP (run ipconfig to find it)
    echo    SERVER_SECRET - any random string (must match lib/config.dart)
    echo    AI_PROVIDER  - groq (free) or another provider
    echo    GROQ_API_KEY - get from console.groq.com (free)
    echo    FIREBASE_SERVICE_ACCOUNT_PATH - path to your Firebase service account JSON
    echo.
    echo  Also copy your Firebase service account JSON to this folder.
    echo  Download from: Firebase Console > Project Settings > Service Accounts
    echo.
) else (
    echo  [OK] .env already exists (not overwritten).
)

echo  Setup complete. Run start.bat to launch the server.
echo.
pause
