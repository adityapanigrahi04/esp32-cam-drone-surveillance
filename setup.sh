#!/bin/bash
set -e

echo "🚀 Setting up ESP32 Drone Surveillance (Local)"

# ---------- Backend ----------
cd backend

if [ ! -d "venv" ]; then
  python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip

# Torch CPU wheels (important for your versions)
pip install torch==2.1.2 torchvision==0.16.2 \
  --index-url https://download.pytorch.org/whl/cpu

pip install -r requirements.txt

deactivate
cd ..

# ---------- Frontend ----------
cd frontend
npm install
cd ..

echo "✅ Setup completed successfully"
