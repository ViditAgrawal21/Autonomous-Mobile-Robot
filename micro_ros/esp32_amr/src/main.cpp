#include <Arduino.h>
#include <micro_ros_platformio.h>

#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>

// #include <std_msgs/msg/int32.h>
// #include <geometry_msgs/msg/vector3.h>
#include <geometry_msgs/msg/twist_stamped.h>


#if !defined(MICRO_ROS_TRANSPORT_ARDUINO_WIFI)
#error This example is only avaliable for Arduino framework with serial transport.
#endif

rcl_publisher_t publisher;
geometry_msgs__msg__TwistStamped msg;

rclc_executor_t executor;
rclc_support_t support;
rcl_allocator_t allocator;
rcl_node_t node;
rcl_timer_t timer;

#define RCCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){error_loop();}}
#define RCSOFTCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){}}

// Error handle loop
void error_loop() {
  while(1) {
    delay(100);
  }
}

void timer_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    int rawx = analogRead(34);
    int rawy = analogRead(35);

    float center = 2048.0;              // 12-bit ADC midpoint
    float threshold = 400.0;            // Deadzone threshold

    msg.twist.linear.x = (rawy - center)/ center;
    //msg.linear.y = (rawy - 2048)/ 2048.0;
    msg.twist.angular.z = (rawx - center)/ center;
    //msg.angular.y = (rawy - 2048)/ 2048.0;

    // Apply deadzone
    if (abs(msg.twist.linear.x ) < (threshold / center)) {
      msg.twist.linear.x  = 0.0;
    }
    if (abs(msg.twist.angular.z) < (threshold / center)) {
      msg.twist.angular.z = 0.0;
    }


    // msg.twist.linear.x = (rawy - 2048)/ 2048.0;
    // //msg.linear.y = (rawy - 2048)/ 2048.0;
    // msg.twist.angular.z = (rawx - 2048)/ 2048.0;
    // //msg.angular.y = (rawy - 2048)/ 2048.0;
    RCSOFTCHECK(rcl_publish(&publisher, &msg, NULL));
    // //msg.x++;
  }
}

void setup() {
  // Configure serial transport
  IPAddress agent_ip(192, 168, 1, 113);
  size_t agent_port = 8888;

  char ssid[] = "XPS-15-9520";
  char psk[]= "xps159520";

  set_microros_wifi_transports(ssid, psk, agent_ip, agent_port);
  delay(2000);

  allocator = rcl_get_default_allocator();

  //create init_options
  RCCHECK(rclc_support_init(&support, 0, NULL, &allocator));

  // create node
  RCCHECK(rclc_node_init_default(&node, "micro_ros_platformio_node", "", &support));

  // create publisher
  RCCHECK(rclc_publisher_init_default(
    &publisher,
    &node,
    //ROSIDL_GET_MSG_TYPE_SUPPORT(geometry_msgs, msg, geometry_msgs__msg__TwistStamped),
    ROSIDL_GET_MSG_TYPE_SUPPORT(geometry_msgs, msg, TwistStamped),
    "diff_drive_controller/cmd_vel"));

  // create timer,
  const unsigned int timer_timeout = 5;
  RCCHECK(rclc_timer_init_default(
    &timer,
    &support,
    RCL_MS_TO_NS(timer_timeout),
    timer_callback));

  // create executor
  RCCHECK(rclc_executor_init(&executor, &support.context, 1, &allocator));
  RCCHECK(rclc_executor_add_timer(&executor, &timer));

  msg.twist.linear.x = 0;
  msg.twist.linear.y = 0;
  msg.twist.linear.z = 0;

  msg.twist.angular.x = 0;
  msg.twist.angular.y = 0;
  msg.twist.angular.z = 0;
}

void loop() {
  delay(100);
  RCSOFTCHECK(rclc_executor_spin_some(&executor, RCL_MS_TO_NS(1)));
}