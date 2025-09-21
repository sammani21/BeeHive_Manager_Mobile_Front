// components/insights/marketing_tip_card.dart
import 'package:flutter/material.dart';

class MarketingTipCard extends StatelessWidget {
  final String marketingTip;

  const MarketingTipCard({super.key, required this.marketingTip});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'Marketing Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(marketingTip),
          ],
        ),
      ),
    );
  }
}