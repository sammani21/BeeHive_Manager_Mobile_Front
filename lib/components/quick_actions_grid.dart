// quick_actions_grid.dart
import 'package:flutter/material.dart';
import 'quick_action_button.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final int crossAxisCount = constraints.maxWidth > 600 ? 6 : 3;
            final double childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 0.9;
            
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
                QuickActionButton(
                  icon: Icons.task,
                  label: "Tasks",
                  onTap: () => Navigator.pushNamed(context, '/todo'),
                ),
                QuickActionButton(
                  icon: Icons.bar_chart,
                  label: "Reports",
                  onTap: () => Navigator.pushNamed(context, '/reports'),
                ),
                QuickActionButton(
                  icon: Icons.lightbulb_outline,
                  label: "Recommendations",
                  onTap: () => Navigator.pushNamed(context, '/recommendations'),
                ),
                QuickActionButton(
                  icon: Icons.hive,
                  label: "My Hives",
                  onTap: () => Navigator.pushNamed(context, '/hives'),
                ),
                QuickActionButton(
                  icon: Icons.analytics,
                  label: "Insights",
                  onTap: () => Navigator.pushNamed(context, '/insights'),
                ),
                QuickActionButton(
                  icon: Icons.notifications,
                  label: "Notifications",
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}