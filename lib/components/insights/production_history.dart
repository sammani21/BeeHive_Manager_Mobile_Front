// components/insights/production_history.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pass_log/models/product_model.dart';

class ProductionHistory extends StatelessWidget {
  final List<Product> products;

  const ProductionHistory({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Production History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        products.isNotEmpty
            ? Column(
                children: products.map((product) => _buildProductItem(product)).toList(),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No products yet'),
                ),
              ),
      ],
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.agriculture, color: Colors.amber[700]),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${product.quantity} ${product.unit} - ${DateFormat('MMM d, yyyy').format(product.harvestDate)}',
        ),
        trailing: Chip(
          label: Text(
            product.productType,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: Colors.amber[700],
        ),
      ),
    );
  }
}