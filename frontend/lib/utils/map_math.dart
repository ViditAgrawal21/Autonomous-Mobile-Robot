import 'dart:math';

/// Utility math functions for AGV map calculations.
class MapMath {
  /// Calculates the Euclidean distance between two points.
  static double distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Calculates the angle (in degrees) from point (x1, y1) to (x2, y2).
  static double angleDegrees(double x1, double y1, double x2, double y2) {
    final radians = atan2(y2 - y1, x2 - x1);
    return radians * 180 / pi;
  }

  /// Converts degrees to radians.
  static double degToRad(double degrees) => degrees * pi / 180;

  /// Converts radians to degrees.
  static double radToDeg(double radians) => radians * 180 / pi;

  /// Returns the midpoint between two points.
  static Point<double> midpoint(double x1, double y1, double x2, double y2) {
    return Point((x1 + x2) / 2, (y1 + y2) / 2);
  }
}