#include <Arduino.h>

// put function declarations here:
int myFunction(int, int);

void setup() {
  // put your setup code here, to run once:
  pinMode(25, OUTPUT);
  delay(5000);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(25, HIGH); // Turn on the LED
}
