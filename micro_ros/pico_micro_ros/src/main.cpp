#include <Arduino.h>
#include <Cytron.h>
#include <micro_ros_platformio.h>
#include <rmw_microros/rmw_microros.h>

#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>

#include <std_msgs/msg/int32.h>
#include <std_msgs/msg/float32_multi_array.h>
#include <std_msgs/msg/bool.h>
#include <geometry_msgs/msg/twist.h>
#include <sensor_msgs/msg/range.h>
#include <rmw_microros/time_sync.h>
#include <builtin_interfaces/msg/time.h>

#if !defined(MICRO_ROS_TRANSPORT_ARDUINO_SERIAL)
#error This example is only avaliable for Arduino framework with serial transport.
#endif

#define LPWM 0
#define LDir 2
#define RPWM 1
#define RDir 3

#define ENCODER_0_PIN_A 18
#define ENCODER_0_PIN_B 19
#define ENCODER_1_PIN_A 20
#define ENCODER_1_PIN_B 21

#define ECHOPIN 7// Pin to receive echo pulse
#define TRIGPIN 8// Pin to send trigger pulse

Cytron leftMotor(LPWM, LDir, LOW);
Cytron rightMotor(RPWM, RDir, LOW);

volatile int32_t encoder_count[2] = {0};
volatile bool last_A0 = 0;
volatile bool last_A1 = 0;

rcl_publisher_t encoder_readings_pub_;
rcl_publisher_t check_pub_;
rcl_publisher_t ultrsonic_sensor_pub_;

rcl_subscription_t wheel_vel_sub_;
rcl_subscription_t pid_values_sub_;

std_msgs__msg__Float32MultiArray encoder_readings_;
std_msgs__msg__Bool check_;
std_msgs__msg__Float32MultiArray wheel_vel_;
std_msgs__msg__Float32MultiArray pid_values_;
sensor_msgs__msg__Range ultrasonic_sensor_;

rclc_executor_t executor;
rclc_support_t support;
rcl_allocator_t allocator;

rcl_node_t mc_node;

rcl_timer_t encoder_readings_timer;
rcl_timer_t check_timer;
rcl_timer_t ultrasonic_readings_timer;

float pid_values[4] = {0};
float pwm_limit = 100; // Max PWM value for motors
float min_pwm = 15; // Minimum PWM value
float v = min_pwm;
float mul = 1; // multiplier
bool l_dir = LOW;  //direction flag for left motor
bool r_dir = LOW;  //direction flag for right motor

float v1 = 0, v2 = 0;

float distance = 0;;

#define RCCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){error_loop();}}
#define RCSOFTCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){}}

// Error handle loop
void error_loop() {
  while(1) {
    delay(100);
  }
}

void enc_read_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    RCSOFTCHECK(rcl_publish(&encoder_readings_pub_, &encoder_readings_, NULL));
  }
}

void check_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    RCSOFTCHECK(rcl_publish(&check_pub_, &check_, NULL));
  }
}

void ultrasonic_readings_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    RCSOFTCHECK(rcl_publish(&ultrsonic_sensor_pub_, &ultrasonic_sensor_, NULL));
  }
}

void wheel_vel_callback(const void * msgin)
{  
  if(msgin == NULL){
    return;
  }
  const std_msgs__msg__Float32MultiArray * msg = (const std_msgs__msg__Float32MultiArray *)msgin;

  if((msg->data.data == NULL) || (msg->data.size < 2)){
    return;
  }

  v1 = msg->data.data[0];
  v2 = msg->data.data[1];
}

void pid_callback(const void * msgin)
{  
  if(msgin == NULL){
    return;
  }

  const std_msgs__msg__Float32MultiArray * msg = (const std_msgs__msg__Float32MultiArray *)msgin;

  if((msg->data.data == NULL) || (msg->data.size < 4)){
    return;
  }

  pid_values[0] = msg->data.data[0];
  pid_values[1] = msg->data.data[1];
  pid_values[2] = msg->data.data[2];
  pid_values[3] = msg->data.data[3];
}

