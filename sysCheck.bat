@echo off
setlocal

echo ============================================
echo   ESP32 Drone Surveillance - Precheck (Win)
echo ============================================

:: ---------- Architecture ----------
echo Checking OS architecture...
wmic os get osarchitecture | find "64" >nul
if errorlevel 1 (
    echo ❌ 64-bit Windows required
    exit /b 1
)
echo ✅ 64-bit OS detected

:: ---------- Internet ----------
echo Checking internet connectivity...
ping -n 1 google.com >nul
if errorlevel 1 (
    echo ❌ Internet connection required
    exit /b 1
)
echo ✅ Internet available

:: ---------- Git ----------
echo Checking Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo Installing Git...
    winget install --id Git.Git -e --source winget
)
git --version

:: ---------- Python 3.10 ----------
echo Checking Python...
python --version 2>nul | find "3.10" >nul
if errorlevel 1 (
    echo Installing Python 3.10...
    winget install --id Python.Python.3.10 -e
)

python --version
pip --version

:: ---------- Node.js 18 LTS ----------
echo Checking Node.js...
node --version 2>nul | find "v18" >nul
if errorlevel 1 (
    echo Installing Node.js 18 LTS...
    winget install OpenJS.NodeJS.LTS
)

node --version
npm --version

:: ---------- Build Tools ----------
echo Checking build tools...
where cl >nul 2>&1
if errorlevel 1 (
    echo Installing Visual Studio Build Tools...
    winget install Microsoft.VisualStudio.2022.BuildTools
)

:: ---------- Final Verification ----------
echo.
echo ========= FINAL SYSTEM CHECK =========
git --version
python --version
pip --version
node --version
npm --version

echo.
echo ✅ System ready. You may now run setup.bat
pause
