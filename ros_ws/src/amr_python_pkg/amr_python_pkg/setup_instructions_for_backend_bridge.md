# Setup Instructions:

## 1) Copy the script to your AMR:
- ssh piros@192.168.x.x,
- nano ~/amr_backend_bridge.py,
- chmod +x ~/amr_backend_bridge.py

## 2) Install dependencies:
- pip3 install websocket-client requests

## 3) Run the bridge:
- python3 ~/amr_backend_bridge.py

## 4) Make it auto-start (optional):
- echo "python3 ~/amr_backend_bridge.py &" >> ~/.bashrc
