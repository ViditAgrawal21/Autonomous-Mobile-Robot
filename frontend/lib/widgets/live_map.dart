import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../services/ros_services.dart';
import '../utils/map_math.dart';

// Dummy RosParser for pose parsing; replace with your actual implementation or import if it exists elsewhere.
class RosPose {
  final double x;
  final double y;
  final double theta;
  RosPose({required this.x, required this.y, required this.theta});
}

class RosParser {
  static RosPose? parsePose(dynamic data) {
    // Replace this with actual parsing logic
    if (data is Map<String, dynamic> &&
        data.containsKey('x') &&
        data.containsKey('y') &&
        data.containsKey('theta')) {
      return RosPose(
        x: (data['x'] as num).toDouble(),
        y: (data['y'] as num).toDouble(),
        theta: (data['theta'] as num).toDouble(),
      );
    }
    return null;
  }
}

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  ui.Image? _mapImage;
  Offset _robotPosition = Offset.zero;
  double _robotAngle = 0;

  @override
  void initState() {
    super.initState();
    _loadMapImage();
    _listenToRobotPose();
  }

  Future<void> _loadMapImage() async {
    // Placeholder for map loading - replace with actual map data
    final ByteData data = await rootBundle.load('assets/map_placeholder.png');
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() => _mapImage = frame.image);
  }

  void _listenToRobotPose() {
    ROSService.stream.listen((data) {
      // Parse ROS pose data (simplified example)
      final pose = RosParser.parsePose(data);
      if (pose != null && mounted) {
        setState(() {
          _robotPosition = Offset(pose.x, pose.y);
          _robotAngle = pose.theta;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(
        mapImage: _mapImage,
        robotPosition: _robotPosition,
        robotAngle: _robotAngle,
      ),
      size: Size.infinite,
    );
  }
}

class _MapPainter extends CustomPainter {
  final ui.Image? mapImage;
  final Offset robotPosition;
  final double robotAngle;

  _MapPainter({
    required this.mapImage,
    required this.robotPosition,
    required this.robotAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mapImage == null) return;

    // Draw map
    canvas.drawImageRect(
      mapImage!,
      Rect.fromLTWH(0, 0, mapImage!.width.toDouble(), mapImage!.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Draw robot
    final robotPaint = Paint()..color = Colors.blue;
    canvas.save();
    canvas.translate(robotPosition.dx, robotPosition.dy);
    canvas.rotate(robotAngle);
    canvas.drawCircle(Offset.zero, 10, robotPaint);
    canvas.drawLine(Offset.zero, Offset(20, 0), robotPaint..strokeWidth = 3);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}