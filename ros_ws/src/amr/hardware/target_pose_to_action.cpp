#include "rclcpp/rclcpp.hpp"
#include "nav2_msgs/action/navigate_to_pose.hpp"
#include "rclcpp_action/rclcpp_action.hpp"
#include "geometry_msgs/msg/pose_stamped.hpp"
#include "geometry_msgs/msg/twist.hpp"
#include "tf2/LinearMath/Quaternion.h"
#include "tf2_geometry_msgs/tf2_geometry_msgs.hpp"

class TargetPoseToAction : public rclcpp::Node
{
  public:
    using Pose = geometry_msgs::msg::Twist;
    using NavigateToPose = nav2_msgs::action::NavigateToPose;
    using GoalHandleNavigateToPose = rclcpp_action::ClientGoalHandle<NavigateToPose>;

    TargetPoseToAction()
    : Node("target_to_pose_to_action")
    {

      action_client_ = rclcpp_action::create_client<NavigateToPose>(this, "navigate_to_pose");

      target_pose_sub_ = this->create_subscription<Pose>(
          "/target_pose", 10,
          std::bind(&TargetPoseToAction::target_pose_callback, this, std::placeholders::_1));

    }


  private:
    
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

    void result_callback(const GoalHandleNavigateToPose::WrappedResult & result)
    {
      if (result.code == rclcpp_action::ResultCode::SUCCEEDED) {
        RCLCPP_INFO(this->get_logger(), "Goal reached");
      } else {
        RCLCPP_WARN(this->get_logger(), "Goal failed!");
      }
    }

    void send_goal(){
      if (!action_client_->wait_for_action_server(std::chrono::seconds(1))) {
        RCLCPP_WARN(this->get_logger(), "Waiting for action server...");
        return;
      }

      timer_->cancel();

      RCLCPP_INFO(this->get_logger(), "Sending goal..");

      auto goal = goal_;

      auto send_goal_options = rclcpp_action::Client<NavigateToPose>::SendGoalOptions();
      send_goal_options.result_callback =
        std::bind(&TargetPoseToAction::result_callback, this, std::placeholders::_1);

      
      action_client_->async_send_goal(goal, send_goal_options);
    }

    void target_pose_callback(const Pose::SharedPtr msg)
    {
      timer_.reset();

      goal_ = create_goal(msg->linear.x, msg->linear.y, msg->angular.z);
      
      timer_ = this->create_wall_timer(
        std::chrono::seconds(1),
        std::bind(&TargetPoseToAction::send_goal, this));
    }

    rclcpp::Subscription<Pose>::SharedPtr target_pose_sub_;
    rclcpp_action::Client<NavigateToPose>::SharedPtr action_client_;

    rclcpp::TimerBase::SharedPtr timer_;
    NavigateToPose::Goal goal_;

};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<TargetPoseToAction>();
  rclcpp::spin(node);
  rclcpp::shutdown();
  return 0;
}
