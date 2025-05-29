const WebSocket = require('ws');
const { ROSBRIDGE_IP, FLUTTER_PORT } = require('./config/constants');

const wss = new WebSocket.Server({ port: FLUTTER_PORT || 8080 });
const rosbridge = new WebSocket(`ws://${ROSBRIDGE_IP}:9090`);

wss.on('connection', (flutterClient) => {
  console.log('Flutter client connected');
  
  // Forward Flutter → ROS
  flutterClient.on('message', (data) => {
    console.log('Flutter → ROS:', data);
    rosbridge.send(data);
  });

  // Forward ROS → Flutter
  rosbridge.on('message', (data) => {
    console.log('ROS → Flutter:', data);
    flutterClient.send(data);
  });

  // Error handling
  flutterClient.on('error', (err) => console.error('Flutter WS error:', err));
  rosbridge.on('error', (err) => console.error('ROS WS error:', err));
});

console.log(`WebSocket bridge running on port ${FLUTTER_PORT}`);