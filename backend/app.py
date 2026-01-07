from flask import Flask, Response, jsonify, request, send_file
from flask_cors import CORS
import cv2
import numpy as np
from ultralytics import YOLO
import requests
import time
import os
from datetime import datetime
import threading
import json

ESP32_STREAM_URL = "http://{ip}/stream"

app = Flask(__name__)
CORS(app)

# Configuration
RECORDINGS_DIR = 'recordings'
os.makedirs(RECORDINGS_DIR, exist_ok=True)

# Global variables
model = None
current_detections = []
is_recording = False
video_writer = None
current_recording_file = None
recording_detections = set()
recording_lock = threading.Lock()
stream_active = False

def load_yolo_model():
    """Load YOLO model"""
    global model
    try:
        model = YOLO('yolov8n.pt')
        print("✓ YOLO model loaded successfully")
        return True
    except Exception as e:
        print(f"✗ Error loading YOLO model: {e}")
        print("Downloading YOLOv8s model...")
        try:
            model = YOLO('yolov8s.pt')
            print("✓ YOLO model downloaded and loaded")
            return True
        except Exception as e2:
            print(f"✗ Failed to download model: {e2}")
            return False

def detect_objects(frame):
    """Run YOLO detection on frame"""
    global current_detections, recording_detections
    
    if model is None:
        return frame, []
    
    try:
        results = model(frame, conf=0.45, verbose=False)
        detections = []
        
        for result in results:
            boxes = result.boxes
            for box in boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                conf = float(box.conf[0])
                cls = int(box.cls[0])
                class_name = model.names[cls]
                
                # Draw bounding box
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                
                # Draw label with background
                label = f'{class_name} {conf:.2f}'
                (w, h), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 1)
                cv2.rectangle(frame, (x1, y1 - 20), (x1 + w, y1), (0, 255, 0), -1)
                cv2.putText(frame, label, (x1, y1 - 5), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 0), 1)
                
                detection = {
                    'class': class_name,
                    'confidence': conf,
                    'bbox': [x1, y1, x2, y2]
                }
                detections.append(detection)
                
                if is_recording:
                    recording_detections.add(class_name)
        
        current_detections = detections
        return frame, detections
        
    except Exception as e:
        print(f"Error in detection: {e}")
        return frame, []

def read_mjpeg_stream(url):
    """Read MJPEG stream from ESP32-CAM"""
    try:
        stream = requests.get(url, stream=True, timeout=5)
        if stream.status_code != 200:
            return None
            
        bytes_data = bytes()
        for chunk in stream.iter_content(chunk_size=1024):
            bytes_data += chunk
            a = bytes_data.find(b'\xff\xd8')  # JPEG start
            b = bytes_data.find(b'\xff\xd9')  # JPEG end
            
            if a != -1 and b != -1:
                jpg = bytes_data[a:b+2]
                bytes_data = bytes_data[b+2:]
                
                # Decode JPEG
                frame = cv2.imdecode(np.frombuffer(jpg, dtype=np.uint8), cv2.IMREAD_COLOR)
                if frame is not None:
                    yield frame
                    
    except Exception as e:
        print(f"Error reading stream: {e}")
        return None

def generate_frames(esp32_ip):
    """Generate video frames with detection from ESP32 stream"""
    global stream_active, video_writer, is_recording
    
    stream_url = ESP32_STREAM_URL.format(ip=esp32_ip)
    stream_active = True
    
    while stream_active:
        try:
            for frame in read_mjpeg_stream(stream_url):
                if not stream_active:
                    break
                    
                if frame is None:
                    continue
                
                # Perform detection
                frame, _ = detect_objects(frame)

                frame = cv2.resize(frame, (960, 720))
                
                # Write to video file if recording
                if is_recording and video_writer is not None:
                    with recording_lock:
                        try:
                            video_writer.write(frame)
                        except:
                            pass
                
                # Encode frame for streaming
                ret, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
                if not ret:
                    continue
                    
                frame_bytes = buffer.tobytes()
                
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
                
        except Exception as e:
            print(f"Stream error: {e}")
            # Generate error frame
            error_frame = np.zeros((240, 320, 3), dtype=np.uint8)
            cv2.putText(error_frame, 'Connection Lost', (50, 120),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
            ret, buffer = cv2.imencode('.jpg', error_frame)
            frame_bytes = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
            time.sleep(1)

@app.route('/test_esp32', methods=['POST'])
def test_esp32():
    """Test ESP32 camera connection"""
    data = request.json
    esp32_ip = data.get('esp32_ip', '192.168.4.1')
    
    try:
        # Test the stream endpoint
        response = requests.get(ESP32_STREAM_URL.format(ip=esp32_ip), stream=True, timeout=3)
        if response.status_code == 200:
            return jsonify({
                'status': 'success',
                'message': 'ESP32-CAM connected successfully',
                'stream_url': ESP32_STREAM_URL.format(ip=esp32_ip)
            })
        else:
            return jsonify({
                'status': 'error',
                'message': f'ESP32 returned status code {response.status_code}'
            }), 400
    except requests.exceptions.Timeout:
        return jsonify({
            'status': 'error',
            'message': 'Connection timeout. Check ESP32 IP address and network.'
        }), 400
    except requests.exceptions.ConnectionError:
        return jsonify({
            'status': 'error',
            'message': 'Cannot connect to ESP32. Make sure it\'s powered on and connected to WiFi.'
        }), 400
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error: {str(e)}'
        }), 400

