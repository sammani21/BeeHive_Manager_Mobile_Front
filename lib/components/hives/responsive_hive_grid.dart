// components/hives/responsive_hive_grid.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/hive_model.dart';
import 'hive_card.dart';

class ResponsiveHiveGrid extends StatelessWidget {
  final List<Hive> hives;
  final Function(Hive) onHiveTap;

  const ResponsiveHiveGrid({
    super.key,
    required this.hives,
    required this.onHiveTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return isDesktop
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: hives.length,
            itemBuilder: (context, index) => HiveCard(
              hive: hives[index],
              onTap: () => onHiveTap(hives[index]),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hives.length,
            itemBuilder: (context, index) => HiveCard(
              hive: hives[index],
              onTap: () => onHiveTap(hives[index]),
            ),
          );
  }
}