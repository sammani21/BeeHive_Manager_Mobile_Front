// components/reports/product_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pass_log/models/product_model.dart';
import 'package:pass_log/utils/report_utils.dart';

import 'empty_state.dart';

class ProductReport extends StatelessWidget {
  final List<Product> products;

  const ProductReport({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory,
        message: 'No product data available',
        subtitle: 'Try adding data or check your connection',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Inventory Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of your harvested products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.amber[50]!,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Harvest Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: products.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(Text(product.productName)),
                          DataCell(Text(product.productType)),
                          DataCell(Text('${product.quantity} ${product.unit}')),
                          DataCell(Text(DateFormat('yyyy-MM-dd').format(product.harvestDate))),
                          DataCell(
                            Chip(
                              label: Text(
                                ReportUtils.getProductStatus(product.harvestDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: ReportUtils.getProductStatusColor(product.harvestDate),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}