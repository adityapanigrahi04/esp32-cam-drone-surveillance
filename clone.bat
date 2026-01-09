@echo off
setlocal enabledelayedexpansion

echo =============================================
echo   ESP32 Drone Surveillance - Clone Script
echo   Target Location: Desktop
echo =============================================

:: ---------- Check Internet ----------
echo Checking internet connection...
ping -n 1 github.com >nul
if errorlevel 1 (
    echo ❌ No internet connection detected.
    echo Please connect to the internet and retry.
    pause
    exit /b 1
)
echo ✅ Internet connection OK

:: ---------- Check Git ----------
echo Checking Git installation...
git --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Git not found. Installing Git...
    winget install --id Git.Git -e --source winget
    echo 🔁 Git installed. Please re-run this script.
    pause
    exit /b 0
)
echo ✅ Git is installed

:: ---------- Desktop Workspace ----------
set WORKSPACE=%USERPROFILE%\Desktop\esp32-projects

if not exist "%WORKSPACE%" (
    echo Creating workspace folder on Desktop...
    mkdir "%WORKSPACE%"
)

cd /d "%WORKSPACE%"

:: ---------- Clone Repository ----------
if exist "esp32-cam-drone-surveillance" (
    echo ⚠️ Repository already exists on Desktop.
    echo Location: %WORKSPACE%\esp32-cam-drone-surveillance
    pause
    exit /b 0
)

echo Cloning repository to Desktop...
git clone https://github.com/adityapanigrahi04/esp32-cam-drone-surveillance.git

if errorlevel 1 (
    echo ❌ Clone failed.
    pause
    exit /b 1
)

:: ---------- Enter Project ----------
cd esp32-cam-drone-surveillance

echo.
echo ✅ Repository cloned successfully!
echo 📂 Location:
echo %CD%
echo.
echo Next steps:
echo   1. Run sysCheck.bat
echo   2. Run setup.bat
echo.

pause
