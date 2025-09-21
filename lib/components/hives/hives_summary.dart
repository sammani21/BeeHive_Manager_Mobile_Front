// components/hives/hives_summary.dart
import 'package:flutter/material.dart';

class HivesSummary extends StatelessWidget {
  final Map<String, dynamic> stats;

  const HivesSummary({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            title: 'Total Hives',
            value: stats['total'].toString(),
            icon: Icons.hive_outlined,
            color: Colors.blue,
          ),
          _SummaryItem(
            title: 'Avg Strength',
            value: stats['total'] > 0 ? stats['averageStrength'].toStringAsFixed(1) : '0',
            icon: Icons.assessment_outlined,
            color: Colors.green,
          ),
          _SummaryItem(
            title: 'Strong Hives',
            value: stats['strongHives'].toString(),
            icon: Icons.thumb_up_outlined,
            color: Colors.green,
          ),
          _SummaryItem(
            title: 'Weak Hives',
            value: stats['weakHives'].toString(),
            icon: Icons.thumb_down_outlined,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}