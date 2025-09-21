// production_stats_grid.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/product_model.dart';
import 'stat_card.dart';

class ProductionStatsGrid extends StatelessWidget {
  final List<Product> products;

  const ProductionStatsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final double totalProduction =
        products.fold(0, (sum, product) => sum + product.quantity);
    final int productTypes = products.map((e) => e.productType).toSet().length;

    final Map<String, double> productionByType = {};
    for (final product in products) {
      productionByType[product.productType] =
          (productionByType[product.productType] ?? 0) + product.quantity;
    }

    String mostProducedType = "None";
    double maxProduction = 0;
    productionByType.forEach((type, production) {
      if (production > maxProduction) {
        maxProduction = production;
        mostProducedType = type;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Production Overview",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            final double childAspectRatio = constraints.maxWidth > 600 ? 1.8 : 1.6;
            
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              children: [
                StatCard(
                  title: 'Total Products',
                  value: products.length.toString(),
                  icon: Icons.inventory,
                ),
                StatCard(
                  title: 'Product Types',
                  value: productTypes.toString(),
                  icon: Icons.category,
                ),
                StatCard(
                  title: 'Total Production',
                  value: '${totalProduction.toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}',
                  icon: Icons.agriculture,
                ),
                StatCard(
                  title: 'Most Produced',
                  value: mostProducedType,
                  icon: Icons.emoji_events,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}