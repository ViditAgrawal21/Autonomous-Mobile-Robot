//Show/edit live map
import 'package:flutter/material.dart';

// Dummy map data (replace with real map data from control screen)
class MapObject {
  final Offset position;
  final Size size;
  MapObject(this.position, this.size);
}

class MapPage extends StatefulWidget {
  // final bool isDarkMode;
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Example map objects (replace with fetched data)
  List<MapObject> obstacles = [
    MapObject(const Offset(40, 30), const Size(50, 25)),
    MapObject(const Offset(180, 60), const Size(45, 35)),
    MapObject(const Offset(90, 120), const Size(70, 20)),
  ];

  int? selectedObstacle;
  String selectedTool = "Pencil";
  String objectType = "Obstacle";
  double width = 40;
  double height = 20;

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
              const SizedBox(height: 24),
              Text(
                'Map Editing Interface',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                // width: 350, // Remove fixed width for responsiveness
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  // Remove boxShadow for flat look
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
                          'Map Editor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.upload, color: theme.primaryColor),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.download, color: theme.primaryColor),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Map Canvas
                    Center(
                      child: Container(
                        width: 270,
                        height: 180,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF23242B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(270, 180),
                              painter: _GridPainter(
                                isDark: isDark,
                                theme: theme,
                              ),
                            ),
                            // Obstacles
                            ...obstacles.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final obj = entry.value;
                              final isSelected = selectedObstacle == idx;
                              return Positioned(
                                left: obj.position.dx,
                                top: obj.position.dy,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedObstacle = idx;
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: obj.size.width,
                                        height: obj.size.height,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.redAccent.withOpacity(
                                                  0.5,
                                                )
                                              : Colors.grey[400],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: CustomPaint(
                                              painter: _SelectionPainter(
                                                isDark: isDark,
                                                theme: theme,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
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
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: theme.iconTheme.color),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Editing Tools
                    Text(
                      'Editing Tools',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ToolButton(
                          icon: Icons.edit,
                          label: "Pencil",
                          selected: selectedTool == "Pencil",
                          onTap: () => setState(() => selectedTool = "Pencil"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.delete_outline,
                          label: "Eraser",
                          selected: selectedTool == "Eraser",
                          onTap: () => setState(() => selectedTool = "Eraser"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.crop_16_9,
                          label: "Rectangle",
                          selected: selectedTool == "Rectangle",
                          onTap: () =>
                              setState(() => selectedTool = "Rectangle"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.select_all,
                          label: "Select",
                          selected: selectedTool == "Select",
                          onTap: () => setState(() => selectedTool = "Select"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.circle_outlined,
                          label: "Circle",
                          selected: selectedTool == "Circle",
                          onTap: () => setState(() => selectedTool = "Circle"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.open_in_full,
                          label: "Resize",
                          selected: selectedTool == "Resize",
                          onTap: () => setState(() => selectedTool = "Resize"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.rotate_right,
                          label: "Rotate",
                          selected: selectedTool == "Rotate",
                          onTap: () => setState(() => selectedTool = "Rotate"),
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ToolButton(
                          icon: Icons.edit_note,
                          label: "Edit",
                          selected: selectedTool == "Edit",
                          onTap: () => setState(() => selectedTool = "Edit"),
                          isDark: isDark,
                          theme: theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Properties
                    Text(
                      'Properties',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: objectType,
                            decoration: InputDecoration(
                              labelText: "Object Type",
                              border: const OutlineInputBorder(),
                              labelStyle: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            dropdownColor: theme.cardColor,
                            items: const [
                              DropdownMenuItem(
                                value: "Obstacle",
                                child: Text("Obstacle"),
                              ),
                              DropdownMenuItem(
                                value: "Path",
                                child: Text("Path"),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                objectType = val ?? "Obstacle";
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: width.toString(),
                                  decoration: InputDecoration(
                                    labelText: "Width (cm)",
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      width = double.tryParse(val) ?? width;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  initialValue: height.toString(),
                                  decoration: InputDecoration(
                                    labelText: "Height (cm)",
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      height = double.tryParse(val) ?? height;
                                    });
                                  },
                                ),
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

// Tool Button Widget
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                    ? theme.primaryColor.withOpacity(0.15)
                    : const Color(0xFFEDF4FF))
              : (isDark ? theme.cardColor : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? theme.primaryColor
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? theme.primaryColor : theme.iconTheme.color,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? theme.primaryColor : theme.iconTheme.color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
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

// Selection painter for selected obstacle
class _SelectionPainter extends CustomPainter {
  final bool isDark;
  final ThemeData theme;
  _SelectionPainter({required this.isDark, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Draw rectangle border
    canvas.drawRect(Offset.zero & size, paint);

    // Draw handles (circles at corners)
    final handlePaint = Paint()..color = theme.primaryColor;
    const handleRadius = 5.0;
    canvas.drawCircle(const Offset(0, 0), handleRadius, handlePaint);
    canvas.drawCircle(Offset(size.width, 0), handleRadius, handlePaint);
    canvas.drawCircle(Offset(0, size.height), handleRadius, handlePaint);
    canvas.drawCircle(
      Offset(size.width, size.height),
      handleRadius,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
