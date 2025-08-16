# #!/usr/bin/env python3
# import rclpy
# from rclpy.node import Node
# from gpiozero import Button
# import subprocess
# import time
# import os

# button = Button(15, pull_up=True, bounce_time=0.1)

# running = False  # Tracks if the process is running

# def toggle_scripts():
#     global running

#     if not running:
#         print("Button pressed. Starting process...")
#         subprocess.Popen(['/home/piros/scripts/ptp.sh'], preexec_fn=os.setsid)
#         running = True
#     else:
#         print("Button pressed. Stopping process...")
#         subprocess.Popen(['/home/piros/scripts/kill_ptp.sh'], preexec_fn=os.setsid)
#         running = False

# print("Press button to start/stop process...")
# button.when_pressed = toggle_scripts

# while True:
#     time.sleep(1)

#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from gpiozero import Button
import subprocess
import os


class ButtonToggleNode(Node):
    def __init__(self):
        super().__init__('button_toggle_node')

        # Set up button
        self.button = Button(15, pull_up=True, bounce_time=0.1)
        self.running = False

        # Register event
        self.button.when_pressed = self.toggle_scripts

        self.get_logger().info("Press button to start/stop process...")

    def toggle_scripts(self):
        if not self.running:
            self.get_logger().info("Button pressed. Starting process...")
            subprocess.Popen(['/home/piros/scripts/ptp.sh'], preexec_fn=os.setsid)
            self.running = True
        else:
            self.get_logger().info("Button pressed. Stopping process...")
            subprocess.Popen(['/home/piros/scripts/kill_ptp.sh'], preexec_fn=os.setsid)
            self.running = False


def main(args=None):
    rclpy.init(args=args)
    node = ButtonToggleNode()
    try:
        rclpy.spin(node)  # Keeps node alive and responsive
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
