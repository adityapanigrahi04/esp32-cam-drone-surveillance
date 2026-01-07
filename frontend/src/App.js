import React, { useState, useEffect, useRef } from "react";
import {
  Camera,
  Circle,
  Video,
  Download,
  CheckCircle,
  AlertCircle,
} from "lucide-react";

function App() {
  const [esp32IP, setEsp32IP] = useState("192.168.4.1");
  const [backendURL, setBackendURL] = useState("http://localhost:5000");
  const [isConnected, setIsConnected] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [detections, setDetections] = useState([]);
  const [streamURL, setStreamURL] = useState("");
  const [status, setStatus] = useState("");
  const [recordings, setRecordings] = useState([]);
  const intervalRef = useRef(null);

  useEffect(() => {
    if (isConnected) fetchRecordings();
  }, [isConnected, backendURL]);

  useEffect(() => {
    return () => intervalRef.current && clearInterval(intervalRef.current);
  }, []);

  const fetchRecordings = async () => {
    const res = await fetch(`${backendURL}/recordings`);
    const data = await res.json();
    setRecordings(data.recordings || []);
  };

  const testConnection = async () => {
    setStatus("Testing connection...");
    try {
      const res = await fetch(`${backendURL}/test_esp32`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ esp32_ip: esp32IP }),
      });
      const data = await res.json();

      if (data.status === "success") {
        setIsConnected(true);
        setStreamURL(`${backendURL}/video_feed?esp32_ip=${esp32IP}`);
        setStatus("Connected successfully");
      } else {
        setIsConnected(false);
        setStatus(data.message || "Connection failed");
      }
    } catch (e) {
      setIsConnected(false);
      setStatus("Backend not reachable");
    }
  };

  const startRecording = async () => {
    const res = await fetch(`${backendURL}/start_recording`, { method: "POST" });
    const data = await res.json();
    if (data.status === "success") {
      setIsRecording(true);
      intervalRef.current = setInterval(async () => {
        const d = await fetch(`${backendURL}/detections`);
        const j = await d.json();
        setDetections(j.detections || []);
      }, 500);
    }
  };

  const stopRecording = async () => {
    await fetch(`${backendURL}/stop_recording`, { method: "POST" });
    intervalRef.current && clearInterval(intervalRef.current);
    setIsRecording(false);
    setDetections([]);
    fetchRecordings();
  };

  const downloadRecording = (f) =>
    window.open(`${backendURL}/download/${f}`, "_blank");

  return (
    <div className="min-h-screen bg-white text-gray-900 relative">
      <div className="max-w-7xl mx-auto px-6 py-8">

        {/* Header */}
        <div className="mb-8 pb-6 border-b border-gray-200 text-center relative">
          <h1 className="text-3xl font-medium">
            ESP32-CAM Drone Surveillance
          </h1>
          <p className="text-sm text-gray-500 mt-2">
            Live video monitoring and object detection
          </p>

          <button
            onClick={() =>
              fetch(`${backendURL}/shutdown`, { method: "POST" })
            }
            className="absolute right-0 top-0 bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded-md text-sm"
          >
            Exit Application
          </button>
        </div>

        {/* Main Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">

          {/* Left Controls */}
          <div className="lg:col-span-4 space-y-6">

            {/* Configuration */}
            <div className="border rounded-lg p-5">
              <h2 className="text-sm font-medium mb-4">Configuration</h2>

              <input
                value={esp32IP}
                onChange={(e) => setEsp32IP(e.target.value)}
                className="w-full border rounded px-3 py-2 text-sm mb-3"
                placeholder="ESP32 IP"
              />

              <input
                value={backendURL}
                onChange={(e) => setBackendURL(e.target.value)}
                className="w-full border rounded px-3 py-2 text-sm mb-3"
                placeholder="Backend URL"
              />

              <button
                onClick={testConnection}
                className="w-full bg-gray-900 text-white py-2 rounded"
              >
                Test Connection
              </button>

              {status && (
                <div className={`mt-3 p-2 text-sm rounded ${
                  isConnected ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
                }`}>
                  {status}
                </div>
              )}
            </div>

            {/* Recording */}
            {isConnected && (
              <div className="border rounded-lg p-5">
                {!isRecording ? (
                  <button
                    onClick={startRecording}
                    className="w-full bg-red-600 text-white py-2 rounded"
                  >
                    Start Recording
                  </button>
                ) : (
                  <button
                    onClick={stopRecording}
                    className="w-full bg-gray-700 text-white py-2 rounded"
                  >
                    Stop Recording
                  </button>
                )}
              </div>
            )}
          </div>

          {/* Live Feed */}
          <div className="lg:col-span-8 border rounded-lg p-5">
            <h2 className="text-sm font-medium mb-4 text-center">Live Feed</h2>
            <div className="aspect-video bg-gray-100 rounded overflow-hidden">
              {streamURL ? (
                <img src={streamURL} className="w-full h-full object-contain" />
              ) : (
                <div className="h-full flex items-center justify-center text-gray-400">
                  <Camera size={48} />
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Recordings */}
        <div className="mt-10 border rounded-lg p-5">
          <h2 className="text-sm font-medium mb-4 text-center">
            Saved Recordings
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {recordings.map((r, i) => (
              <div key={i} className="border rounded p-4">
                <p className="text-sm font-medium truncate">{r.filename}</p>
                <button
                  onClick={() => downloadRecording(r.filename)}
                  className="mt-3 w-full bg-gray-900 text-white py-2 text-xs rounded"
                >
                  Download
                </button>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}

export default App;
