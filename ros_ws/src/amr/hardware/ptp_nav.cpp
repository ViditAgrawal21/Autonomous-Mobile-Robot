#include "rclcpp/rclcpp.hpp"
#include "nav2_msgs/action/navigate_to_pose.hpp"
#include "rclcpp_action/rclcpp_action.hpp"
#include "geometry_msgs/msg/pose_stamped.hpp"
#include "tf2/LinearMath/Quaternion.h"
#include "tf2_geometry_msgs/tf2_geometry_msgs.hpp"

using std::placeholders::_1;
using std::placeholders::_2;

class PtpNode : public rclcpp::Node
{
public:
  using NavigateToPose = nav2_msgs::action::NavigateToPose;
  using GoalHandleNavigateToPose = rclcpp_action::ClientGoalHandle<NavigateToPose>;

  PtpNode() : Node("ptp_node"), current_goal_index_(0)
  {
    action_client_ = rclcpp_action::create_client<NavigateToPose>(this, "navigate_to_pose");

    goals_.push_back(create_goal(0.8, 0.2, 0.0));        // Goal A
    goals_.push_back(create_goal(0.0, -1.0, 3 * M_PI / 2));   // Goal B
    goals_.push_back(create_goal(0.2, -0.1, 0.0));       // Goal C
    goals_.push_back(create_goal(1.0, -1.0, M_PI));       // Goal D

    timer_ = this->create_wall_timer(
      std::chrono::seconds(1),
      std::bind(&PtpNode::send_next_goal, this));
  }

private:
  rclcpp_action::Client<NavigateToPose>::SharedPtr action_client_;
  std::vector<NavigateToPose::Goal> goals_;
  int current_goal_index_;
  rclcpp::TimerBase::SharedPtr timer_;

  NavigateToPose::Goal create_goal(double x, double y, double yaw)
  {
    NavigateToPose::Goal goal_msg;
    goal_msg.pose.header.frame_id = "map";
    goal_msg.pose.header.stamp = this->now();
    goal_msg.pose.pose.position.x = x;
    goal_msg.pose.pose.position.y = y;

    tf2::Quaternion q;
    q.setRPY(0, 0, yaw);
    goal_msg.pose.pose.orientation = tf2::toMsg(q);

    return goal_msg;
  }

  void send_next_goal()
  {
    if (!action_client_->wait_for_action_server(std::chrono::seconds(1))) {
      RCLCPP_WARN(this->get_logger(), "Waiting for action server...");
      return;
    }

    RCLCPP_INFO(this->get_logger(), "Sending goal %d", current_goal_index_ + 1);

    auto goal = goals_[current_goal_index_];

    auto send_goal_options = rclcpp_action::Client<NavigateToPose>::SendGoalOptions();
    send_goal_options.result_callback =
      std::bind(&PtpNode::result_callback, this, _1);

    action_client_->async_send_goal(goal, send_goal_options);

    timer_->cancel();  // stop sending goals repeatedly; resume after each goal result
  }

  void result_callback(const GoalHandleNavigateToPose::WrappedResult & result)
  {
    if (result.code == rclcpp_action::ResultCode::SUCCEEDED) {
      RCLCPP_INFO(this->get_logger(), "Goal %d reached", current_goal_index_ + 1);
    } else {
      RCLCPP_WARN(this->get_logger(), "Goal %d failed!", current_goal_index_ + 1);
    }

    // Move to the next goal
    current_goal_index_ = (current_goal_index_ + 1) % goals_.size();

    // Resume the timer to send the next goal
    timer_->reset();
  }
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<PtpNode>();
  rclcpp::spin(node);
  rclcpp::shutdown();
  return 0;
}
