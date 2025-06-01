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
  bool isDarkMode = true;
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

  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF181A20),
    iconTheme: const IconThemeData(color: Colors.redAccent),
    colorScheme: const ColorScheme.dark(
      primary: Colors.redAccent,
      secondary: Colors.redAccent,
      background: Colors.black,
      surface: Color(0xFF181A20),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.redAccent),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(Colors.redAccent),
      trackColor: MaterialStatePropertyAll(Color(0x44FF1744)),
    ),
  );

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
        '/login': (context) => LoginScreen(),
        '/connect': (context) => ConnectScreen(),
        '/dashboard': (context) => DashBoard_Screen(),
        '/control': (context) => ControlPage(),
        '/analytics': (context) => AnalyticsScreen(),
        '/map': (context) => MapPage(),
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
      home: LoginScreen(),
    );
  }
}
