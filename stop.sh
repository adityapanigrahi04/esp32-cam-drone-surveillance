#!/bin/bash

echo "🛑 Stopping ESP32 Drone Surveillance..."

pkill -f "python app.py" || true
pkill -f "react-scripts start" || true

echo "✅ All services stopped"
