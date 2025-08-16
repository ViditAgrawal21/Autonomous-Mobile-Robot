#include "pid.h"

PidController::PidController()
    : set_point(0), current_point(0), kp(1), ki(0.0001), kd(10),
      max_correction(50), min_correction(10),
      min_i_clamp(-100), max_i_clamp(100),
      error(0), correction(0), old_time(0) {}

void PidController::setParameters(float kp, float ki, float kd, 
                                 float min_i_clamp, float max_i_clamp,
                                 float min_correction, float max_correction) {
    this->kp = kp;
    this->ki = ki;
    this->kd = kd;
    this->min_i_clamp = min_i_clamp;
    this->max_i_clamp = max_i_clamp;
    this->min_correction = min_correction;
    this->max_correction = max_correction;
}

void PidController::setPidValues(float kp, float ki, float kd) {
    this->kp = kp;
    this->ki = ki;
    this->kd = kd;
}

void PidController::integralLimits(float min_i_clamp, float max_i_clamp) {
    this->min_i_clamp = min_i_clamp;
    this->max_i_clamp = max_i_clamp;
}

void PidController::minMaxCorrcetion(float min_correction, float max_correction) {
    this->min_correction = min_correction;
    this->max_correction = max_correction;
}

float PidController::calculateCorrection(float set_point, float current_point, double current_time) {
    this->set_point = set_point;
    this->current_point = current_point;

    float error = set_point - current_point;
    double time_diff = (current_time - old_time)/1000;

    old_time = current_time;  // Update the last time stamp

    pid_data[1] = error - pid_data[0];  //prevError(0), errorChange(1), errorSlope(2), errorArea(3)

    if(first_flag){
        pid_data[1] = 0;  // Initialize the first error change to zero
        first_flag = false;  // Set the flag to false after the first calculation
    }

    pid_data[2] = pid_data[1] / time_diff;
    pid_data[3] = pid_data[3] + (error * time_diff);
    pid_data[0] = error;
    
    // Clamp the integral to prevent windup
    if (pid_data[3] < min_i_clamp) {
        pid_data[3] = min_i_clamp;
    } else if (pid_data[3] > max_i_clamp) {
        pid_data[3] = max_i_clamp;
    }

    correction = kp * error + kd * pid_data[2] + ki * pid_data[3];

    // Clamp the correction to the defined limits
    if (correction < min_correction) {
        correction = min_correction;
    } else if (correction > max_correction) {
        correction = max_correction;
    }

    for(int i = 0; i < 4; i++) {
        Serial.print(pid_data[i]);  // Reset PID data after each calculation
        Serial.print("   ");
    }
    Serial.println();

    return correction;
}