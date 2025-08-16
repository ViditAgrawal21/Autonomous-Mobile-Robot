import os
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import IncludeLaunchDescription, TimerAction
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import ThisLaunchFileDir
from launch.actions import RegisterEventHandler
from launch.event_handlers import OnProcessExit

def generate_launch_description():

    robot_controller_spawner = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["diff_drive_controller", "--controller-manager", "/controller_manager"],
    )

    # Launch the second launch file
    nav2_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(os.path.dirname(__file__), 'navigation_launch.py')),
        launch_arguments={
            'use_sim_time': 'false'
        }.items()

    )

    slam_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(os.path.dirname(__file__), 'online_async_launch.py')),
        launch_arguments={
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

    delay_slam_launch = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=robot_controller_spawner,
            on_exit=[slam_launch],
        )
    )

    node = [robot_controller_spawner,
            delay_nav2_launch,
            delay_slam_launch,
            ]

    return LaunchDescription(node)
