#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist, PoseWithCovarianceStamped
from sensor_msgs.msg import LaserScan, BatteryState
from nav_msgs.msg import OccupancyGrid
import requests
import websocket
import json
import threading
import time

class AMRBackendBridge(Node):
    def __init__(self):
        super().__init__('amr_backend_bridge')
        
        # Backend configuration
        self.backend_url = "https://fleetos-backend-frp4.onrender.com"
        self.ws_url = "wss://fleetos-backend-frp4.onrender.com"
        self.device_id = "piros"  # Your AMR device ID
        
        # Initialize WebSocket
        self.ws = None
        self.connect_websocket()
        
        # ROS2 subscriptions
        self.create_subscription(PoseWithCovarianceStamped, '/amcl_pose', self.pose_callback, 10)
        self.create_subscription(BatteryState, '/battery_status', self.battery_callback, 10)
        self.create_subscription(LaserScan, '/scan', self.laser_callback, 10)
        self.create_subscription(OccupancyGrid, '/map', self.map_callback, 10)
        
        # Send heartbeat every 30 seconds
        self.create_timer(30.0, self.send_heartbeat)
        
        self.get_logger().info(f'AMR Bridge started - connecting to {self.backend_url}')

    def connect_websocket(self):
        try:
            self.ws = websocket.WebSocket()
            self.ws.connect(self.ws_url)
            
            # Register device
            registration = {
                "type": "device_connect",
                "deviceId": self.device_id,
                "deviceInfo": {
                    "name": "mirai-x",
                    "type": "differential_drive",
                    "capabilities": ["mapping", "navigation", "remote_control"]
                }
            }
            self.ws.send(json.dumps(registration))
            self.get_logger().info('WebSocket connected and device registered')
            
        except Exception as e:
            self.get_logger().error(f'WebSocket connection failed: {e}')
            self.ws = None

    def pose_callback(self, msg):
        # Send pose data to backend
        pose_data = {
            "type": "odometry_update",
            "deviceId": self.device_id,
            "data": {
                "position": {
                    "x": msg.pose.pose.position.x,
                    "y": msg.pose.pose.position.y,
                    "z": msg.pose.pose.position.z
                },
                "orientation": {
                    "x": msg.pose.pose.orientation.x,
                    "y": msg.pose.pose.orientation.y,
                    "z": msg.pose.pose.orientation.z,
                    "w": msg.pose.pose.orientation.w
                },
                "timestamp": time.time()
            }
        }
        self.send_to_backend(pose_data)

    def battery_callback(self, msg):
        battery_data = {
            "type": "battery_update",
            "deviceId": self.device_id,
            "data": {
                "voltage": msg.voltage,
                "percentage": msg.percentage,
                "current": msg.current,
                "temperature": msg.temperature,
                "timestamp": time.time()
            }
        }
        self.send_to_backend(battery_data)

    def laser_callback(self, msg):
        # Send laser scan data (simplified)
        laser_data = {
            "type": "laser_scan",
            "deviceId": self.device_id,
            "data": {
                "range_min": msg.range_min,
                "range_max": msg.range_max,
                "ranges": msg.ranges[:10],  # Send first 10 ranges to avoid large data
                "timestamp": time.time()
            }
        }
        self.send_to_backend(laser_data)

    def map_callback(self, msg):
        # Send map data (when mapping)
        map_data = {
            "type": "map_update",
            "deviceId": self.device_id,
            "data": {
                "width": msg.info.width,
                "height": msg.info.height,
                "resolution": msg.info.resolution,
                "origin": {
                    "x": msg.info.origin.position.x,
                    "y": msg.info.origin.position.y
                },
                "timestamp": time.time()
            }
        }
        self.send_to_backend(map_data)

    def send_to_backend(self, data):
        if self.ws:
            try:
                self.ws.send(json.dumps(data))
            except:
                self.connect_websocket()  # Reconnect if connection lost

    def send_heartbeat(self):
        heartbeat = {
            "type": "heartbeat",
            "deviceId": self.device_id,
            "timestamp": time.time()
        }
        self.send_to_backend(heartbeat)

def main():
    rclpy.init()
    bridge = AMRBackendBridge()
    rclpy.spin(bridge)
    rclpy.shutdown()

if __name__ == '__main__':
    main()
