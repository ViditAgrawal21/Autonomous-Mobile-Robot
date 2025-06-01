import 'package:flutter/material.dart';
import 'screens/login_screen_static.dart';
import 'screens/connect_screen.dart';
import 'screens/control_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  String themeColor = "Blue";

  ThemeData get _lightTheme {
    Color primary = _getPrimaryColor();
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      cardColor: Colors.white,
      iconTheme: IconThemeData(color: primary),
      colorScheme: ColorScheme.light(primary: primary),
    );
  }

  ThemeData get _darkTheme {
    Color primary = _getPrimaryColor();
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF181A20),
      cardColor: const Color(0xFF23242B),
      iconTheme: IconThemeData(color: primary),
      colorScheme: ColorScheme.dark(primary: primary),
    );
  }

  Color _getPrimaryColor() {
    switch (themeColor) {
      case "Purple":
        return const Color(0xFFB388FF);
      case "Green":
        return const Color(0xFF4FE6A5);
      default:
        return const Color(0xFF4F8CFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGV Control System',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme : _lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(isDarkMode: isDarkMode),
        '/connect': (context) => ConnectScreen(isDarkMode: isDarkMode),
        '/dashboard': (context) => DashBoard_Screen(isDarkMode: isDarkMode),
        '/control': (context) => ControlPage(isDarkMode: isDarkMode),
        '/analytics': (context) => AnalyticsScreen(isDarkMode: isDarkMode),
        '/map': (context) => MapPage(isDarkMode: isDarkMode),
        '/settings': (context) => SettingsScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: (val) {
                setState(() {
                  isDarkMode = val;
                });
              },
              themeColor: themeColor,
              onColorChanged: (color) {
                setState(() {
                  themeColor = color;
                });
              },
            ),
      },
      home: LoginScreen(isDarkMode: isDarkMode),
    );
  }
}