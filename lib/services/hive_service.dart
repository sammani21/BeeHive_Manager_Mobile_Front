// services/hive_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class HiveService {
  static Future<Map<String, dynamic>> saveHive({
    required Map<String, dynamic> hiveData,
    required String? hiveId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication expired. Please log in again.');
      }

      final String url = hiveId != null
          ? '$apiBaseUrl/hive/$hiveId'
          : '$apiBaseUrl/hive';

      final response = hiveId != null
          ? await http.put(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(hiveData),
            )
          : await http.post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(hiveData),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save hive');
      }
    } catch (error) {
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }
}