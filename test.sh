#!/bin/bash

echo "🧪 Running system tests..."

echo ""
echo "🔍 Backend health:"
curl -s http://localhost:5000/health | jq || echo "❌ Backend not responding"

echo ""
echo "🔍 ESP32 connection test (default IP):"
curl -s -X POST http://localhost:5000/test_esp32 \
  -H "Content-Type: application/json" \
  -d '{"esp32_ip":"192.168.4.1"}' | jq || echo "❌ ESP32 not reachable"

echo ""
echo "🔍 MJPEG endpoint test:"
curl -I "http://localhost:5000/video_feed?esp32_ip=192.168.4.1" || echo "❌ Stream not reachable"

echo ""
echo "✅ Test completed"
