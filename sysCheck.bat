@echo off
setlocal

echo ============================================
echo   ESP32 Drone Surveillance - System Precheck
echo ============================================

:: ---------------- OS INFO ----------------
echo.
echo [1/6] Checking Operating System...
powershell -command "(Get-CimInstance Win32_OperatingSystem).Caption" || (
    echo ❌ Failed to detect OS
    exit /b 1
)

:: ---------------- ARCH ----------------
echo.
echo [2/6] Checking System Architecture...
echo Architecture: %PROCESSOR_ARCHITECTURE%

:: ---------------- ADMIN ----------------
echo.
echo [3/6] Checking Administrator Privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Please run Windows Terminal / PowerShell as ADMIN
    pause
    exit /b 1
)
echo ✅ Administrator access confirmed

:: ---------------- GIT ----------------
echo.
echo [4/6] Checking Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git NOT installed
    echo 👉 Install from https://git-scm.com
    pause
    exit /b 1
)
git --version
echo ✅ Git OK

:: ---------------- PYTHON ----------------
echo.
echo [5/6] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python NOT installed or not in PATH
    echo 👉 Install from https://www.python.org (check "Add to PATH")
    pause
    exit /b 1
)
python --version
echo ✅ Python OK

:: ---------------- NODE + NPM ----------------
echo.
echo [6/6] Checking Node.js and npm...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js NOT installed
    echo 👉 Install LTS from https://nodejs.org
    pause
    exit /b 1
)

npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm NOT available
    pause
    exit /b 1
)

node --version
npm --version
echo ✅ Node.js and npm OK

:: ---------------- SUCCESS ----------------
echo.
echo ============================================
echo ✅ SYSTEM CHECK PASSED - READY TO SETUP
echo ============================================
pause
