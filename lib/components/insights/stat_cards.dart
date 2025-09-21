// components/insights/stat_cards.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/product_model.dart';

import '../../utils/insights_utils.dart';

class StatCards extends StatelessWidget {
  final List<Product> products;

  const StatCards({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final stats = InsightsUtils.calculateStats(products);
    
    return Column(
      children: [
        _buildStatItem('Total Products', stats['totalProducts'].toString(), Icons.inventory),
        const SizedBox(height: 8),
        _buildStatItem('Product Types', stats['productTypes'].toString(), Icons.category),
        const SizedBox(height: 8),
        _buildStatItem(
          'Total Production', 
          '${stats['totalProduction'].toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}', 
          Icons.agriculture
        ),
        const SizedBox(height: 8),
        _buildStatItem('Most Produced', stats['mostProducedType'], Icons.emoji_events),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber[700]),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[700])),
      contentPadding: EdgeInsets.zero,
    );
  }
}