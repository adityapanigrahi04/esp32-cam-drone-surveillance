@echo off
echo ▶️ Starting ESP32 Drone Surveillance (Local) - Windows

:: ---------- Backend ----------
cd backend
call venv\Scripts\activate.bat

start cmd /k python app.py
echo ✅ Backend started

deactivate
cd ..

:: ---------- Frontend ----------
cd frontend
start cmd /k npm start
echo ✅ Frontend started
cd ..

:: ---------- Auto Open Browser ----------
echo ⏳ Waiting for model to load...
timeout /t 8 > nul

start http://localhost:3000

echo.
echo ✅ Application running
pause
