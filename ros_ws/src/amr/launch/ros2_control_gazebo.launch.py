from launch import LaunchDescription
from launch.actions import RegisterEventHandler
from launch.event_handlers import OnProcessExit
from launch.substitutions import Command, FindExecutable, PathJoinSubstitution
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource

from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare
import os
from ament_index_python.packages import get_package_share_directory
from launch.actions import ExecuteProcess
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration


def generate_launch_description():

    package_name='amr'

    use_ros2_control = LaunchConfiguration('use_ros2_control')

    joy_params = os.path.join(get_package_share_directory('amr'),'config','joystick.yaml')

    # Get URDF via xacro
    robot_description_content = Command(
        [
            PathJoinSubstitution([FindExecutable(name="xacro")]),
            " ",
            PathJoinSubstitution(
                [FindPackageShare("amr"), "urdf", "robot.xacro"]),
            " ",
            "use_ros2_control:=", use_ros2_control,
        ]
    )
    robot_description = {"robot_description": robot_description_content}

    rviz_config = PathJoinSubstitution(
        [FindPackageShare("amr"), "rviz", "urdf_config.rviz"]
    )

    gazebo_bridge_config = os.path.join(get_package_share_directory(package_name),'config','gazebo_bridge.yaml')

    robot_state_pub_node = Node(
        package="robot_state_publisher",
        executable="robot_state_publisher",
        output="both",
        parameters=[robot_description],
    )

    gz_sim_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([ FindPackageShare("ros_gz_sim"), "launch", "gz_sim.launch.py" ])
        ),
        launch_arguments={
            "gz_args": "/home/nikhil/Work/technowings/Autonomous-Mobile-Robot/ros_ws/src/amr/worlds/basketball_arena.sdf -r"
        }.items()
    )

    # Node to publish robot_description
    ros_gz_sim_node = Node(
        package="ros_gz_sim",
        executable="create",
        arguments=["-topic", "robot_description"]
    )

    # Parameter bridge node
    ros_gz_bridge_node = Node(
        package="ros_gz_bridge",
        executable="parameter_bridge",
        arguments=['--ros-args', '-p', f'config_file:={gazebo_bridge_config}',
        ]
    )

    # Joy node for joystick input
    joy_node = Node(
            package="joy",
            executable="joy_node",
            parameters=[joy_params],
         )

    # Teleop node for joystick control
    teleop_node = Node(
            package="teleop_twist_joy",
            executable="teleop_node",
            name="teleop_node",
            parameters=[joy_params],
         )
    
    # Twist to Stamped converter
    twist_to_stamped_node = Node(
        package="amr",
        executable="twist_to_stamped"
    )

    # RViz2
    rviz_node = Node(
        package="rviz2",
        executable="rviz2",
        output="screen",
        arguments=["-d", rviz_config]
    )

    # Spawner: diff_drive_controller
    diff_drive_spawner_node = Node(
        package="controller_manager",
        executable="spawner",
        output="screen",
        arguments=["diff_drive_controller", "--controller-manager", "/controller_manager"],
    )

    # Spawner: joint_state_broadcaster
    joint_state_broadcaster_spawner_node = Node(
        package="controller_manager",
        executable="spawner",
        output="screen",
        arguments=["joint_state_broadcaster", "--controller-manager", "/controller_manager"],
    )


    delay_diff_drive_spawner_node = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=ros_gz_sim_node,
            on_exit=[diff_drive_spawner_node],
        )
    )

    delay_joint_state_broadcaster_spawner = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=ros_gz_sim_node,
            on_exit=[joint_state_broadcaster_spawner_node],
        )
    )
    
    delay_ros_gz_bridge_node = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=ros_gz_sim_node,
            on_exit=[ros_gz_bridge_node],
        )
    )

    nodes = [
        DeclareLaunchArgument(name="use_ros2_control", default_value="false",  # or "false" if you want
                description="Use ros2_control if true, else gazebo control",),

        robot_state_pub_node,
        gz_sim_launch,
        ros_gz_sim_node,
        delay_ros_gz_bridge_node,
        # delay_diff_drive_spawner_node,
        # delay_joint_state_broadcaster_spawner,
        twist_to_stamped_node,
        rviz_node,
        joy_node,
        teleop_node,
    ]

    return LaunchDescription(nodes)