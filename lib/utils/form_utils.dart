// utils/form_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormUtils {
  static Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  static const Color primaryColor = Color(0xFFFFB22C);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF343A40);
  static const Color secondaryTextColor = Color(0xFF6C757D);
}