# ESP32-CAM Drone Surveillance System

A simple real-time drone surveillance system using **ESP32-CAM**, **FastAPI**, and **YOLO** for human and object detection.

The ESP32-CAM streams live video, which is processed on the backend using OpenCV and YOLO. The detected and annotated video is then streamed to a web-based frontend for monitoring and recording.

## Features
- Live video streaming from ESP32-CAM
- Real-time human & object detection (YOLO)
- Backend-driven MJPEG streaming (stable)
- Video recording with timestamps
- Simple web dashboard for monitoring

## Tech Stack
- **Hardware:** ESP32-CAM, Drone frame
- **Backend:** FastAPI, OpenCV, YOLOv8
- **Frontend:** React + Vite
- **Streaming:** MJPEG over HTTP

## How It Works
ESP32-CAM → FastAPI (Detection & Processing) → Web UI

## Use Cases
- Drone surveillance
- Human detection
- Security monitoring
- Academic & learning projects

---

> This project is built for learning, experimentation, and academic demonstration.
