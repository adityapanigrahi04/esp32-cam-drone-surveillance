@echo off
echo 🛠️ ESP32 Drone Surveillance Diagnostics
echo --------------------------------------

:: ---------- Versions ----------
echo.
echo 📌 Versions
python --version
node --version
npm --version

:: ---------- Ports ----------
echo.
echo 📌 Ports
netstat -ano | findstr :5000 >nul && echo Port 5000 in use || echo Port 5000 free
netstat -ano | findstr :3000 >nul && echo Port 3000 in use || echo Port 3000 free

:: ---------- Running Processes ----------
echo.
echo 📌 Running Processes
tasklist | findstr python.exe >nul || echo Backend not running
tasklist | findstr node.exe >nul || echo Frontend not running

:: ---------- Python Dependencies ----------
echo.
echo 📌 Python dependencies
cd backend
call venv\Scripts\activate.bat
pip check || echo Dependency issues detected
deactivate
cd ..

:: ---------- Recordings ----------
echo.
echo 📌 Recordings
if exist backend\recordings (
    dir backend\recordings
) else (
    echo No recordings yet
)

echo.
echo ✅ Troubleshooting completed
pause
