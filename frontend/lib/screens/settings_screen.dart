import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final String themeColor;
  final Function(String) onColorChanged;

  const SettingsScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.themeColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;
  late String _themeColor;
  String _mapFormat = "ROS Map (.yaml/.pgm)";
  String _resolution = "1024x768";

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
    _themeColor = widget.themeColor;
  }

  void _setTheme(bool value) {
    setState(() {
      _darkMode = value;
    });
    widget.onThemeChanged(value);
  }

  void _setColor(String color) {
    setState(() {
      _themeColor = color;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 24),
              // Text(
              //   'Map Sync & Settings',
              //   style: TextStyle(
              //     fontWeight: FontWeight.w600,
              //     fontSize: 16,
              //     color: theme.textTheme.bodyLarge?.color,
              //     letterSpacing: 1.1,
              //   ),
              // ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
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
                          'Settings',
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
                          'Connected',
                          style: TextStyle(
                            color: const Color(0xFF2ECC71),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Appearance
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appearance',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              Switch(
                                value: _darkMode,
                                onChanged: _setTheme,
                                activeColor: Colors.redAccent,
                              ),
                            ],
                          ),
                          // Text(
                          //   'Use dark theme',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: theme.textTheme.bodyMedium?.color,
                          //   ),
                          // ),
                          // Only show color selector if not dark mode
                          if (!_darkMode) ...[
                            const SizedBox(height: 16),
                            // Text(
                            //   'Theme Color',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w500,
                            //     fontSize: 14,
                            //     color: theme.textTheme.bodyLarge?.color,
                            //   ),
                            // ),
                            // const SizedBox(height: 8),
                            // Row(
                            //   children: [
                            //     _ColorDot(
                            //       color: const Color(0xFF4F8CFF),
                            //       selected: _themeColor == "Blue",
                            //       onTap: () => _setColor("Blue"),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     _ColorDot(
                            //       color: const Color(0xFFB388FF),
                            //       selected: _themeColor == "Purple",
                            //       onTap: () => _setColor("Purple"),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     _ColorDot(
                            //       color: const Color(0xFF4FE6A5),
                            //       selected: _themeColor == "Green",
                            //       onTap: () => _setColor("Green"),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ],
                      ),
                    ),
                    // Current Map
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Map',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.cardColor, // <-- changed from Color(0xFFEFF4FB)
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: const Size(double.infinity, 100),
                                  painter: _GridPainter(
                                    isDark: isDark,
                                    theme: theme,
                                  ),
                                ),
                                // Dummy obstacles
                                Positioned(
                                  left: 30,
                                  top: 18,
                                  child: Container(
                                    width: 40,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.redAccent.withOpacity(0.5)
                                          : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 120,
                                  top: 40,
                                  child: Container(
                                    width: 35,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.redAccent.withOpacity(0.5)
                                          : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 70,
                                  top: 65,
                                  child: Container(
                                    width: 50,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.redAccent.withOpacity(0.5)
                                          : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                // Dummy path
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _PathPainter(
                                      isDark: isDark,
                                      theme: theme,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Last edited: Today, 14:32',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              Text(
                                'Size: 20m x 15m',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Sync to AGV'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: theme.primaryColor,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Sync Settings
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sync Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _mapFormat,
                            decoration: InputDecoration(
                              labelText: "Map Format",
                              border: const OutlineInputBorder(),
                              labelStyle: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            dropdownColor: theme.cardColor,
                            items: const [
                              DropdownMenuItem(
                                value: "ROS Map (.yaml/.pgm)",
                                child: Text("ROS Map (.yaml/.pgm)"),
                              ),
                              DropdownMenuItem(
                                value: "Image (.png)",
                                child: Text("Image (.png)"),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _mapFormat = val ?? "ROS Map (.yaml/.pgm)";
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: _resolution,
                            decoration: InputDecoration(
                              labelText: "Resolution",
                              border: const OutlineInputBorder(),
                              labelStyle: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _resolution = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
    path.moveTo(20, size.height - 30);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.8,
      size.width - 20,
      30,
    );
    final paint = Paint()
      ..color = theme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.black, width: 3) : null,
        ),
      ),
    );
  }
}
