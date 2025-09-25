// components/insights/production_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pass_log/models/product_model.dart';
import '../../utils/insights_utils.dart';

class ProductionChart extends StatelessWidget {
  final List<Product> products;

  const ProductionChart({super.key, required this.products});

  // Group products by month and year using harvestDate
  Map<DateTime, List<Product>> _groupProductsByMonth(List<Product> products) {
    final Map<DateTime, List<Product>> monthlyProducts = {};
    
    for (final product in products) {
      // Use harvestDate as the production date
      final monthStart = DateTime(product.harvestDate.year, product.harvestDate.month);
      
      if (!monthlyProducts.containsKey(monthStart)) {
        monthlyProducts[monthStart] = [];
      }
      monthlyProducts[monthStart]!.add(product);
    }
    
    return monthlyProducts;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyProducts = _groupProductsByMonth(products);
    
    if (monthlyProducts.isEmpty) {
      return const Center(
        child: Text(
          'No production data available',
          style: TextStyle(fontSize: 12),
        ),
      );
    }

    // For small card layout, use a simplified chart without pagination
    return CompactMonthlyChart(monthlyProducts: monthlyProducts);
  }
}

class CompactMonthlyChart extends StatefulWidget {
  final Map<DateTime, List<Product>> monthlyProducts;

  const CompactMonthlyChart({super.key, required this.monthlyProducts});

  @override
  State<CompactMonthlyChart> createState() => _CompactMonthlyChartState();
}

class _CompactMonthlyChartState extends State<CompactMonthlyChart> {
  int _currentMonthIndex = 0;
  late List<DateTime> _sortedMonths;

  @override
  void initState() {
    super.initState();
    _sortedMonths = widget.monthlyProducts.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    // Start with the most recent month
    _currentMonthIndex = _sortedMonths.length - 1;
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonthIndex < _sortedMonths.length - 1) {
        _currentMonthIndex++;
      }
    });
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonthIndex > 0) {
        _currentMonthIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = _sortedMonths[_currentMonthIndex];
    final monthlyProducts = widget.monthlyProducts[currentMonth]!;
    final productionByType = InsightsUtils.getProductionByType(monthlyProducts);

    if (productionByType.isEmpty) {
      return Center(
        child: Text(
          'No data for ${_getMonthName(currentMonth.month)}',
          style: const TextStyle(fontSize: 12),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Compact month selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 16),
              onPressed: _previousMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
            Text(
              _getMonthYearString(currentMonth),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 16),
              onPressed: _nextMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Page indicator
        Text(
          '${_currentMonthIndex + 1}/${_sortedMonths.length}',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        
        // Compact chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: productionByType.isNotEmpty 
                    ? productionByType.values.reduce((a, b) => a > b ? a : b) * 1.2 
                    : 100,
                minY: 0,
                barGroups: productionByType.entries.map((entry) {
                  return BarChartGroupData(
                    x: productionByType.keys.toList().indexOf(entry.key),
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: _getColorForIndex(productionByType.keys.toList().indexOf(entry.key)),
                        width: 12,
                        borderRadius: BorderRadius.circular(2),
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
                        final label = productionByType.keys.toList()[value.toInt()];
                        // Use abbreviated labels for small space
                        final abbreviatedLabel = _abbreviateLabel(label);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            abbreviatedLabel,
                            style: const TextStyle(fontSize: 8),
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
                      interval: _calculateInterval(productionByType.values.reduce((a, b) => a > b ? a : b)),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 8),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(productionByType.values.reduce((a, b) => a > b ? a : b)),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
        
        // Compact summary
        const SizedBox(height: 4),
        _buildCompactSummary(productionByType, monthlyProducts),
      ],
    );
  }

  String _getMonthYearString(DateTime month) {
    final monthName = _getMonthName(month.month);
    return '${monthName.substring(0, 3)} ${month.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  String _abbreviateLabel(String label) {
    if (label.length <= 8) return label;
    return label.substring(0, 7) + '..';
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 100) return 50;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    return 500;
  }

  Widget _buildCompactSummary(Map<String, double> productionByType, List<Product> products) {
    final totalQuantity = products.fold(0.0, (sum, product) => sum + product.quantity);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCompactStatItem('Items', products.length.toString()),
        _buildCompactStatItem('Qty', totalQuantity.toStringAsFixed(0)),
        _buildCompactStatItem('Types', productionByType.keys.length.toString()),
      ],
    );
  }

  Widget _buildCompactStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.amber,
      const Color.fromARGB(249, 245, 212, 66),
      Colors.green.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
    ];
    return colors[index % colors.length];
  }
}