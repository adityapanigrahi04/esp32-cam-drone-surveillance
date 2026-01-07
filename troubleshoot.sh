#!/bin/bash

echo "🛠️ ESP32 Drone Surveillance Diagnostics"
echo "--------------------------------------"

echo ""
echo "📌 Versions"
python3 --version
node --version
npm --version

echo ""
echo "📌 Ports"
lsof -i :5000 || echo "Port 5000 free"
lsof -i :3000 || echo "Port 3000 free"

echo ""
echo "📌 Running Processes"
ps aux | grep app.py | grep -v grep || echo "Backend not running"
ps aux | grep "react-scripts start" | grep -v grep || echo "Frontend not running"

echo ""
echo "📌 Python dependencies"
cd backend
source venv/bin/activate
pip check || echo "Dependency issues detected"
deactivate
cd ..

echo ""
echo "📌 Recordings"
ls -lh backend/recordings || echo "No recordings yet"

echo ""
echo "✅ Troubleshooting completed"