void encoder_callback_0() {
    bool A = digitalRead(ENCODER_0_PIN_A);
    bool B = digitalRead(ENCODER_0_PIN_B);

    if (A != last_A0) {
        if (A == B) {
            encoder_count[0]++;
        } else {
            encoder_count[0]--;
        }
        last_A0 = A;
    }
}

void encoder_callback_1() {
    bool A = digitalRead(ENCODER_1_PIN_A);
    bool B = digitalRead(ENCODER_1_PIN_B);

    if (A != last_A1) {
        if (A == B) {
            encoder_count[1]++;
        } else {
            encoder_count[1]--;
        }
        last_A1 = A;
    }
}

void ultrasonic_sensor_data() {

  digitalWrite(TRIGPIN, LOW); // Set the trigger pin to low for 2uS
  delayMicroseconds(2);
  digitalWrite(TRIGPIN, HIGH); // Send a 10uS high to trigger ranging
  delayMicroseconds(20);
  digitalWrite(TRIGPIN, LOW); // Send pin low again
  distance = pulseIn(ECHOPIN, HIGH)/58; // Read in times pulse

  // Simulated ultrasonic sensor data
  builtin_interfaces__msg__Time now;
  uint64_t time_ms = rmw_uros_epoch_millis();
  now.sec = time_ms / 1000;
  now.nanosec = (time_ms % 1000) * 1000000;
  ultrasonic_sensor_.header.stamp = now;
  ultrasonic_sensor_.radiation_type = sensor_msgs__msg__Range__ULTRASOUND;
  ultrasonic_sensor_.field_of_view = 2.1; // Example field of view in radians
  ultrasonic_sensor_.min_range = 0.25; // Minimum range in meters
  ultrasonic_sensor_.max_range = 4.0; // Maximum range in meters
  ultrasonic_sensor_.range = distance; // Example range value in meters
}

void encoderReadings(){
  encoder_readings_.data.data[0] = encoder_count[0];
  encoder_readings_.data.data[1] = encoder_count[1];
}

void moveMotors(){

  float temp_v1 = abs(v1);
  float temp_v2 = abs(v2);
  
  if(temp_v1 < temp_v2){
    if(temp_v1 < min_pwm)
      v = temp_v1;
    else
      v = min_pwm;
  }
  else if(temp_v2 < temp_v1){
    if(temp_v2 < min_pwm)
      v = temp_v2;
    else
      v = min_pwm;
  }

  temp_v1 = abs(temp_v1) + (min_pwm - v);
  temp_v2 = abs(temp_v2) + (min_pwm - v);

  if(v1 < 0)
    v1 = -temp_v1;
  else
    v1 = temp_v1;

  if(v2 < 0)
    v2 = -temp_v2;
  else
    v2 = temp_v2;

  // constrain(v1, -pwm_limit, pwm_limit);
  // constrain(v2, -pwm_limit, pwm_limit);

  if(v1 > pwm_limit){
    v1 = 100;
  }
  else if(v1 < -pwm_limit){
    v1 = -100;
  }
  if(v2 > pwm_limit){
    v2 = 100;
  }
  else if(v2 < -pwm_limit){
    v2 = -100;
  }

  leftMotor.rotate(v1);
  rightMotor.rotate(v2);

}

