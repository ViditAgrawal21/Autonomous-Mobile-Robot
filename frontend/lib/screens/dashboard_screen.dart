import 'package:flutter/material.dart';
import 'analytics_screen.dart';
import 'control_page.dart';

class DashBoard_Screen extends StatefulWidget {
  final bool isDarkMode;
  const DashBoard_Screen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<DashBoard_Screen> createState() => _DashBoard_ScreenState();
}

class _DashBoard_ScreenState extends State<DashBoard_Screen> {
  int _selectedIndex = 0;

  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4F8CFF),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        cardColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF4F8CFF)),
      );

  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4F8CFF),
        scaffoldBackgroundColor: const Color(0xFF181A20),
        cardColor: const Color(0xFF23242B),
        iconTheme: const IconThemeData(color: Color(0xFF4F8CFF)),
      );

  void _onBottomNavTap(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnalyticsScreen(isDarkMode: widget.isDarkMode)),
      );
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDarkMode ? _darkTheme : _lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            'AGV Dashboard',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
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
                              const SizedBox(width: 8),
                              // Removed dark mode toggle button from dashboard
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // AGV Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF23242B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF23242B)
                                    : const Color(0xFFEDF2FF),
                              ),
                              child: Icon(
                                Icons.memory,
                                color: theme.primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AGV-Lab-01',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '192.168.1.105',
                                    style: TextStyle(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Active',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Battery',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '85%',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Speed',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '0.5 m/s',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mode',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Manual',
                                            style: TextStyle(
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ActionButton(
                            icon: Icons.play_circle_fill,
                            label: 'Start',
                            color: const Color(0xFF2ECC71),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ControlPage(isDarkMode: widget.isDarkMode)),
                              );
                            },
                            isDark: widget.isDarkMode,
                          ),
                          _ActionButton(
                            icon: Icons.stop_circle,
                            label: 'Stop',
                            color: const Color(0xFFFF6B6B),
                            onTap: () {},
                            isDark: widget.isDarkMode,
                          ),
                          _ActionButton(
                            icon: Icons.warning_amber_rounded,
                            label: 'E-Stop',
                            color: const Color(0xFFFFC300),
                            onTap: () {},
                            isDark: widget.isDarkMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Navigation',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        children: [
                          _NavButton(
                            icon: Icons.map,
                            label: 'Create Map',
                            color: const Color(0xFF4F8CFF),
                            onTap: () {},
                            isDark: widget.isDarkMode,
                          ),
                          _NavButton(
                            icon: Icons.edit,
                            label: 'Edit Map',
                            color: const Color(0xFF6F6CFF),
                            onTap: () {},
                            isDark: widget.isDarkMode,
                          ),
                          _NavButton(
                            icon: Icons.home,
                            label: 'Home',
                            color: const Color(0xFFB388FF),
                            onTap: () {},
                            isDark: widget.isDarkMode,
                          ),
                          _NavButton(
                            icon: Icons.settings,
                            label: 'Settings',
                            color: const Color(0xFF64B5F6),
                            onTap: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            isDark: widget.isDarkMode,
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
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: widget.isDarkMode ? Colors.red : const Color(0xFF4F8CFF),
            unselectedItemColor: widget.isDarkMode ? Colors.red : Colors.black38,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onBottomNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.analytics), label: ''),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 13,
                  backgroundColor: Color(0xFF4F8CFF),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF23242B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23242B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}