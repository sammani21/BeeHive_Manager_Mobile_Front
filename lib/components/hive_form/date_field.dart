// components/hive_form/date_field.dart
import 'package:flutter/material.dart';
import 'package:pass_log/utils/form_utils.dart';

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;

  const DateField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: const Icon(Icons.calendar_today),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormUtils.primaryColor, width: 2),
        ),
      ),
      readOnly: true,
      onTap: () => FormUtils.selectDate(context, controller),
    );
  }
}