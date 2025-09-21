// components/reports/report_selector.dart
import 'package:flutter/material.dart';

class ReportSelector extends StatelessWidget {
  final String selectedReport;
  final List<String> reportTypes;
  final Function(String) onReportChanged;

  const ReportSelector({
    super.key,
    required this.selectedReport,
    required this.reportTypes,
    required this.onReportChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedReport,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          elevation: 8,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: reportTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => onReportChanged(newValue!),
        ),
      ),
    );
  }
}