void setup() {
  // Configure serial transport
  Serial.begin(115200);
  set_microros_serial_transports(Serial);
  delay(2000);

  pinMode(ENCODER_0_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_0_PIN_B, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_B, INPUT_PULLUP);

  pinMode(ECHOPIN, INPUT);
  pinMode(TRIGPIN, OUTPUT);

  attachInterrupt(digitalPinToInterrupt(ENCODER_0_PIN_A), encoder_callback_0, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_1_PIN_A), encoder_callback_1, CHANGE);

  // Wait for agent successful ping for 5 minutes.
  const int timeout_ms = 1000; 
  const uint8_t attempts = 255;

  rcl_ret_t ret = rmw_uros_ping_agent(timeout_ms, attempts);

  if (ret != RCL_RET_OK)
  {
      // Unreachable agent, exiting program.
      while(1);
  }

  rmw_uros_sync_session(10);  // syncs every 10 seconds

  allocator = rcl_get_default_allocator();

  //create init_options
  RCCHECK(rclc_support_init(&support, 0, NULL, &allocator));

  // create node
  RCCHECK(rclc_node_init_default(&mc_node, "micro_ros_node", "", &support));

  // create publisher
  RCCHECK(rclc_publisher_init_default(
    &encoder_readings_pub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
    "wheel_encoders"));

  // create publisher
  RCCHECK(rclc_publisher_init_default(
    &check_pub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Bool),
    "communication_check"));
      
  // create subscriber
  RCCHECK(rclc_subscription_init_default(
    &wheel_vel_sub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
    "cmd_vel"));
      
  // create subscriber
  RCCHECK(rclc_subscription_init_default(
    &pid_values_sub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
    "set_pid"));

  // create timer,
  const unsigned int timer_timeout = 10;
  RCCHECK(rclc_timer_init_default(
    &encoder_readings_timer,
    &support,
    RCL_MS_TO_NS(timer_timeout),
    enc_read_callback));

  // create timer,
  const unsigned int timer_timeout1 = 1000;
  RCCHECK(rclc_timer_init_default(
    &check_timer,
    &support,
    RCL_MS_TO_NS(timer_timeout1),
    check_callback));

  // create timer,
  const unsigned int ultrasonic_timer_timeout = 10;
  RCCHECK(rclc_timer_init_default(
    &ultrasonic_readings_timer,
    &support,
    RCL_MS_TO_NS(ultrasonic_timer_timeout),
    ultrasonic_readings_callback));

  // create executor
  RCCHECK(rclc_executor_init(&executor, &support.context, 4, &allocator));
  RCCHECK(rclc_executor_add_timer(&executor, &encoder_readings_timer));
  RCCHECK(rclc_executor_add_timer(&executor, &check_timer));
  RCCHECK(rclc_executor_add_timer(&executor, &ultrasonic_readings_timer));
  
  RCCHECK(rclc_executor_add_subscription(&executor, &wheel_vel_sub_, &wheel_vel_, &wheel_vel_callback, ON_NEW_DATA));
  RCCHECK(rclc_executor_add_subscription(&executor, &pid_values_sub_, &pid_values_, &pid_callback, ON_NEW_DATA));

  // encoder_readings_ = { .data = { .data = NULL, .size = 0, .capacity = 0}};
  encoder_readings_.data.size = 2;
  encoder_readings_.data.capacity = 2;
  encoder_readings_.data.data = (float*) malloc(2 * sizeof(float));

  encoder_readings_.data.data[0] = 0;
  encoder_readings_.data.data[1] = 0;

  check_.data = true;
  
  wheel_vel_.data.size = 2;
  wheel_vel_.data.capacity = 2;
  wheel_vel_.data.data = (float*) malloc(2 * sizeof(float));

  wheel_vel_.data.data[0] = 0;
  wheel_vel_.data.data[1] = 0;

  pid_values_.data.size = 4;
  pid_values_.data.capacity = 4;
  pid_values_.data.data = (float*) malloc(4 * sizeof(float));

  pid_values_.data.data[0] = 0;
  pid_values_.data.data[1] = 0;
  pid_values_.data.data[2] = 0;
  pid_values_.data.data[3] = 0;

}

void loop() {
  // delay(100);
  encoderReadings();
  ultrasonic_sensor_data();
  moveMotors();
  RCSOFTCHECK(rclc_executor_spin_some(&executor, RCL_MS_TO_NS(1)));
}