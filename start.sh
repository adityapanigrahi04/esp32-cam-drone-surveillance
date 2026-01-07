#!/bin/bash
set -e

echo "▶️ Starting ESP32 Drone Surveillance (Local)"

# ---------- Backend ----------
cd backend
source venv/bin/activate
python app.py &
BACKEND_PID=$!
deactivate
cd ..

# ---------- Frontend ----------
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

# ---------- Auto Open Browser ----------
# YOLO model load takes time
sleep 8

URL="http://localhost:3000"

if command -v xdg-open &> /dev/null; then
  xdg-open "$URL"
elif command -v open &> /dev/null; then
  open "$URL"
else
  echo "🌐 Open manually: $URL"
fi

echo ""
echo "✅ Application running"
echo "Backend PID : $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
