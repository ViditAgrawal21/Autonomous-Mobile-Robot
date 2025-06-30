#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/float32_multi_array.hpp"
#include "sensor_msgs/msg/range.hpp"

class UltrasonicData : public rclcpp::Node
{
public:
    UltrasonicData() : Node("ultrasonic_data_node")
    {
        subscription_ = this->create_subscription<std_msgs::msg::Float32MultiArray>(
            "ultrsonic_sensor", 10,
            std::bind(&UltrasonicData::data_callback, this, std::placeholders::_1)
        );

        sensor_data_pub_ = this->create_publisher<sensor_msgs::msg::Range>(
            "stamped_ultrasonic_sensor_data", 10);
    }

private:
    void data_callback(const std_msgs::msg::Float32MultiArray::SharedPtr msg)
    {
        sensor_data_ = *msg;

        ultrasonic_data_msg_.header.stamp = this->get_clock()->now();
        ultrasonic_data_msg_.radiation_type = sensor_msgs::msg::Range::ULTRASOUND;
        ultrasonic_data_msg_.header.frame_id = "ultrasonic_sensor";
        ultrasonic_data_msg_.field_of_view = 2.1; // Example field of view in radians
        ultrasonic_data_msg_.min_range = 0.20; // Minimum range in meters
        ultrasonic_data_msg_.max_range = 4.0; // Maximum range in meters
        ultrasonic_data_msg_.range = sensor_data_.data[0]; // Example range value in meters


        sensor_data_pub_->publish(ultrasonic_data_msg_);
    }

    rclcpp::Subscription<std_msgs::msg::Float32MultiArray>::SharedPtr subscription_;
    rclcpp::Publisher<sensor_msgs::msg::Range>::SharedPtr sensor_data_pub_;

    std_msgs::msg::Float32MultiArray sensor_data_;
    sensor_msgs::msg::Range ultrasonic_data_msg_;
};

int main(int argc, char *argv[])
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<UltrasonicData>());
    rclcpp::shutdown();
    return 0;
}
