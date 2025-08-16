#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/twist_stamped.hpp>
#include <std_msgs/msg/int32.hpp>
#include <action_msgs/msg/goal_status_array.hpp>

using std::placeholders::_1;

class LedColourNode : public rclcpp::Node
{
public:
    LedColourNode() : Node("led_colour_node"), is_moving_(false), nav_status_("UNKNOWN")
    {
        // Publisher
        status_pub_ = this->create_publisher<std_msgs::msg::Int32>("/led_colour", 10);

        // Subscriber to cmd_vel
        cmd_vel_sub_ = this->create_subscription<geometry_msgs::msg::TwistStamped>(
            "/diff_drive_controller/cmd_vel", 10, std::bind(&LedColourNode::cmdVelCallback, this, _1));

        // Subscriber to navigate_to_pose result topic
        result_sub_ = this->create_subscription<action_msgs::msg::GoalStatusArray>(
            "/navigate_to_pose/_action/status", 10, std::bind(&LedColourNode::resultCallback, this, _1));

        // Timer to publish status
        timer_ = this->create_wall_timer(
            std::chrono::milliseconds(100),
            std::bind(&LedColourNode::publishStatus, this));
    }

private:
    void cmdVelCallback(const geometry_msgs::msg::TwistStamped::SharedPtr msg)
    {
        if (std::abs(msg->twist.angular.x) > 0.01 || std::abs(msg->twist.angular.z) > 0.01)
        {
            is_moving_ = true;
        }
        else
        {
            is_moving_ = false;
        }
    }

    void resultCallback(const action_msgs::msg::GoalStatusArray::SharedPtr msg)
    {
        if (msg->status_list.empty())
        {
            nav_status_ = "UNKNOWN";
            return;
        }

        auto latest_status = msg->status_list.back();

        switch (latest_status.status)
        {
        case action_msgs::msg::GoalStatus::STATUS_SUCCEEDED:
            nav_status_ = "SUCCEEDED";
            break;
        case action_msgs::msg::GoalStatus::STATUS_CANCELED:
            nav_status_ = "CANCELED";
            break;
        case action_msgs::msg::GoalStatus::STATUS_ABORTED:
            nav_status_ = "FAILED";
            break;
        default:
            nav_status_ = "UNKNOWN";
            break;
        }
    }

    void publishStatus()
    {
        std_msgs::msg::Int32 status_msg;

        if (is_moving_)
        {
            status_msg.data = 2; // Blue
        }
        else if (nav_status_ == "SUCCEEDED")
        {
            status_msg.data = 1; // Green
        }
        else if (nav_status_ == "CANCELED")
        {
            status_msg.data = 3; // Orange
        }
        else if (nav_status_ == "FAILED")
        {
            status_msg.data = 2; // Red
        }
        else
        {
            return; // Do not publish if status unknown
        }

        status_pub_->publish(status_msg);
        // RCLCPP_INFO(this->get_logger(), "Published Status: %d", status_msg.data);
    }

    // Members
    rclcpp::Publisher<std_msgs::msg::Int32>::SharedPtr status_pub_;
    rclcpp::Subscription<geometry_msgs::msg::TwistStamped>::SharedPtr cmd_vel_sub_;
    rclcpp::Subscription<action_msgs::msg::GoalStatusArray>::SharedPtr result_sub_;
    rclcpp::TimerBase::SharedPtr timer_;

    bool is_moving_;
    std::string nav_status_;
};

int main(int argc, char ** argv)
{
    rclcpp::init(argc, argv);
    auto node = std::make_shared<LedColourNode>();
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
