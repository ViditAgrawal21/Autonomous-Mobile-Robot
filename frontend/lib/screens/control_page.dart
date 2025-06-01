import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'dart:math';

class ControlPage extends StatefulWidget {
  final bool isDarkMode;
  const ControlPage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Dot position as a fraction of the map area (0.0 - 1.0)
  double dotX = 0.5;
  double dotY = 0.5;

  // Map area size (used for calculating dot position)
  static const double mapWidth = 310;
  static const double mapHeight = 180;

  // Joystick sensitivity
  static const double moveStep = 0.015;

  void _onJoystickMove(StickDragDetails details) {
    setState(() {
      // Update dot position based on joystick direction
      dotX += details.x * moveStep;
      dotY -= details.y * moveStep; // Y is inverted for UI

      // Clamp between 0 and 1
      dotX = dotX.clamp(0.0, 1.0);
      dotY = dotY.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy values for distance, area, duration
    final theme = Theme.of(context);
    const distance = "24.5 m";
    const area = "42 m²";
    const duration = "05:23";

    return Scaffold(
      
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 24),
              // const Text(
              //   'Map Creation & Tracking',
              //   style: TextStyle(
              //     fontWeight: FontWeight.w600,
              //     fontSize: 16,
              //     color: Colors.black87,
              //     letterSpacing: 1.1,
              //   ),
              // ),
              const SizedBox(height: 24),
              Container(
                // width: 350, // REMOVE this line for dynamic width
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Change from Color(0xFFEFF4FB) to transparent
                  borderRadius: BorderRadius.circular(32),
                  // Remove boxShadow if present
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Map Creation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Recording',
                          style: TextStyle(
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Map area with moving dot
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: mapWidth,
                            height: mapHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Stack(
                              children: [
                                // Grid background
                                CustomPaint(
                                  size: const Size(mapWidth, mapHeight),
                                  painter: _GridPainter(),
                                ),
                                // Dummy obstacles
                                Positioned(
                                  left: 40,
                                  top: 30,
                                  child: Container(
                                    width: 50,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 60,
                                  child: Container(
                                    width: 45,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 90,
                                  top: 120,
                                  child: Container(
                                    width: 70,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                // Dummy path
                                Positioned.fill(
                                  child: CustomPaint(painter: _PathPainter()),
                                ),
                                // Moving dot
                                Positioned(
                                  left: dotX * (mapWidth - 16) - 8,
                                  top: dotY * (mapHeight - 16) - 8,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFB71C1C), // Dark red
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.black54,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.black54),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.black54,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Distance, Area, Duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoCard(label: "Distance", value: distance),
                        _InfoCard(label: "Area", value: area),
                        _InfoCard(label: "Duration", value: duration),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Manual Control',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Centered Joystick
                    Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(90),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Joystick(
                            mode: JoystickMode.all,
                            listener: _onJoystickMove,
                            base: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F8FB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            stick: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF4F8CFF), Color(0xFF6F6CFF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB7F8C7),
                            foregroundColor: Colors.green[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            minimumSize: const Size(80, 40),
                          ),
                          child: const Text('Start'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD6D6),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            minimumSize: const Size(80, 40),
                          ),
                          child: const Text('Stop'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4F8CFF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// Dummy grid painter for background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEFF4FB)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 24) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Dummy path painter for AGV path
class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(20, size.height - 40);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.8,
      size.width - 20,
      40,
    );
    final paint = Paint()
      ..color = const Color(0xFF4F8CFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}