@app.route('/video_feed')
def video_feed():
    """Video streaming route with detection"""
    esp32_ip = request.args.get('esp32_ip', '192.168.4.1')
    return Response(generate_frames(esp32_ip),
                   mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/start_recording', methods=['POST'])
def start_recording():
    global is_recording, video_writer, current_recording_file, recording_detections

    if is_recording:
        return jsonify({'status': 'error', 'message': 'Already recording'}), 400

    # Fixed resolution (must match generate_frames resize)
    width, height = 960, 720

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    current_recording_file = f'drone_recording_{timestamp}.mp4'
    filepath = os.path.join(RECORDINGS_DIR, current_recording_file)

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    video_writer = cv2.VideoWriter(filepath, fourcc, 20.0, (width, height))

    if not video_writer.isOpened():
        return jsonify({'status': 'error', 'message': 'Failed to create video file'}), 400

    is_recording = True
    recording_detections = set()

    return jsonify({
        'status': 'success',
        'message': 'Recording started',
        'filename': current_recording_file,
        'resolution': f'{width}x{height}'
    })


@app.route('/stop_recording', methods=['POST'])
def stop_recording():
    """Stop recording video"""
    global is_recording, video_writer, current_recording_file, recording_detections
    
    if not is_recording:
        return jsonify({'status': 'error', 'message': 'Not currently recording'}), 400
    
    with recording_lock:
        is_recording = False
        if video_writer is not None:
            video_writer.release()
            video_writer = None
    
    # Save detection metadata
    metadata_file = current_recording_file.replace('.mp4', '_metadata.json')
    metadata_path = os.path.join(RECORDINGS_DIR, metadata_file)
    
    metadata = {
        'filename': current_recording_file,
        'timestamp': datetime.now().isoformat(),
        'detections': list(recording_detections),
        'detection_count': len(recording_detections)
    }
    
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    filename = current_recording_file
    current_recording_file = None
    detections = list(recording_detections)
    recording_detections = set()
    
    return jsonify({
        'status': 'success',
        'message': 'Recording stopped and saved',
        'filename': filename,
        'detections': detections
    })

@app.route('/detections')
def get_detections():
    """Get current detections"""
    return jsonify({
        'detections': current_detections,
        'count': len(current_detections)
    })

@app.route('/recordings')
def get_recordings():
    """Get list of all recordings"""
    recordings = []
    
    for filename in os.listdir(RECORDINGS_DIR):
        if filename.endswith('.mp4'):
            filepath = os.path.join(RECORDINGS_DIR, filename)
            metadata_file = filename.replace('.mp4', '_metadata.json')
            metadata_path = os.path.join(RECORDINGS_DIR, metadata_file)
            
            recording_info = {
                'filename': filename,
                'timestamp': datetime.fromtimestamp(os.path.getctime(filepath)).strftime('%Y-%m-%d %H:%M:%S'),
                'size': f"{os.path.getsize(filepath) / 1024 / 1024:.2f} MB",
                'detections': []
            }
            
            if os.path.exists(metadata_path):
                try:
                    with open(metadata_path, 'r') as f:
                        metadata = json.load(f)
                        recording_info['detections'] = metadata.get('detections', [])
                except:
                    pass
            
            recordings.append(recording_info)
    
    recordings.sort(key=lambda x: x['timestamp'], reverse=True)
    return jsonify({'recordings': recordings})

@app.route('/download/<filename>')
def download_recording(filename):
    """Download a recording"""
    filepath = os.path.join(RECORDINGS_DIR, filename)
    if os.path.exists(filepath):
        return send_file(filepath, as_attachment=True)
    return jsonify({'status': 'error', 'message': 'File not found'}), 404

@app.route('/flash', methods=['POST'])
def control_flash():
    """Control ESP32 flash LED"""
    data = request.json
    esp32_ip = data.get('esp32_ip', '192.168.4.1')
    value = data.get('value', 0)
    
    try:
        response = requests.get(f'http://{esp32_ip}/flash?val={value}', timeout=2)
        if response.status_code == 200:
            return jsonify({'status': 'success', 'message': f'Flash set to {value}'})
        else:
            return jsonify({'status': 'error', 'message': 'Failed to control flash'}), 400
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 400

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'is_recording': is_recording,
        'stream_active': stream_active
    })


if __name__ == '__main__':
    print("=" * 60)
    print("🚁 ESP32-CAM Drone Surveillance System - Backend Server")
    print("=" * 60)
    
    print("\n[1/2] Loading YOLO model...")
    if load_yolo_model():
        print("✓ Model ready for object detection")
    else:
        print("✗ Warning: Running without detection capability")
    
    print("\n[2/2] Starting Flask server...")
    print("✓ Server starting on http://localhost:5000")
    print(f"\n📁 Recordings will be saved to: {os.path.abspath(RECORDINGS_DIR)}")
    print("\n📡 ESP32-CAM Configuration:")
    print("   • Default IP: 192.168.4.1")
    print("   • Stream endpoint: http://192.168.4.1/stream")
    print("   • No ESP32 code changes needed!")
    print("\n💡 Tips:")
    print("   • Make sure your computer is connected to the ESP32 WiFi")
    print("   • Or ensure ESP32 and computer are on the same network")
    print("\nPress Ctrl+C to stop the server")
    print("=" * 60 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)