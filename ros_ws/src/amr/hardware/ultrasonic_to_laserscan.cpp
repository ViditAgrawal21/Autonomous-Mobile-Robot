#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/laser_scan.hpp"
#include "std_msgs/msg/float32_multi_array.hpp"

class UltrasonicToLaserscan : public rclcpp::Node
{
public:
    UltrasonicToLaserscan()
    : Node("ultrasonic_to_laserscan")
    {
        rclcpp::QoS qos_profile = rclcpp::QoS(rclcpp::KeepLast(10)).transient_local();

        ultrasonic_sub_ = this->create_subscription<std_msgs::msg::Float32MultiArray>(
            "/ultrasonic_sensor", 10,
            std::bind(&UltrasonicToLaserscan::sensor_data_callback, this, std::placeholders::_1));

        ultrasonic_scan_pub_ = this->create_publisher<sensor_msgs::msg::LaserScan>(
            "ultrasonic_scan", qos_profile);

    }

private:
    void sensor_data_callback(const std_msgs::msg::Float32MultiArray::SharedPtr msg)
    {
        // std::vector<float> range(120, msg->data[0]);
        std::vector<float> range = {msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0], msg->data[0],
                                    msg->data[0], msg->data[0], msg->data[0]};
        // ultrasonic_scan_msg_.header.seq
        ultrasonic_scan_msg_.header.stamp = this->get_clock()->now();
        ultrasonic_scan_msg_.header.frame_id = "ultrasonic_sensor";
        ultrasonic_scan_msg_.angle_min = 0.523;
        ultrasonic_scan_msg_.angle_max = 2.617;
        ultrasonic_scan_msg_.angle_increment = 0.0698; // 120 degrees in radians

        ultrasonic_scan_msg_.range_min = 0.2;
        ultrasonic_scan_msg_.range_max = 4.0;
        ultrasonic_scan_msg_.scan_time = 0.001;
        ultrasonic_scan_msg_.time_increment = 0.001;
        ultrasonic_scan_msg_.intensities.clear();

        float num_of_readings = static_cast<int>(std::round((ultrasonic_scan_msg_.angle_max - ultrasonic_scan_msg_.angle_min) / ultrasonic_scan_msg_.angle_increment)) + 1;

        ultrasonic_scan_msg_.ranges.assign(num_of_readings, msg->data[0]);

        // ultrasonic_scan_msg_.ranges = range;
        
        ultrasonic_scan_pub_->publish(ultrasonic_scan_msg_);
    }

    rclcpp::Subscription<std_msgs::msg::Float32MultiArray>::SharedPtr ultrasonic_sub_;
    rclcpp::Publisher<sensor_msgs::msg::LaserScan>::SharedPtr ultrasonic_scan_pub_;

    sensor_msgs::msg::LaserScan ultrasonic_scan_msg_;
};

int main(int argc, char *argv[])
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<UltrasonicToLaserscan>());
    rclcpp::shutdown();
    return 0;
}
