@echo off
echo ============================================
echo   ESP32 Drone Surveillance - Start (Windows)
echo ============================================

:: ---------------- BACKEND ----------------
echo.
echo [1/2] Starting Backend...

if not exist backend (
    echo ❌ Backend folder not found
    pause
    exit /b 1
)

cd backend || exit /b 1

if not exist venv\Scripts\activate.bat (
    echo ❌ Python virtual environment not found
    echo 👉 Please run setup.bat first
    pause
    exit /b 1
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Launching backend server...
start "Backend Server" cmd /k python app.py

cd ..

echo ✅ Backend started

:: ---------------- FRONTEND ----------------
echo.
echo [2/2] Starting Frontend...

if not exist frontend (
    echo ❌ Frontend folder not found
    pause
    exit /b 1
)

cd frontend || exit /b 1

echo Launching frontend server...
start "Frontend Server" cmd /k npm start

cd ..

echo ✅ Frontend started

:: ---------------- BROWSER ----------------
echo.
echo ⏳ Waiting for services to initialize...
timeout /t 10 >nul

echo Opening browser...
start http://localhost:3000

echo.
echo ============================================
echo ✅ APPLICATION RUNNING
echo ============================================
echo Close the backend and frontend windows to stop the app
pause
