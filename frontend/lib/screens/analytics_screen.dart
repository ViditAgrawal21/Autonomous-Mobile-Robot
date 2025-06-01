import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final bool isDarkMode;
  const AnalyticsScreen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    // Example analytics data
    final List<Map<String, String>> analyticsData = [
      {'title': 'Total AGVs', 'value': '12'},
      {'title': 'Active AGVs', 'value': '9'},
      {'title': 'Avg Tasks', 'value': '134'},
      {'title': 'Pending Tasks', 'value': '5'},
    ];

    // Example values for pie chart
    final double distanceTravelled = 78.0; // meters
    final double distanceGoal = 100.0; // meters
    final double batteryLevel = 0.85; // 85%
    final double timeConsumed = 0.65; // 65% of expected time

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Overview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                // Pie Chart Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "AGV Performance",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF4F8CFF),
                                value: distanceTravelled,
                                title: '${distanceTravelled.toInt()}m',
                                radius: 48,
                                titleStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                badgeWidget: _PieBadge(
                                  icon: Icons.alt_route,
                                  label: "Distance",
                                  color: const Color(0xFF4F8CFF),
                                ),
                                badgePositionPercentageOffset: 1.65,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF2ECC71),
                                value: batteryLevel * 100,
                                title: '${(batteryLevel * 100).toInt()}%',
                                radius: 42,
                                titleStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                badgeWidget: _PieBadge(
                                  icon: Icons.battery_full,
                                  label: "Battery",
                                  color: const Color(0xFF2ECC71),
                                ),
                                badgePositionPercentageOffset: 1.15,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFFFC300),
                                value: timeConsumed * 100,
                                title: '${(timeConsumed * 100).toInt()}%',
                                radius: 38,
                                titleStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                badgeWidget: _PieBadge(
                                  icon: Icons.timer,
                                  label: "Time",
                                  color: const Color(0xFFFFC300),
                                ),
                                badgePositionPercentageOffset: 1.65,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _LegendDot(
                            color: const Color(0xFF4F8CFF),
                            label: "Distance",
                          ),
                          _LegendDot(
                            color: const Color(0xFF2ECC71),
                            label: "Battery",
                          ),
                          _LegendDot(
                            color: const Color(0xFFFFC300),
                            label: "Time",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: analyticsData.map((item) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['value']!,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F8CFF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Add more analytics widgets or charts here if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PieBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 16,
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
