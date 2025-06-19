import rclpy
from rclpy.node import Node
from sensor_msgs.msg import LaserScan

class ScanRepublisher(Node):
    def __init__(self):
        super().__init__('remap_scan_node')
        self.subscription = self.create_subscription(
            LaserScan,
            '/scan',                # 🔁 Input topic
            self.scan_callback,
            10)
        self.publisher = self.create_publisher(
            LaserScan,
            '/custom_scan',         # ✅ Output topic
            10)
        self.get_logger().info("Republishing /scan → /custom_scan")

    def scan_callback(self, msg):
        self.publisher.publish(msg)

def main(args=None):
    rclpy.init(args=args)
    node = ScanRepublisher()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
