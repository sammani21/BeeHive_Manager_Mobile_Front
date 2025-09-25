// utils/report_utils.dart
import 'package:flutter/material.dart';

import 'package:pass_log/models/hive_model.dart';
import 'package:pass_log/models/product_model.dart';

class ReportUtils {
  static Color getStrengthColor(int strength) {
    if (strength >= 8) return Colors.green;
    if (strength >= 5) return Colors.orange;
    return Colors.red;
  }

  static String getHiveStatus(int strength) {
    if (strength >= 8) return 'Strong';
    if (strength >= 5) return 'Moderate';
    return 'Weak';
  }

  static Color getStatusColor(int strength) {
    if (strength >= 8) return Colors.green;
    if (strength >= 5) return Colors.orange;
    return Colors.red;
  }

  static String getProductStatus(DateTime harvestDate) {
    final now = DateTime.now();
    final difference = now.difference(harvestDate).inDays;
    
    if (difference < 30) return 'Fresh';
    if (difference < 90) return 'Aging';
    return 'Mature';
  }

  static Color getProductStatusColor(DateTime harvestDate) {
    final now = DateTime.now();
    final difference = now.difference(harvestDate).inDays;
    
    if (difference < 30) return Colors.green;
    if (difference < 90) return Colors.orange;
    return Colors.purple;
  }

  static Map<String, dynamic> calculateHiveStats(List<Hive> hives) {
    if (hives.isEmpty) {
      return {
        'total': 0,
        'avgStrength': 0.0,
        'strongHives': 0,
      };
    }

    final double avgStrength = hives.map((h) => h.strength).reduce((a, b) => a + b) / hives.length;
    final int strongHives = hives.where((hive) => hive.strength >= 7).length;
    
    return {
      'total': hives.length,
      'avgStrength': avgStrength,
      'strongHives': strongHives,
    };
  }

  static Map<String, dynamic> calculateProductStats(List<Product> products) {
    if (products.isEmpty) {
      return {
        'total': 0,
        'totalWeight': 0.0,
        'avgWeight': 0.0,
      };
    }

    final double totalWeight = products.map((p) => p.quantity).reduce((a, b) => a + b);
    final double avgWeight = totalWeight / products.length;
    
    return {
      'total': products.length,
      'totalWeight': totalWeight,
      'avgWeight': avgWeight,
    };
  }
}