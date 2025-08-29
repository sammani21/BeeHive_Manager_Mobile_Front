// pages/recommendations_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Recommendation {
  final String id;
  final String hiveId;
  final String hiveName;
  final String location;
  final String recommendations;
  final DateTime date;

  Recommendation({
    required this.id,
    required this.hiveId,
    required this.hiveName,
    required this.location,
    required this.recommendations,
    required this.date,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['_id'],
      hiveId: json['hiveId'] is Map ? json['hiveId']['_id'] : json['hiveId'],
      hiveName: json['hiveId'] is Map ? json['hiveId']['hiveName'] ?? 'Unknown Hive' : 'Unknown Hive',
      location: json['hiveId'] is Map ? json['hiveId']['location'] ?? 'Unknown Location' : 'Unknown Location',
      recommendations: json['recommendations'],
      date: DateTime.parse(json['date']),
    );
  }
}

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  List<Recommendation> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/recommendations/my-recommendations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> recommendationList = data['data'];
        setState(() {
          recommendations = recommendationList.map((json) => Recommendation.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (error) {
      print('Error fetching recommendations: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Recommendations'),
        backgroundColor: Colors.amber[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendations.isEmpty
              ? const Center(
                  child: Text(
                    'No recommendations available',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  recommendation.hiveName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '${recommendation.date.day}/${recommendation.date.month}/${recommendation.date.year}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recommendation.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              recommendation.recommendations,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}