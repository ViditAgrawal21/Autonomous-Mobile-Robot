#include <Arduino.h>
#include <Cytron.h>
#include <micro_ros_platformio.h>
#include <rmw_microros/rmw_microros.h>

#include <rcl/rcl.h>
#include <rcl/time.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>

#include <std_msgs/msg/int32.h>
#include <std_msgs/msg/float32.h>
#include <std_msgs/msg/float32_multi_array.h>
#include <std_msgs/msg/bool.h>
#include <geometry_msgs/msg/twist.h>
#include <sensor_msgs/msg/range.h>
#include "rosidl_runtime_c/string_functions.h"

#if !defined(MICRO_ROS_TRANSPORT_ARDUINO_SERIAL)
#error This example is only avaliable for Arduino framework with serial transport.
#endif

#define LPWM 0
#define LDir 2
#define RPWM 1
#define RDir 3

#define ENCODER_0_PIN_A 21
#define ENCODER_0_PIN_B 20
#define ENCODER_1_PIN_A 18
#define ENCODER_1_PIN_B 19

// #define ECHOPIN 9// Pin to receive echo pulse
// #define TRIGPIN 10// Pin to send trigger pulse

#define BATTERYPIN 26

#define NUM_OF_READINGS 10 // Number of readings for battery voltage averaging
int indexx = 0; // Index for the current battery reading
float total = 0; // Total of the battery readings
float voltage_readings[NUM_OF_READINGS] = {0}; // Array to store battery

#define LED_RED 6
#define LED_GREEN 7
#define LED_BLUE 8

int led_pwms[3] = {0};
int max_pwm_value = 100; // Maximum PWM value for the LEDs

Cytron leftMotor(LPWM, LDir, LOW);
Cytron rightMotor(RPWM, RDir, LOW);

volatile int32_t encoder_count[2] = {0};
volatile bool last_A0 = 0;
volatile bool last_A1 = 0;

rcl_publisher_t encoder_readings_pub_;
// rcl_publisher_t ultrasonic_sensor_pub_;
rcl_publisher_t battery_status_pub_;
rcl_publisher_t communication_check_pub_;

rcl_subscription_t wheel_vel_sub_;
// rcl_subscription_t pid_values_sub_;
rcl_subscription_t check_sub_;
rcl_subscription_t led_colour_sub_;

std_msgs__msg__Float32MultiArray encoder_readings_;
std_msgs__msg__Bool comm_check_;
std_msgs__msg__Float32MultiArray wheel_vel_;
// std_msgs__msg__Float32MultiArray pid_values_;
// std_msgs__msg__Float32MultiArray ultrasonic_sensor_;
std_msgs__msg__Float32MultiArray battery_status_;
std_msgs__msg__Int32 led_colour_;

rclc_executor_t executor;
rclc_support_t support;
rcl_allocator_t allocator;

rcl_node_t mc_node;

rcl_timer_t encoder_readings_timer;
// rcl_timer_t ultrasonic_readings_timer;
rcl_timer_t battery_status_timer;
rcl_timer_t communication_check_timer;

// float pid_values[4] = {0};
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
void ledControl(int led_pwms[3]) {
  for(int i = 0; i < 3; i++) {
    if(led_pwms[i] < 0) {
      led_pwms[i] = 0; // Ensure PWM values are not negative
    } else if(led_pwms[i] > max_pwm_value) {
      led_pwms[i] = max_pwm_value; // Ensure PWM values do not exceed 255
    }
  }
  // Set the PWM values for the LEDs
  digitalWrite(LED_RED, led_pwms[0]);
  digitalWrite(LED_GREEN, led_pwms[1]);
  digitalWrite(LED_BLUE, led_pwms[2]);
}

void enc_read_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    RCSOFTCHECK(rcl_publish(&encoder_readings_pub_, &encoder_readings_, NULL));
  }
}

// void ultrasonic_readings_callback(rcl_timer_t * timer, int64_t last_call_time) {
//   RCLC_UNUSED(last_call_time);
//   if (timer != NULL) {
//     RCSOFTCHECK(rcl_publish(&ultrasonic_sensor_pub_, &ultrasonic_sensor_, NULL));
//   }
// }

