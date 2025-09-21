// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_log/models/beekeeper_model.dart';
import 'package:pass_log/models/product_model.dart';
import 'package:pass_log/models/hive_model.dart';
import '../constants.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<Beekeeper?> fetchBeekeeperData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/beekeepers/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Beekeeper.fromJson(data['data']);
      } else {
        throw Exception('Failed to load beekeeper data');
      }
    } catch (error) {
      throw Exception('Error fetching beekeeper data: $error');
    }
  }

  static Future<List<Hive>> fetchHives() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/hive/my-hives'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Hive.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hives');
      }
    } catch (error) {
      throw Exception('Error fetching hives: $error');
    }
  }

  static Future<List<Product>> fetchProducts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/product/my-products'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productList = data['data'];
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      throw Exception('Error fetching products: $error');
    }
  }
}