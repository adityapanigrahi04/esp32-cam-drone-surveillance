@echo off
echo ============================================
echo   ESP32 Drone Surveillance - Precheck (Win)
echo ============================================

:: ---- OS Info ----
echo Checking OS...
powershell -command "(Get-CimInstance Win32_OperatingSystem).Caption"

:: ---- Architecture ----
echo Checking architecture...
echo %PROCESSOR_ARCHITECTURE%

:: ---- Admin Check ----
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Please run PowerShell as ADMIN
    pause
    exit /b 1
) else (
    echo ✅ Running as Administrator
)

:: ---- Git ----
echo Checking Git...
git --version >nul 2>&1 || (
    echo ❌ Git not installed
    pause
    exit /b 1
)
echo ✅ Git OK

:: ---- Python ----
echo Checking Python...
python --version >nul 2>&1 || (
    echo ❌ Python not installed
    pause
    exit /b 1
)
echo ✅ Python OK

:: ---- Node ----
echo Checking Node.js...
node --version >nul 2>&1 || (
    echo ❌ Node.js not installed
    pause
    exit /b 1
)
echo ✅ Node.js OK

echo ============================================
echo ✅ SYSTEM CHECK PASSED
echo ============================================
pause
