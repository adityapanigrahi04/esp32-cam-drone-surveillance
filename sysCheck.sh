#!/usr/bin/env bash
set -e

PROJECT_NAME="esp32-cam-drone-surveillance"
REPO_URL="https://github.com/adityapanigrahi04/esp32-cam-drone-surveillance.git"

echo "================================================="
echo " ESP32 Drone Surveillance - System Precheck (WSL)"
echo "================================================="

# ---------- WSL Check ----------
echo "[1/8] Checking WSL environment..."
if ! grep -qi microsoft /proc/version; then
  echo "❌ This script must be run inside WSL (Ubuntu on Windows)"
  exit 1
fi
echo "✅ Running inside WSL"

# ---------- Architecture ----------
echo "[2/8] Checking system architecture..."
ARCH="$(uname -m)"
if [ "$ARCH" != "x86_64" ]; then
  echo "❌ 64-bit system required (x86_64)"
  exit 1
fi
echo "✅ 64-bit architecture detected"

# ---------- Internet ----------
echo "[3/8] Checking internet connectivity..."
if ! ping -c 1 google.com >/dev/null 2>&1; then
  echo "❌ Internet connection required"
  exit 1
fi
echo "✅ Internet available"

# ---------- Update ----------
echo "[4/8] Updating system..."
sudo apt update -y

# ---------- Git ----------
echo "[5/8] Checking Git..."
if ! command -v git >/dev/null 2>&1; then
  echo "Installing Git..."
  sudo apt install -y git
fi
git --version

# ---------- Python 3.10 ----------
echo "[6/8] Checking Python 3.10..."
if ! command -v python3.10 >/dev/null 2>&1; then
  echo "Installing Python 3.10..."
  sudo apt install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip
fi

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Ensure pip command exists
if ! command -v pip &> /dev/null; then
  sudo ln -s /usr/bin/pip3 /usr/bin/pip
fi

python --version
pip3 --version

# ---------- Node.js 20 LTS ----------
echo "[7/8] Checking Node.js 20 LTS..."
if ! command -v node >/dev/null 2>&1 || ! node --version | grep -q "^v20"; then
  echo "Installing Node.js 20 LTS..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
fi

node --version
npm --version

# ---------- Build Dependencies ----------
echo "[8/8] Installing build dependencies..."
sudo apt install -y \
  build-essential \
  cmake \
  pkg-config \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libavcodec-dev \
  libavformat-dev \
  libswscale-dev \
  libgtk2.0-dev \
  libgtk-3-dev

# ---------- Final Summary ----------
echo
echo "================ SYSTEM READY ================"
echo "Project: $PROJECT_NAME"
echo "Path:    $(pwd)"
echo "Git:     $(git --version)"
echo "Python:  $(python --version)"
echo "Pip:     $(pip --version)"
echo "Node:    $(node --version)"
echo "NPM:     $(npm --version)"
echo "=============================================="
echo
echo "✅ Precheck complete."
echo "👉 Next steps:"
echo "   ./setup.sh"
echo "   ./start-all.sh"
echo
