import 'dart:convert';
import 'dart:math';

class RosParser {
  /// Parses a ROS pose message (as JSON string) and extracts x, y, theta.
  /// Expects a format like:
  /// {
  ///   "position": {"x": 1.0, "y": 2.0},
  ///   "orientation": {"z": 0.0, "w": 1.0}
  /// }
  static ({double x, double y, double theta})? parsePose(String jsonData) {
    try {
      final data = json.decode(jsonData);

      // Extract position
      final x = (data['position']['x'] as num).toDouble();
      final y = (data['position']['y'] as num).toDouble();

      // Extract orientation (assuming theta is in radians and encoded as yaw)
      double theta = 0.0;
      if (data['orientation'] != null) {
        // If theta is directly available
        if (data['orientation']['theta'] != null) {
          theta = (data['orientation']['theta'] as num).toDouble();
        } else if (data['orientation']['z'] != null && data['orientation']['w'] != null) {
          // If orientation is quaternion, convert to yaw (theta)
          final z = (data['orientation']['z'] as num).toDouble();
          final w = (data['orientation']['w'] as num).toDouble();
          theta = 2 * atan2(z, w);
        }
      }

      return (x: x, y: y, theta: theta);
    } catch (e) {
      return null;
    }
  }
}