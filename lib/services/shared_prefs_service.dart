// shared_prefs_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_log/models/beekeeper_model.dart';

class SharedPrefsService {
  static Future<void> saveBeekeeper(Beekeeper beekeeper) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('beekeeper', json.encode(beekeeper.toJson()));
  }

  static Future<Beekeeper?> getBeekeeper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? beekeeperJson = prefs.getString('beekeeper');
      
      if (beekeeperJson != null) {
        final data = jsonDecode(beekeeperJson);
        return Beekeeper.fromJson(data);
      }
      return null;
    } catch (error) {
      throw Exception('Error getting beekeeper from shared preferences: $error');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}