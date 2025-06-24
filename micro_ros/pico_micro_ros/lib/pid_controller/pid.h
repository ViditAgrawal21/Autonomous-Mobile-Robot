#ifndef PID_H
#define PID_H

#include "Arduino.h"


class PidController
{
private:
    float set_point;           //traget value
    float current_point;       //current value
    float kp, ki, kd;          //pid values
    float max_correction;      //maximum correction value
    float min_correction;      //minimum pwm value
    float min_i_clamp;         //minimum integral clamp value
    float max_i_clamp;         //maximum integral clamp value
    float error;               //error value
    float correction;          //correction value 
    float pid_data[4] = {0};   //pid data array: pid_data[0] = prevError, pid_data[1] = errorChange, pid_data[2] = errorSlope, pid_data[3] = errorArea
    float old_time;            //last time stamp
    bool first_flag = true;    //flag to check if it is the first run

public:
    PidController();
    void setParameters(float kp, float ki, float kd, 
                        float min_i_clamp, float max_i_clamp,
                        float min_correction, float max_correction);
    void setPidValues(float kp, float ki, float kd); 
    void integralLimits(float min_i_clamp, float max_i_clamp);
    void minMaxCorrcetion(float min_correction, float max_correction);
    float calculateCorrection(float set_point, float current_point, double current_time);
};

#endif