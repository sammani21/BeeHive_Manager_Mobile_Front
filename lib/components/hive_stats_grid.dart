// hive_stats_grid.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/hive_model.dart';
import 'stat_card.dart';

class HiveStatsGrid extends StatelessWidget {
  final List<Hive> hives;

  const HiveStatsGrid({super.key, required this.hives});

  @override
  Widget build(BuildContext context) {
    final int totalHives = hives.length;
    final double avgStrength = hives.isEmpty
        ? 0
        : hives.map((hive) => hive.strength).reduce((a, b) => a + b) /
            hives.length;

    final Map<String, int> hivesByType = {};
    for (final hive in hives) {
      hivesByType[hive.hiveType] = (hivesByType[hive.hiveType] ?? 0) + 1;
    }

    String mostCommonType = "None";
    int maxCount = 0;
    hivesByType.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonType = type;
      }
    });

    final int strongestHive = hives.isEmpty
        ? 0
        : hives.map((hive) => hive.strength).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hive Overview",
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
                  title: 'Total Hives',
                  value: totalHives.toString(),
                  icon: Icons.hive,
                ),
                StatCard(
                  title: 'Average Strength',
                  value: avgStrength.toStringAsFixed(1),
                  icon: Icons.auto_graph,
                ),
                StatCard(
                  title: 'Most Common Type',
                  value: mostCommonType,
                  icon: Icons.category,
                ),
                StatCard(
                  title: 'Strongest Hive',
                  value: hives.isEmpty ? 'N/A' : '$strongestHive/10',
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