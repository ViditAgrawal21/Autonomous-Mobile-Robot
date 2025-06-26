#include <Arduino.h>
#include <Cytron.h>
#include <pid.h>

#define LPWM 0
#define LDir 2
#define RPWM 1
#define RDir 3

Cytron leftMotor(LPWM, LDir, LOW);
Cytron rightMotor(RPWM, RDir, LOW);

float pwm_limit = 100.0 ; // Max PWM value for motors
float min_pwm = 15.0 ; // Minimum PWM value   0.759
float v = min_pwm;

float v1 = 10, v2 = 10;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  
}

void loop() {

  float temp_v1 = abs(v1);
  float temp_v2 = abs(v2);
  
  if(temp_v1 <= temp_v2){
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

  Serial.print(temp_v1);
  Serial.print(" ");
  Serial.print(min_pwm);
  Serial.print(" ");
  Serial.println(v);

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
