// services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_log/models/hive_model.dart';
import 'package:pass_log/models/product_model.dart';
import '../constants.dart';

class ReportService {
  static Future<List<Hive>> fetchHives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/hive/my-hives'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Hive.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hives: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching hives: $error');
    }
  }

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
}