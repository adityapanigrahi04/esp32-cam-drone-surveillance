#!/usr/bin/env bash
set -e

echo "🚀 Setting up ESP32 Drone Surveillance (Local)"

# ---------- Ensure venv support ----------
echo "🔍 Checking Python venv support..."
if ! python3 -m venv --help >/dev/null 2>&1; then
  echo "Installing python3.10-venv..."
  sudo apt update
  sudo apt install -y python3.10-venv
fi

# ---------- Backend ----------
echo "⚙️ Setting up backend..."
cd backend

if [ ! -d "venv" ]; then
  python3 -m venv venv
fi

source venv/bin/activate

pip install --upgrade pip

# Torch CPU wheels (explicit + safe)
pip install torch==2.1.2 torchvision==0.16.2 \
  --index-url https://download.pytorch.org/whl/cpu

pip install -r requirements.txt

deactivate
cd ..

# ---------- Frontend ----------
echo "🎨 Setting up frontend..."
cd frontend
npm install
cd ..

echo "✅ Setup completed successfully"
