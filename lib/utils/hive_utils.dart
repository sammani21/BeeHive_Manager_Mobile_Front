// utils/hive_utils.dart
import 'package:pass_log/models/hive_model.dart';

class HiveUtils {
  static Map<String, dynamic> calculateHiveStats(List<Hive> hives) {
    if (hives.isEmpty) {
      return {
        'total': 0,
        'averageStrength': 0.0,
        'strongHives': 0,
        'weakHives': 0,
      };
    }

    double totalStrength = hives.fold(0, (sum, hive) => sum + hive.strength);
    double averageStrength = totalStrength / hives.length;
    int strongHives = hives.where((hive) => hive.strength > 7).length;
    int weakHives = hives.where((hive) => hive.strength <= 4).length;

    return {
      'total': hives.length,
      'averageStrength': averageStrength,
      'strongHives': strongHives,
      'weakHives': weakHives,
    };
  }
}