from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import IncludeLaunchDescription, TimerAction
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import ThisLaunchFileDir
from launch.actions import RegisterEventHandler
from launch.event_handlers import OnProcessExit

def generate_launch_description():

    # Map and param file paths
    map_path = '/home/piros/fleet-management-system/ros_ws/src/amr/maps/map_1750065869.yaml'
    param_path = '/home/piros/fleet-management-system/ros_ws/src/amr/config/nav2_params1.yaml'

    # Launch the first launch file
    robot_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([ThisLaunchFileDir(), '/home/nikhil/Work/technowings/Autonomous-Mobile-Robot/ros_ws/src/amr/launch/ros2_control_robot.launch.py'])
    )

    # Launch the second launch file
    nav2_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([ThisLaunchFileDir(), '/opt/ros/jazzy/share/nav2_bringup/launch/bringup_launch.py']),
        launch_arguments={
            'map': map_path,
            'params_file': param_path,
            'use_sim_time': 'false'
        }.items()

    )

    # Delay rviz start after `joint_state_broadcaster
    delay_nav2_launch = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=robot_launch,
            on_exit=[nav2_launch],
        )
    )

    # # Delay rviz start after `joint_state_broadcaster
    # delay_status_node = RegisterEventHandler(
    #     event_handler=OnProcessExit(
    #         target_action=nav2_launch,
    #         on_exit=[rviz_node],
    #     )
    # )

    node = [robot_launch,
            delay_nav2_launch,
            ]

    return LaunchDescription(node)
