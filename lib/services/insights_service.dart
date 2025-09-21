// services/insights_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_log/models/product_model.dart';
import '../constants.dart';

class InsightsService {
  static Future<List<Product>> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/product/my-products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productList = data['data'];
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching products: $error');
    }
  }

  static Future<http.Response> downloadReport(int month, int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse(
        '$apiBaseUrl/product/download-report?month=$month&year=$year',
      );

      return await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );
    } catch (error) {
      throw Exception('Error downloading report: $error');
    }
  }
}