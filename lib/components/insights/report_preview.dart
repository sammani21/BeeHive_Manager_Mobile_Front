// components/insights/report_preview.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pass_log/models/product_model.dart';
import 'package:pass_log/utils/insights_utils.dart';

import 'production_chart.dart';

class ReportPreview extends StatelessWidget {
  final List<Product> products;

  const ReportPreview({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final stats = InsightsUtils.calculateStats(products);
    final marketingData = InsightsUtils.generateMarketingTip(products);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'PRODUCTION REPORT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const Divider(thickness: 2),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Production Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(height: 12),
          
          if (products.isNotEmpty) ..._buildSummaryCards(stats, marketingData),
          
          const SizedBox(height: 24),
          
          Text(
            'Production by Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 200,
            child: products.isNotEmpty 
                ? ProductionChart(products: products)
                : const Center(
                    child: Text('No production data available'),
                  ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Production Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(height: 12),
          
          ..._buildProductionDetails(),
          
          const SizedBox(height: 24),
          
          const Divider(thickness: 2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Generated on: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                'FarmInsights Pro',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSummaryCards(Map<String, dynamic> stats, Map<String, dynamic> marketingData) {
    String monthName = marketingData['peakMonth'] != null 
        ? DateFormat('MMMM').format(DateTime(2023, marketingData['peakMonth'], 1))
        : "N/A";
    
    return [
      Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Production',
              '${stats['totalProduction'].toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}',
              Icons.agriculture,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Product Types',
              stats['productTypes'].toString(),
              Icons.category,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Peak Production Month',
              monthName,
              Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Products Listed',
              stats['totalProducts'].toString(),
              Icons.list,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductionDetails() {
    if (products.isEmpty) {
      return [const Text('No production data available')];
    }
    
    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Quantity'), numeric: true),
            DataColumn(label: Text('Harvest Date')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.productName)),
                DataCell(Text(product.productType)),
                DataCell(Text('${product.quantity} ${product.unit}')),
                DataCell(Text(DateFormat('MMM d, yyyy').format(product.harvestDate))),
              ],
            );
          }).toList(),
        ),
      ),
    ];
  }
}