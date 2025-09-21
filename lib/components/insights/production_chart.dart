// components/insights/production_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pass_log/models/product_model.dart';

import '../../utils/insights_utils.dart';

class ProductionChart extends StatelessWidget {
  final List<Product> products;

  const ProductionChart({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final productionByType = InsightsUtils.getProductionByType(products);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: productionByType.isNotEmpty ? productionByType.values.reduce((a, b) => a > b ? a : b) * 1.2 : 100,
        barGroups: productionByType.entries.map((entry) {
          return BarChartGroupData(
            x: productionByType.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.amber,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= productionByType.keys.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    productionByType.keys.toList()[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}