// services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_log/models/recommendation_model.dart';
import '../constants.dart';

class RecommendationService {
  static Future<List<Recommendation>> fetchRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/recommendations/my-recommendations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recommendationList = data['data'];
        return recommendationList
            .map((json) => Recommendation.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching recommendations: $error');
    }
  }
}