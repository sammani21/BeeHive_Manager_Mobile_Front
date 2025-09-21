// components/reports/summary_row.dart
import 'package:flutter/material.dart';
import 'summary_card.dart';

class SummaryRow extends StatelessWidget {
  final List<Map<String, dynamic>> cards;

  const SummaryRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: cards.map((card) {
          return Expanded(
            child: SummaryCard(
              title: card['title'],
              value: card['value'],
              icon: card['icon'],
              color: card['color'],
            ),
          );
        }).toList(),
      ),
    );
  }
}