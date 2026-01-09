@echo off
echo 🛑 Stopping ESP32 Drone Surveillance...

:: Stop Python backend
taskkill /F /IM python.exe >nul 2>&1

:: Stop React frontend
taskkill /F /IM node.exe >nul 2>&1

echo ✅ All services stopped
pause
