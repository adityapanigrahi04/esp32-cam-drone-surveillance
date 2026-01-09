@echo off
echo 🧪 Running system tests...

echo.
echo 🔍 Backend health:
curl http://localhost:5000/health || echo ❌ Backend not responding

echo.
echo 🔍 ESP32 connection test (default IP):
curl -X POST http://localhost:5000/test_esp32 ^
 -H "Content-Type: application/json" ^
 -d "{\"esp32_ip\":\"192.168.4.1\"}" || echo ❌ ESP32 not reachable

echo.
echo 🔍 MJPEG endpoint test:
curl -I "http://localhost:5000/video_feed?esp32_ip=192.168.4.1" || echo ❌ Stream not reachable

echo.
echo ✅ Test completed
pause
