import os
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import IncludeLaunchDescription, TimerAction
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import ThisLaunchFileDir
from launch.actions import RegisterEventHandler
from launch.event_handlers import OnProcessExit

def generate_launch_description():

    # Map and param file paths
    map_path = '/home/piros/fleet-management-system/ros_ws/src/amr/maps/tw_rnd.yaml'
    param_path = '/home/piros/fleet-management-system/ros_ws/src/amr/config/nav2_params1.yaml'

    # Launch the first launch file
    robot_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(os.path.dirname(__file__), 'ros2_control_robot.launch.py'))
    )

    robot_controller_spawner = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["diff_drive_controller", "--controller-manager", "/controller_manager"],
    )

    # Launch the second launch file
    nav2_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(os.path.dirname(__file__), 'bringup_launch.py')),
        launch_arguments={
            'map': map_path,
            'params_file': param_path,
            'use_sim_time': 'false'
        }.items()

    )

    # Delay rviz start after `joint_state_broadcaster
    delay_nav2_launch = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=robot_controller_spawner,
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
            robot_controller_spawner,
            delay_nav2_launch,
            ]

    return LaunchDescription(node)
