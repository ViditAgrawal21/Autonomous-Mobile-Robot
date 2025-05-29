module.exports = {
  ROSBRIDGE_IP: 'localhost', // Change to your ROS bridge IP
  FLUTTER_PORT: 8080,
  ROS_TOPICS: {
    POSE: '/amcl_pose',
    MAP: '/map',
    CMD_VEL: '/cmd_vel',
    BATTERY: '/battery_status'
  }
};