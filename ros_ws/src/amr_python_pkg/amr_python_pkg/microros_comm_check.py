#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from std_msgs.msg import Bool
from gpiozero import LED
import time

class MicrorosCommunicationCheck(Node):
    def __init__(self):
        super().__init__('microros_communication_check')

        # Parameters
        self.timeout_sec = 4.0  # Timeout for missing messages
        self.gpio_pin = 18      # GPIO pin number (BCM numbering)
        self.trigger = LED(self.gpio_pin)

        # Subscriber
        self.subscription = self.create_subscription(
            Bool,
            'communication_check',  # Replace with your actual topic name
            self.heartbeat_callback,
            10
        )

        self.get_logger().info("Microros Communication Check Node started.")

        self.last_msg_time = self.get_clock().now()

        # Timer to check timeout every second
        self.timer = self.create_timer(1.0, self.check_connection)

    def heartbeat_callback(self, msg):
        if msg.data:  # Expecting True
            self.last_msg_time = self.get_clock().now()

    def check_connection(self):
        elapsed_time = (self.get_clock().now() - self.last_msg_time).nanoseconds / 1e9

        if elapsed_time > self.timeout_sec:
            self.get_logger().warn(f'No heartbeat for {elapsed_time:.2f} seconds. Triggering GPIO.')
            self.trigger.on()
            time.sleep(1)
            self.trigger.off()
            # After triggering, reset timer to wait for new messages
            self.last_msg_time = self.get_clock().now()


def main(args=None):
    rclpy.init(args=args)
    node = MicrorosCommunicationCheck()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
