// rosbridge/ros_client.js
const WebSocket = require('ws');
const { ROSBRIDGE_IP, ROSBRIDGE_PORT } = require('../config');

const ROS_URL = `ws://${ROSBRIDGE_IP}:${ROSBRIDGE_PORT}`;
let rosSocket = null;
let onDataCallback = null;

function connectToROS() {
  rosSocket = new WebSocket(ROS_URL);

  rosSocket.on('open', () => {
    console.log('✅ Connected to ROSBridge');

    // Example: Subscribe to a topic
    rosSocket.send(JSON.stringify({
      op: "subscribe",
      topic: "/battery_state"
    }));
  });

  rosSocket.on('message', (data) => {
    const msg = JSON.parse(data);
    if (onDataCallback) {
      onDataCallback(msg);
    }
  });

  rosSocket.on('close', () => {
    console.log('⚠️ ROSBridge Disconnected');
    // Optional: Reconnect logic
  });

  rosSocket.on('error', (err) => {
    console.error('❌ ROSBridge Error:', err.message);
  });

  return rosSocket;
}

// Register callback to receive ROS data
function onRosData(callback) {
  onDataCallback = callback;
}

// Handle commands coming from Flutter → ROS
function handleFlutterCommand(command) {
  if (!rosSocket || rosSocket.readyState !== WebSocket.OPEN) {
    console.warn('ROS socket not ready');
    return;
  }

  // You can add more commands here
  switch (command.type) {
    case "start_agv":
      rosSocket.send(JSON.stringify({
        op: "publish",
        topic: "/start_agv",
        msg: { data: true }
      }));
      break;

    case "stop_agv":
      rosSocket.send(JSON.stringify({
        op: "publish",
        topic: "/stop_agv",
        msg: { data: true }
      }));
      break;

    default:
      console.log("Unknown command:", command);
  }
}

module.exports = {
  connectToROS,
  handleFlutterCommand,
  onRosData,
};
