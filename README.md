
# 🤖 AGV Fleet Control System – Expo Demo

This project is a real-time control and visualization interface for an Autonomous Guided Vehicle (AGV) system using Flutter (frontend), Node.js (backend), and ROS2 (robot interface). Designed specifically for an expo demo, it allows you to monitor, control, and interact with your AGV through a clean UI.

---

## 🧱 Architecture Overview

```
Flutter App (Tablet/Desktop)
   ↕ WebSocket
Node.js Backend
   ↕ WebSocket
ROS2 + rosbridge_server
   ↔ AGV (Hardware or Simulation)
```

---

## 🧭 Features

### ✅ Flutter App (Frontend)
- Robot connection screen
- Real-time battery and pose tracking
- Interactive map display with live AGV path
- Pencil/Eraser/Obstacle map editing tools
- Joystick-based manual AGV control
- Analytics screen: distance, battery, time

### ✅ Node.js Backend
- Acts as bridge between Flutter and ROS
- WebSocket server for real-time communication
- Forwards joystick commands and map edits to ROS
- Parses and reformats ROS messages into frontend-friendly JSON
- Optionally logs and simulates data for testing

---

## 📂 Folder Structure

```
lib/
├── screens/            # Flutter UI Screens
├── widgets/            # Live map, joystick, tools
├── services/           # WebSocket service to backend
├── utils/              # Map scaling, ROS parsing

agv_fleet_backend/
├── server.js           # WebSocket server
├── rosbridge/          # ROS WebSocket client
├── utils/              # Message parsing, map conversion
├── config/             # IPs, ports, topic names
```

---

## ⚙️ How to Run

### 🔹 1. Start ROS with rosbridge
```bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
```

### 🔹 2. Run Node.js backend
```bash
cd agv_fleet_backend
npm install
node server.js
```

### 🔹 3. Run Flutter app
```bash
cd agv_fleet_app
flutter pub get
flutter run
```

---

## 🧪 Simulated Demo Mode

Don’t have an AGV? No problem!

- The backend includes mock data emitters for:
  - Pose updates
  - Battery percentage
  - Distance tracking
- Flutter UI still shows real-time map, joystick, and analytics

---

## 📡 WebSocket Message Format

Example:
```json
{
  "type": "AGV_POSE_UPDATE",
  "payload": { "x": 4.21, "y": 1.72, "theta": 0.95 }
}
```

---

## 🛠️ Future Roadmap

- ✅ Real-time joystick control
- ✅ Map editing and upload to AGV
- ⏳ Persistent map save and reload
- ⏳ Multi-AGV support with task queue
- ⏳ Database integration for analytics

---

## 🙌 Contributors

- **[Vidit Agrawal]** – Frontend (Flutter) & System Architecture
- **[Vidit Agrawal & Prathamesh Pranjale]** – Backend (Node.js)
- **ROS Team** – Backend ROS Integration

---

## 🧠 Tech Stack

- Flutter 3.x
- Node.js 18+
- WebSocket (ws)
- ROS 2 Humble + rosbridge
- YAML, PGM map files

---

## 📜 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---
