@echo off
setlocal enabledelayedexpansion

echo 🚀 Setting up ESP32 Drone Surveillance (Local) - Windows

:: ---------- Backend ----------
cd backend

if not exist venv (
    python -m venv venv
)

call venv\Scripts\activate.bat

python -m pip install --upgrade pip

:: Torch CPU wheels
pip install torch==2.1.2 torchvision==0.16.2 ^
 --index-url https://download.pytorch.org/whl/cpu

pip install -r requirements.txt

deactivate
cd ..

:: ---------- Frontend ----------
cd frontend
npm install
cd ..

echo ✅ Setup completed successfully
pause
