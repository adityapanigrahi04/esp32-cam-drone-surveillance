# Drone Surveillance System

## Overview

This project implements a Drone Surveillance System, featuring both a Python-based backend for object detection (likely using YOLOv8) and a React-based frontend for user interaction and visualization. The system is designed to monitor and record activities, providing a comprehensive solution for drone-based surveillance.

## Features

*   **Real-time Object Detection**: Utilizes YOLOv8 models (`yolov8n.pt`, `yolov8s.pt`) for efficient and accurate object detection in video streams or images.
*   **Backend API**: A Python (`app.py`) backend handles video processing, object detection, and data management.
*   **Interactive Frontend**: A React application provides a user-friendly interface for viewing surveillance feeds, managing recordings, and interacting with the system.
*   **Scripted Operations**: Includes a suite of shell scripts for streamlined setup, starting, stopping, testing, and troubleshooting.

## Prerequisites

### For Linux Users

Ensure you have the following installed on your system:

*   **Git**: For cloning the repository.
*   **Python 3.x**: The backend requires Python. It's recommended to use Python 3.8 or newer.
*   **Node.js & npm/yarn**: The frontend requires Node.js and a package manager (npm or yarn).

### For Windows Users

Windows users are recommended to use the Windows Subsystem for Linux (WSL) for a smoother development experience, as the provided scripts are shell-based. Install the following:

*   **Windows Subsystem for Linux (WSL)**: Follow Microsoft's official guide to install WSL2 and a Linux distribution (e.g., Ubuntu).
*   **Git**: Install Git for Windows, which includes Git Bash.
*   **Python 3.x**: Install Python within your WSL environment.
*   **Node.js & npm/yarn**: Install Node.js and a package manager within your WSL environment.

## Getting Started

Follow these steps to get your Drone Surveillance System up and running.

### 1. Clone the Repository

First, clone the project repository to your local machine:

```bash
git clone <repository_url>
cd DRONE_SURVEILLANCE
```

Replace `<repository_url>` with the actual URL of your Git repository.

### 2. Run Setup Scripts

The project includes several shell scripts to automate the setup process.

#### Initial Checks

Run the `preCheck.sh` script to ensure all necessary prerequisites are met. (Note: This script is assumed to exist based on user request. If not provided, create one or remove this step.)

```bash
./sysCheck.sh
```

#### System Setup

Execute the `setup.sh` script to install dependencies for both the backend (Python) and frontend (Node.js/React).

```bash
./setup.sh
```

This script will typically:
*   Create a Python virtual environment and install `requirements.txt`.
*   Install Node.js packages using `npm install` or `yarn install` in the `frontend/` directory.

### 3. Start the System

To launch both the backend and frontend services, use the `start.sh` script:

```bash
./start.sh
```

This script is expected to start the Python backend (e.g., `python app.py`) and the React development server (e.g., `npm start` or `yarn start`).

### 4. Access the Application

Once the system is running, you can typically access the frontend application in your web browser at `http://localhost:3000` (or another port if configured differently).

## Operations

### Stopping the System

To gracefully stop all running services (backend and frontend), execute the `stop.sh` script:

```bash
./stop.sh
```

### Running Tests

To run the project's test suite, use the `test.sh` script:

```bash
./test.sh
```

### Troubleshooting

If you encounter any issues, the `troubleshoot.sh` script might provide diagnostic information or attempt to fix common problems:

```bash
./troubleshoot.sh
```

## Project Structure

```
DRONE_SURVEILLANCE/
├── backend/
│   ├── recordings/             # Directory for storing surveillance recordings
│   ├── venv/                   # Python virtual environment
│   ├── .env                    # Environment variables
│   ├── .python-version         # Specifies Python version
│   ├── app.py                  # Main backend application file
│   ├── requirements.txt        # Python dependencies
│   ├── yolov8n.pt              # YOLOv8 nano model weights
│   └── yolov8s.pt              # YOLOv8 small model weights
├── frontend/
│   ├── node_modules/           # Node.js dependencies
│   ├── public/                 # Public assets
│   ├── src/                    # React application source code
│   │   ├── App.css
│   │   ├── App.js
│   │   ├── App.test.js
│   │   ├── index.css
│   │   ├── index.js
│   │   ├── logo.svg
│   │   ├── reportWebVitals.js
│   │   └── setupTests.js
│   ├── .gitignore              # Git ignore for frontend
│   ├── package-lock.json       # npm package lock file
│   ├── package.json            # Node.js project metadata and dependencies
│   ├── postcss.config.js       # PostCSS configuration
│   └── tailwind.config.js      # Tailwind CSS configuration
├── .gitignore                  # Git ignore for the root directory
├── LICENSE                     # Project license file
├── README.md                   # This README file
├── setup.sh                    # Script to set up the project environment
├── start.sh                    # Script to start the application
├── stop.sh                     # Script to stop the application
├── sysCheck.sh                 # Script for system health checks
├── test.sh                     # Script to run tests
└── troubleshoot.sh             # Script for troubleshooting issues
```

## License

This project is licensed under the [LICENSE](LICENSE) file.