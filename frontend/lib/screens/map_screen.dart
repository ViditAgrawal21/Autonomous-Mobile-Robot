import 'package:flutter/material.dart';
import '../widgets/live_map.dart';
import '../widgets/tools_panel.dart';
import '../widgets/connection_status.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AGV Control'),
        actions: [ConnectionStatus(isConnected: true)],
      ),
      body: Stack(
        children: const [
          LiveMap(),
          Positioned(bottom: 20, right: 20, child: ToolsPanel()),
        ],
      ),
    );
  }
}