cmake_minimum_required(VERSION 3.8)
project(amr)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(nav2_msgs REQUIRED)
find_package(rclcpp_action REQUIRED)
find_package(tf2 REQUIRED)
find_package(tf2_geometry_msgs REQUIRED)
# uncomment the following section in order to fill in
# further dependencies manually.
# find_package(<dependency> REQUIRED)

add_executable(twist_to_stamped hardware/twist_to_stamped.cpp)   #"cpp_node" name of executable
ament_target_dependencies(twist_to_stamped rclcpp geometry_msgs)         #these two lines create an executable but not install it

add_executable(ultrasonic_data hardware/ultrasonic_data.cpp)   #"cpp_node" name of executable
ament_target_dependencies(ultrasonic_data rclcpp std_msgs sensor_msgs)         #these two lines create an executable but not install it

add_executable(ultrasonic_to_laserscan hardware/ultrasonic_to_laserscan.cpp)   #"cpp_node" name of executable
ament_target_dependencies(ultrasonic_to_laserscan rclcpp sensor_msgs std_msgs)         #these two lines create an executable but not install it

add_executable(ptp_nav hardware/ptp_nav.cpp)   #"cpp_node" name of executable
ament_target_dependencies(ptp_nav rclcpp geometry_msgs nav2_msgs rclcpp_action tf2 tf2_geometry_msgs)         #these two lines create an executable but not install it

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # comment the line when a copyright and license is added to all source files
  set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # comment the line when this package is in a git repo and when
  # a copyright and license is added to all source files
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

install(
  DIRECTORY launch urdf rviz config hardware                  #directory which needs to be installed
  DESTINATION share/${PROJECT_NAME}/      #directory where it will be installed
)

install(TARGETS            #installs the executable
  twist_to_stamped
  ultrasonic_data
  ultrasonic_to_laserscan
  ptp_nav
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
