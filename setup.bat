@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   ESP32 Drone Surveillance - Setup (Windows)
echo ============================================

:: ---------------- BACKEND ----------------
echo.
echo [1/2] Setting up Backend...

if not exist backend (
    echo ❌ Backend folder not found
    pause
    exit /b 1
)

cd backend || exit /b 1

if not exist venv (
    echo Creating Python virtual environment...
    python -m venv venv || (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
)

call venv\Scripts\activate.bat || (
    echo ❌ Failed to activate virtual environment
    pause
    exit /b 1
)

echo Upgrading pip...
python -m pip install --upgrade pip || (
    echo ❌ Failed to upgrade pip
    pause
    exit /b 1
)

echo Installing PyTorch (CPU)...
pip install torch==2.1.2 torchvision==0.16.2 ^
 --index-url https://download.pytorch.org/whl/cpu || (
    echo ❌ Failed to install PyTorch
    pause
    exit /b 1
)

echo Installing backend requirements...
pip install -r requirements.txt || (
    echo ❌ Failed to install backend requirements
    pause
    exit /b 1
)

deactivate
cd ..

echo ✅ Backend setup completed

:: ---------------- FRONTEND ----------------
echo.
echo [2/2] Setting up Frontend...

if not exist frontend (
    echo ❌ Frontend folder not found
    pause
    exit /b 1
)

cd frontend || exit /b 1

npm install || (
    echo ❌ npm install failed
    pause
    exit /b 1
)

cd ..

echo.
echo ============================================
echo ✅ SETUP COMPLETED SUCCESSFULLY
echo ============================================
pause
