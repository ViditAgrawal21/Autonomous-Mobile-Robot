import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  double dotX = 0.5;
  double dotY = 0.5;
  final double moveStep = 0.05;

  void _onJoystickMove(StickDragDetails details) {
    setState(() {
      dotX += details.x * moveStep;
      dotY += details.y * moveStep; // <-- changed to plus
      dotX = dotX.clamp(0.0, 1.0);
      dotY = dotY.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const distance = "24.5 m";
    const area = "42 m²";
    const duration = "05:23";

    // Colors for joystick
    final baseColor = isDark
        ? Colors.black
        : const Color(0xFFE0E0E0); // greyish in light mode
    final arrowsColor = isDark ? Colors.red : Colors.blue;
    final stickColor = isDark ? Colors.red : Colors.blue;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF6F8FB),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 18),
              // Text(
              //   'Map Creation & Tracking',
              //   style: TextStyle(
              //     fontWeight: FontWeight.w600,
              //     fontSize: 16,
              //     color: theme.textTheme.bodyLarge?.color,
              //     letterSpacing: 1.1,
              //   ),
              // ),
              const SizedBox(height: 18),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Map Creation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: theme.textTheme.bodyLarge?.color,
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
                        Text(
                          'Recording',
                          style: TextStyle(
                            color: const Color(0xFF2ECC71),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Map Canvas
                    Center(
                      child: Container(
                        width: 240,
                        height: 180,
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.cardColor
                              : const Color(0xFFF6F8FB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(240, 180),
                              painter: _GridPainter(
                                isDark: isDark,
                                theme: theme,
                              ),
                            ),
                            // Obstacles (dummy)
                            Positioned(
                              left: 30,
                              top: 24,
                              child: Container(
                                width: 50,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 140,
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
                              left: 80,
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
                            // Path (dummy)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _PathPainter(
                                  isDark: isDark,
                                  theme: theme,
                                ),
                              ),
                            ),
                            // Moving Dot
                            Positioned(
                              left: dotX * 220,
                              top: dotY * 160,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.red : Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _MapIconBtn(icon: Icons.search, onTap: () {}),
                        const SizedBox(width: 8),
                        _MapIconBtn(icon: Icons.add, onTap: () {}),
                        const SizedBox(width: 8),
                        _MapIconBtn(icon: Icons.remove, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _InfoBlock(
                          label: "Distance",
                          value: distance,
                          theme: theme,
                        ),
                        _InfoBlock(label: "Area", value: area, theme: theme),
                        _InfoBlock(
                          label: "Duration",
                          value: duration,
                          theme: theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Manual Control',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Joystick(
                            base: JoystickBase(
                              decoration: JoystickBaseDecoration(
                                color: baseColor,
                                drawOuterCircle: false,
                              ),
                              arrowsDecoration: JoystickArrowsDecoration(
                                color: arrowsColor,
                              ),
                            ),
                            stick: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: stickColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            mode: JoystickMode.all,
                            listener: _onJoystickMove,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ControlButton(
                                label: "Start",
                                color: Colors.green[200]!,
                                textColor: Colors.green[900]!,
                                onTap: () {},
                              ),
                              _ControlButton(
                                label: "Stop",
                                color: Colors.red[200]!,
                                textColor: Colors.red[900]!,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _MapIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.iconTheme.color),
        onPressed: onTap,
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoBlock({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF23242B)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (theme.brightness != Brightness.dark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// Grid painter for background
class _GridPainter extends CustomPainter {
  final bool isDark;
  final ThemeData theme;
  _GridPainter({required this.isDark, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? theme.cardColor.withOpacity(0.7)
          : const Color(0xFFEFF4FB)
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
  final bool isDark;
  final ThemeData theme;
  _PathPainter({required this.isDark, required this.theme});

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
      ..color = theme.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
