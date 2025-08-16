#include <Arduino.h>
#include <Cytron.h>

#define LPWM 0
#define LDir 2
#define RPWM 1
#define RDir 3

int pwm = 0; // Initialize PWM value

Cytron leftMotor(LPWM, LDir, LOW);
Cytron rightMotor(RPWM, RDir, LOW);

void setup() {
  // put your setup code here, to run once:
  pinMode(0, OUTPUT);
  pinMode(1, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()) {
    pwm = Serial.parseInt();
    if (pwm < 0) {
      pwm = 0; // Ensure PWM is not negative
    } else if (pwm > 150) {
      pwm = 255; // Ensure PWM does not exceed maximum value
    }
    
    Serial.print("Setting PWM to: ");
    Serial.println(pwm);
    
    leftMotor.rotate(pwm);
    // rightMotor.rotate(pwm);
  }

  // leftMotor.rotate(45);
  // rightMotor.rotate(pwm);
}