// components/recommendations/loading_recommendations.dart
import 'package:flutter/material.dart';

class LoadingRecommendations extends StatelessWidget {
  const LoadingRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
      ),
    );
  }
}