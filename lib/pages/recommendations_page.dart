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
    final hiveData = json['hiveId'];

    return Recommendation(
      id: json['_id'] ?? 'Unknown ID',
      hiveId: hiveData is Map
          ? (hiveData['_id'] ?? 'Unknown HiveId')
          : (hiveData ?? 'Unknown HiveId'),
      hiveName: hiveData is Map
          ? (hiveData['hiveName'] ?? 'Unknown Hive')
          : 'Unknown Hive',
      location: hiveData is Map
          ? (hiveData['location'] ?? 'Unknown Location')
          : 'Unknown Location',
      recommendations: json['recommendations'] ?? 'No recommendations available',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
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
          recommendations = recommendationList
              .map((json) => Recommendation.fromJson(json))
              .toList();
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
  title: const Text(
    'Hive Recommendations',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.amber[800],
  foregroundColor: Colors.white, 
),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : recommendations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = recommendations[index];
                      return _buildRecommendationCard(recommendation);
                    },
                  ),
      ),
    );
  }

  Widget _buildRecommendationCard(Recommendation rec) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hive name + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hive, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      rec.hiveName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    "${rec.date.day}/${rec.date.month}/${rec.date.year}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.amber[100],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  rec.location,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rec.recommendations,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No recommendations available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
