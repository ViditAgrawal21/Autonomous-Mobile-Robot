import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<List<Map<String, dynamic>>> analyticsFuture;

  @override
  void initState() {
    super.initState();
    analyticsFuture = fetchAnalyticsFromRos();
  }

  Future<List<Map<String, dynamic>>> fetchAnalyticsFromRos() async {
    // Replace with your ROS backend endpoint
    const String url = 'http://localhost:5000/api/analytics';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch analytics from ROS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No analytics data available.'));
          }
          final analyticsData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: analyticsData.length,
              itemBuilder: (context, index) {
                final item = analyticsData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.analytics),
                    title: Text(item['title'].toString()),
                    trailing: Text(
                      item['value'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}