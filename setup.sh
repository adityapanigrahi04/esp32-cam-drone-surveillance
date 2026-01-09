#!/usr/bin/env bash
set -e

echo "🚀 Setting up ESP32 Drone Surveillance (Local)"

# ---------- Ensure venv support ----------
echo "🔍 Ensuring Python venv support..."
sudo apt update
sudo apt install -y python3.10-venv python3-pip

# ---------- Backend ----------
echo "⚙️ Setting up backend..."
cd backend

# Remove broken venv if it exists
if [ -d "venv" ] && [ ! -f "venv/bin/activate" ]; then
  echo "⚠️ Broken venv detected. Recreating..."
  rm -rf venv
fi

# Create venv if missing
if [ ! -d "venv" ]; then
  echo "📦 Creating virtual environment..."
  python3.10 -m venv venv
fi

# Safety check
if [ ! -f "venv/bin/activate" ]; then
  echo "❌ Virtual environment creation failed"
  exit 1
fi

# Activate venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Torch CPU wheels (explicit + safe)
pip install torch==2.1.2 torchvision==0.16.2 \
  --index-url https://download.pytorch.org/whl/cpu

# Install backend dependencies
pip install -r requirements.txt

# Deactivate venv
deactivate
cd ..

# ---------- Frontend ----------
echo "🎨 Setting up frontend..."
cd frontend
npm install
cd ..

echo "✅ Setup completed successfully"
