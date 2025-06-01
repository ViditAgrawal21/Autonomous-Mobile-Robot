//Show/edit live map

import 'package:flutter/material.dart';

// Dummy map data (replace with real map data from control screen)
class MapObject {
  final Offset position;
  final Size size;
  MapObject(this.position, this.size);
}

class MapPage extends StatefulWidget {
  final bool isDarkMode;
  const MapPage({Key? key, required this.isDarkMode}) : super(key: key);

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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Map Editing Interface',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 350,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FB),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
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
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Map Editor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.upload, color: Color(0xFF4F8CFF)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: Color(0xFF4F8CFF)),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(270, 180),
                              painter: _GridPainter(),
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
                                          color: Colors.grey[400],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: CustomPaint(
                                              painter: _SelectionPainter(),
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
                              child: CustomPaint(painter: _PathPainter()),
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
                            color: const Color(0xFFF6F8FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.black54),
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
                            icon: const Icon(Icons.remove, color: Colors.black54),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Editing Tools
                    const Text(
                      'Editing Tools',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
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
                        ),
                        _ToolButton(
                          icon: Icons.delete_outline,
                          label: "Eraser",
                          selected: selectedTool == "Eraser",
                          onTap: () => setState(() => selectedTool = "Eraser"),
                        ),
                        _ToolButton(
                          icon: Icons.crop_16_9,
                          label: "Rectangle",
                          selected: selectedTool == "Rectangle",
                          onTap: () => setState(() => selectedTool = "Rectangle"),
                        ),
                        _ToolButton(
                          icon: Icons.select_all,
                          label: "Select",
                          selected: selectedTool == "Select",
                          onTap: () => setState(() => selectedTool = "Select"),
                        ),
                        _ToolButton(
                          icon: Icons.circle_outlined,
                          label: "Circle",
                          selected: selectedTool == "Circle",
                          onTap: () => setState(() => selectedTool = "Circle"),
                        ),
                        _ToolButton(
                          icon: Icons.open_in_full,
                          label: "Resize",
                          selected: selectedTool == "Resize",
                          onTap: () => setState(() => selectedTool = "Resize"),
                        ),
                        _ToolButton(
                          icon: Icons.rotate_right,
                          label: "Rotate",
                          selected: selectedTool == "Rotate",
                          onTap: () => setState(() => selectedTool = "Rotate"),
                        ),
                        _ToolButton(
                          icon: Icons.edit_note,
                          label: "Edit",
                          selected: selectedTool == "Edit",
                          onTap: () => setState(() => selectedTool = "Edit"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Properties
                    const Text(
                      'Properties',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: objectType,
                            decoration: const InputDecoration(
                              labelText: "Object Type",
                              border: OutlineInputBorder(),
                            ),
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
                                  decoration: const InputDecoration(
                                    labelText: "Width (cm)",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
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
                                  decoration: const InputDecoration(
                                    labelText: "Height (cm)",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
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

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF4F8CFF) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? const Color(0xFF4F8CFF) : Colors.black54, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF4F8CFF) : Colors.black54,
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
      size.width * 0.3, size.height * 0.2,
      size.width * 0.7, size.height * 0.8,
      size.width - 20, 40,
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

// Selection painter for selected obstacle
class _SelectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4F8CFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Draw rectangle border
    canvas.drawRect(Offset.zero & size, paint);

    // Draw handles (circles at corners)
    final handlePaint = Paint()..color = const Color(0xFF4F8CFF);
    const handleRadius = 5.0;
    canvas.drawCircle(const Offset(0, 0), handleRadius, handlePaint);
    canvas.drawCircle(Offset(size.width, 0), handleRadius, handlePaint);
    canvas.drawCircle(Offset(0, size.height), handleRadius, handlePaint);
    canvas.drawCircle(Offset(size.width, size.height), handleRadius, handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}