void battery_status_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    // Simulate battery status reading
    float read = analogRead(BATTERYPIN); // Read from A0 pin
    float battery_voltage = (25.0/1008.0) * read;
    float battery_percetage = (100.0/3.0) * (battery_voltage - 22.0); // Calculate percentage

    total = total - voltage_readings[indexx] + battery_voltage; // Subtract the oldest reading

    voltage_readings[indexx] = battery_voltage; // Store the reading
    indexx = (indexx + 1) % NUM_OF_READINGS; // Update index for

    float avg_battery_voltage = total / NUM_OF_READINGS;

    if (battery_percetage < 0) {
      battery_percetage = 0; // Ensure percentage is not negative
    } else if (battery_percetage > 100) {
      battery_percetage = 100; // Ensure percentage does not exceed 100
    }
    battery_status_.data.data[0] = battery_percetage; // Set battery percentage
    battery_status_.data.data[1] = avg_battery_voltage; // Set battery voltage
    RCSOFTCHECK(rcl_publish(&battery_status_pub_, &battery_status_, NULL));
  }
}

void communication_check_callback(rcl_timer_t * timer, int64_t last_call_time) {
  RCLC_UNUSED(last_call_time);
  if (timer != NULL) {
    RCSOFTCHECK(rcl_publish(&communication_check_pub_, &comm_check_, NULL));
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

void led_colour_callback(const void * msgin)
{  
  if(msgin == NULL){
    return;
  }
  const std_msgs__msg__Int32 * msg = (const std_msgs__msg__Int32 *)msgin;

  if(msg->data < 0 || msg->data > 3){
    return; // Invalid colour value
  }

  if(msg->data == 0) {
    led_pwms[0] = max_pwm_value; // Red
    led_pwms[1] = 0; // Green
    led_pwms[2] = 0; // Blue
  } else if(msg->data == 1) {
    led_pwms[0] = 0; // Red
    led_pwms[1] = max_pwm_value; // Green
    led_pwms[2] = 0; // Blue
  } else if(msg->data == 2) {
    led_pwms[0] = 0; // Red
    led_pwms[1] = 0; // Green
    led_pwms[2] = max_pwm_value; // Blue
  } else if(msg->data == 3) {
    led_pwms[0] = max_pwm_value; // Red
    led_pwms[1] = max_pwm_value; // Green
    led_pwms[2] = 0; // Blue
  }
  
  ledControl(led_pwms);
}

// void pid_callback(const void * msgin)
// {  
//   if(msgin == NULL){
//     return;
//   }

//   const std_msgs__msg__Float32MultiArray * msg = (const std_msgs__msg__Float32MultiArray *)msgin;

//   if((msg->data.data == NULL) || (msg->data.size < 4)){
//     return;
//   }

//   pid_values[0] = msg->data.data[0];
//   pid_values[1] = msg->data.data[1];
//   pid_values[2] = msg->data.data[2];
//   pid_values[3] = msg->data.data[3];
// }

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

// void ultrasonic_sensor_data() {

//   digitalWrite(TRIGPIN, LOW); // Set the trigger pin to low for 2uS
//   delayMicroseconds(2);
//   digitalWrite(TRIGPIN, HIGH); // Send a 10uS high to trigger ranging
//   delayMicroseconds(20);
//   digitalWrite(TRIGPIN, LOW); // Send pin low again
//   distance = pulseIn(ECHOPIN, HIGH)/58; // Read in times pulse

//   ultrasonic_sensor_.data.data[0] = distance / 100.0;
//   delay(50); // Wait for 50ms before next reading
// }

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
  else if(v1 > 0)
    v1 = temp_v1;
  else
    v1 = 0;

  if(v2 < 0)
    v2 = -temp_v2;
  else if(v2 > 0)
    v2 = temp_v2;
  else
    v2 = 0;

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

  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);
  
  for(int i = 0; i < 3; i++) {
    led_pwms[i] = 0;
  }

  led_pwms[0] = 100; // Start with red LED at full brightness
  led_pwms[1] = 0;   // Green LED off
  led_pwms[2] = 0;   // Blue LED off
  ledControl(led_pwms);

  // Configure serial transport  
  Serial.begin(115200);
  set_microros_serial_transports(Serial);
  delay(2000);

  pinMode(ENCODER_0_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_0_PIN_B, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_B, INPUT_PULLUP);

  // pinMode(ECHOPIN, INPUT);
  // pinMode(TRIGPIN, OUTPUT);

  pinMode(BATTERYPIN, INPUT);

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

  allocator = rcl_get_default_allocator();

  //create init_options
  RCCHECK(rclc_support_init(&support, 0, NULL, &allocator));

  // create nodes
  RCCHECK(rclc_node_init_default(&mc_node, "micro_ros_node", "", &support));
  // RCCHECK(rclc_node_init_default(&battery_node, "battery_node", "", &support));

  // create publisher
  RCCHECK(rclc_publisher_init_default(
    &encoder_readings_pub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
    "wheel_encoders"));
  
  // // create publisher
  // RCCHECK(rclc_publisher_init_default(
  //   &ultrasonic_sensor_pub_,
  //   &mc_node,
  //   ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
  //   "ultrasonic_sensor"));

  // create publisher
  RCCHECK(rclc_publisher_init_default(
    &battery_status_pub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
    "battery_status"));

  // create publisher
  RCCHECK(rclc_publisher_init_default(
    &communication_check_pub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Bool),
    "communication_check"));

  // create subscriber
  RCCHECK(rclc_subscription_init_default(
    &wheel_vel_sub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
    "wheel_velocity"));
      
  // // create subscriber
  // RCCHECK(rclc_subscription_init_default(
  //   &pid_values_sub_,
  //   &mc_node,
  //   ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32MultiArray),
  //   "set_pid"));

  // create subscriber
  RCCHECK(rclc_subscription_init_default(
    &led_colour_sub_,
    &mc_node,
    ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Int32),
    "led_colour"));

  // create timer,
  const unsigned int timer_timeout = 10;
  RCCHECK(rclc_timer_init_default(
    &encoder_readings_timer,
    &support,
    RCL_MS_TO_NS(timer_timeout),
    enc_read_callback));

  // // create timer,
  // const unsigned int ultrasonic_timer_timeout = 100;
  // RCCHECK(rclc_timer_init_default(
  //   &ultrasonic_readings_timer,
  //   &support,
  //   RCL_MS_TO_NS(ultrasonic_timer_timeout),
  //   ultrasonic_readings_callback));

  // create timer,
  const unsigned int battery_status_timer_timeout = 2000;
  RCCHECK(rclc_timer_init_default(
    &battery_status_timer,
    &support,
    RCL_MS_TO_NS(battery_status_timer_timeout),
    battery_status_callback));

  // create timer,
  const unsigned int communication_check_timer_timeout = 1000;
  RCCHECK(rclc_timer_init_default(
    &communication_check_timer,
    &support,
    RCL_MS_TO_NS(communication_check_timer_timeout),
    communication_check_callback));

  // create executor
  RCCHECK(rclc_executor_init(&executor, &support.context, 5, &allocator));

  RCCHECK(rclc_executor_add_timer(&executor, &encoder_readings_timer));
  // RCCHECK(rclc_executor_add_timer(&executor, &ultrasonic_readings_timer));
  RCCHECK(rclc_executor_add_timer(&executor, &battery_status_timer));
  RCCHECK(rclc_executor_add_timer(&executor, &communication_check_timer));
  
  RCCHECK(rclc_executor_add_subscription(&executor, &wheel_vel_sub_, &wheel_vel_, &wheel_vel_callback, ON_NEW_DATA));
  // RCCHECK(rclc_executor_add_subscription(&executor, &pid_values_sub_, &pid_values_, &pid_callback, ON_NEW_DATA));
  RCCHECK(rclc_executor_add_subscription(&executor, &led_colour_sub_, &led_colour_, &led_colour_callback, ON_NEW_DATA));

  encoder_readings_.data.size = 2;
  encoder_readings_.data.capacity = 2;
  encoder_readings_.data.data = (float*) malloc(2 * sizeof(float));

  encoder_readings_.data.data[0] = 0;
  encoder_readings_.data.data[1] = 0;

  comm_check_.data = true;

  // ultrasonic_sensor_.data.size = 1;
  // ultrasonic_sensor_.data.capacity = 1;
  // ultrasonic_sensor_.data.data = (float*) malloc(1 * sizeof(float));

  encoder_readings_.data.data[0] = 0;
  
  wheel_vel_.data.size = 2;
  wheel_vel_.data.capacity = 2;
  wheel_vel_.data.data = (float*) malloc(2 * sizeof(float));

  wheel_vel_.data.data[0] = 0;
  wheel_vel_.data.data[1] = 0;

  // pid_values_.data.size = 4;
  // pid_values_.data.capacity = 4;
  // pid_values_.data.data = (float*) malloc(4 * sizeof(float));

  // pid_values_.data.data[0] = 0;
  // pid_values_.data.data[1] = 0;
  // pid_values_.data.data[2] = 0;
  // pid_values_.data.data[3] = 0;

  battery_status_.data.size = 2;
  battery_status_.data.capacity = 2;
  battery_status_.data.data = (float*) malloc(2 * sizeof(float));
  battery_status_.data.data[0] = 0;   // Battery percentage
  battery_status_.data.data[1] = 0;   // Battery voltage

  led_colour_.data = 0;

}

void loop() {
  // delay(100);
  encoderReadings();
  // ultrasonic_sensor_data();
  moveMotors();
  RCSOFTCHECK(rclc_executor_spin_some(&executor, RCL_MS_TO_NS(1)));
}