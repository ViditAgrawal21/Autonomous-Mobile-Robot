import 'package:flutter/material.dart';
import 'screens/connect_screen.dart';
import 'screens/map_screen.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const AGVFleetApp());
}

class AGVFleetApp extends StatelessWidget {
  const AGVFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/map': (context) => const MapScreen(), 
        // '/connect': (context) => const ConnectScreen(),
        
      },
      title: 'AGV Fleet Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Professional blue theme
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ConnectScreen(), // Start directly with connection screen
      debugShowCheckedModeBanner: false,
    );
  }
}