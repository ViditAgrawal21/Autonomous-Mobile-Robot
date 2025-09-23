Setup Instructions:

# 1) Copy the script to your AMR:

bashssh pi@192.168.128.240
nano ~/amr_backend_bridge.py
--Paste the code above
chmod +x ~/amr_backend_bridge.py

# 2) Install dependencies:

bashpip3 install websocket-client requests

# 3) Run the bridge:

bashpython3 ~/amr_backend_bridge.py

# 4) Make it auto-start (optional):

bash# Add to startup
echo "python3 ~/amr_backend_bridge.py &" >> ~/.bashrc
