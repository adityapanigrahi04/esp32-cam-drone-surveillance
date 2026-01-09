#!/usr/bin/env bash
set -e

echo "============================================"
echo " ESP32 Drone Surveillance - Precheck (Unix)"
echo "============================================"

# ---------- Architecture ----------
echo "Checking system architecture..."
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo "❌ 64-bit system required"
  exit 1
fi
echo "✅ 64-bit architecture detected"

# ---------- Internet ----------
echo "Checking internet..."
ping -c 1 google.com > /dev/null || {
  echo "❌ Internet connection required"
  exit 1
}
echo "✅ Internet available"

# ---------- Update ----------
sudo apt update -y

# ---------- Git ----------
if ! command -v git &> /dev/null; then
  echo "Installing Git..."
  sudo apt install git -y
fi
git --version

# ---------- Python 3.10 ----------
if ! python3.10 --version &> /dev/null; then
  echo "Installing Python 3.10..."
  sudo apt install python3.10 python3.10-venv python3.10-dev python3-pip -y
fi

python3.10 --version
pip3 --version

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# ---------- Node.js 18 LTS ----------
if ! node --version | grep -q "v18"; then
  echo "Installing Node.js 18 LTS..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt install nodejs -y
fi

node --version
npm --version

# ---------- Build Dependencies ----------
echo "Installing build dependencies..."
sudo apt install -y build-essential cmake pkg-config \
libjpeg-dev libpng-dev libtiff-dev \
libavcodec-dev libavformat-dev libswscale-dev \
libgtk2.0-dev libgtk-3-dev

# ---------- Final Check ----------
echo
echo "========= FINAL SYSTEM CHECK ========="
git --version
python --version
pip --version
node --version
npm --version

echo
echo "✅ System ready. You may now run setup.sh"
