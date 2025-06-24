#include <Arduino.h>
#include <Cytron.h>
#include <pid.h>

PidController wheel;
Cytron motor(0, 2, LOW);

#define ENCODER_0_PIN_A 18
#define ENCODER_0_PIN_B 19
#define ENCODER_1_PIN_A 20
#define ENCODER_1_PIN_B 21

volatile bool last_A0 = 0;
volatile bool last_A1 = 0;

float value = 20.0; // Variable to hold the motor value
float time_diff = 0;
unsigned long prevTime = 0;
int encoder_count[2] = {0, 0}; // left(0), right(1) - encoder counts
float encoder_resolution[2] = {2329, 2376}; // left(0), right(1) - encoder resolution
float diff[2] = {0, 0};
float diff_rad[2] = {0.0, 0.0};
int prev_count[2] = {0, 0};
float angular_vel[2] = {0.0, 0.0}; // left(0), right(1) - angular velocities
float pwm = 0;
int current_value = 0; // Current value from the encoder or sensor
long prev_time = 0; // Previous time for velocity calculation

void calculateWheelVelocities(){
  time_diff = (micros() - prevTime) / 1000000.0; // Convert milliseconds to seconds
  prevTime = micros();

  diff[0] = encoder_count[0] - prev_count[0];
  prev_count[0] = encoder_count[0];
  diff_rad[0] = (diff[0] / encoder_resolution[0]) * 2 * PI;
  angular_vel[0] = (diff_rad[0] / time_diff) *  9.549297; // left wheel

  diff[1] = encoder_count[1] - prev_count[1];
  prev_count[1] = encoder_count[1];
  diff_rad[1] = (diff[1] / encoder_resolution[1]) * 2 * PI;
  angular_vel[1] = (diff_rad[1] / time_diff) *  9.549297; // left wheel

  Serial.print(time_diff);
  Serial.print("  ");
  Serial.print(encoder_count[0]);
  Serial.print("  ");
  Serial.println(prev_count[0]);
  // Serial.print("  ");
  // Serial.print(diff[0]);
  // Serial.print("  ");
  // Serial.print(diff_rad[0]);
  // Serial.print("  ");
  // Serial.println(angular_vel[0]);
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

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  wheel.setParameters(0.3, 0.005, 0, -500, 500, -60, 60);

  pinMode(ENCODER_0_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_0_PIN_B, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_A, INPUT_PULLUP);
  pinMode(ENCODER_1_PIN_B, INPUT_PULLUP);

  attachInterrupt(digitalPinToInterrupt(ENCODER_0_PIN_A), encoder_callback_0, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_1_PIN_A), encoder_callback_1, CHANGE);
}

void loop() {
  // put your main code here, to run repeatedly:
  // if(Serial.available()) {
    // String input = Serial.readStringUntil('\n');
    // if(input.startsWith("set ")) {
    //   int value = input.substring(4).toInt();
    //   motor.rotate(value);
    //   Serial.println("Motor set to: " + String(value));
    // } else if(input == "test") {
    //   motor.test(255, 1000);
    // } else {
    //   Serial.println("Unknown command");
    // }
  // }

  if (Serial.available()) {
    value = Serial.parseInt();
  }
  if(micros() - prev_time > 100) {
    calculateWheelVelocities();
    prev_time = micros();
  }
  // calculateWheelVelocities();
  pwm = 0.5 * pwm + wheel.calculateCorrection(value, angular_vel[0], micros());
  if(pwm > 50)
    pwm = 50;
  else if(pwm < -50)
    pwm = -50;
  motor.rotate(pwm);
  // Serial.print(pwm);
  // Serial.print("  ");
  // Serial.print(encoder_count[0]);
  // Serial.print("      ");
  // Serial.println(angular_vel[0]);
}
