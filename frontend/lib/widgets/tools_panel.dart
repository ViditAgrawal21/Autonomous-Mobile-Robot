import 'package:flutter/material.dart';

class ToolsPanel extends StatelessWidget {
  final void Function(String tool)? onToolSelected;

  const ToolsPanel({Key? key, this.onToolSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'icon': Icons.map, 'label': 'Map'},
      {'icon': Icons.analytics, 'label': 'Analytics'},
      {'icon': Icons.settings, 'label': 'Settings'},
      {'icon': Icons.info, 'label': 'Info'},
    ];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: tools.map((tool) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(tool['icon'] as IconData),
                  tooltip: tool['label'] as String,
                  onPressed: () {
                    if (onToolSelected != null) {
                      onToolSelected!(tool['label'] as String);
                    }
                  },
                ),
                Text(
                  tool['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}