// components/recommendations/empty_recommendations.dart
import 'package:flutter/material.dart';

class EmptyRecommendations extends StatelessWidget {
  const EmptyRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No recommendations available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}