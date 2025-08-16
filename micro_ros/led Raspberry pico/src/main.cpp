#include <Arduino.h>

#define LED_RED 6
#define LED_GREEN 7
#define LED_BLUE 8

int led_pwms[3] = {0};
int max_pwm_value = 100; // Maximum PWM value for the LEDs

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

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);
  
  for(int i = 0; i < 3; i++) {
    led_pwms[i] = 0;
  }

  led_pwms[0] = 127; // Start with red LED at full brightness
  led_pwms[1] = 0;   // Green LED off
  led_pwms[2] = 0;   // Blue LED off
  ledControl(led_pwms);
  delay(1000); // Wait for a second before starting the loop

}

void loop() {
  // put your main code here, to run repeatedly:
  led_pwms[0] = 0;   // Turn off red LED
  led_pwms[1] = 100; // Turn on green LED
  led_pwms[2] = 0;   // Blue LED off
  ledControl(led_pwms);
  delay(1000);
  led_pwms[0] = 0;   // Red LED off
  led_pwms[1] = 0;   // Green LED off
  led_pwms[2] = 100; // Turn on blue LED
  ledControl(led_pwms);
  delay(1000);
  led_pwms[0] = 100; // Turn on red LED again
  led_pwms[1] = 0;   // Green LED off
  led_pwms[2] = 0;   // Blue LED off
  ledControl(led_pwms);
  delay(1000);
}
