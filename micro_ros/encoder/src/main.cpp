#include <Arduino.h>


#define ENCODER_0_PIN_A 18
#define ENCODER_0_PIN_B 19
#define ENCODER_1_PIN_A 20
#define ENCODER_1_PIN_B 21

volatile int32_t encoder_count[2] = {0};
volatile bool last_A0 = 0;
volatile bool last_A1 = 0;


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


void setup() {
  // Configure serial transport
  Serial.begin(9600);
  delay(2000);

  pinMode(ENCODER_0_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_0_PIN_B, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_B, INPUT_PULLUP);

  attachInterrupt(digitalPinToInterrupt(ENCODER_0_PIN_A), encoder_callback_0, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_1_PIN_A), encoder_callback_1, CHANGE);

}

void loop() {
  // delay(100);
  encoder_callback_0();
  encoder_callback_1();
  // Serial.println("Encoder readings:");
  Serial.print("Encoder 0 Count: " + String(encoder_count[0]));
  // Serial.println("      Encoder 1 Count: " + String(encoder_count[1]));
  delay(100); // Adjust the delay as needed
}