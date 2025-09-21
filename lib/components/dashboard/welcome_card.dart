// welcome_card.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/beekeeper_model.dart';
import '../../constants.dart';

class WelcomeCard extends StatelessWidget {
  final Beekeeper? beekeeper;
  final int hiveCount;
  final int productCount;

  const WelcomeCard({
    super.key,
    required this.beekeeper,
    required this.hiveCount,
    required this.productCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.amber[800],
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back,",
            style: TextStyle(
              fontSize: 18,
              color: Colors.amber.shade100,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            beekeeper?.name ?? "Beekeeper",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You have $hiveCount hives and $productCount products",
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade100,
            ),
          ),
        ],
      ),
    );
  }
}