#include <Arduino.h>

void setup() {
  // put your setup code here, to run once:
  pinMode(26, INPUT); // Set pin 26 as an output
}

void loop() {
  // put your main code here, to run repeatedly:
    float read = analogRead(26); // Read from A0 pin

    float battery_voltage = (25.0/1008.0) * read;
    float battery_percetage = (100.0/3.0) * (battery_voltage - 22.0); // Calculate percentage

    // float battery_voltage = map(read, 0, 1023, 0, 25); // Map to voltage
    // float battery_percetage = map(battery_voltage, 22.2, 25, 0, 100); // Map to percentage
    Serial.print(read);
    Serial.print("  ");
    Serial.print(battery_voltage);
    Serial.print("  ");
    Serial.println(battery_percetage);
  delay(1000); // Wait for a second
}
