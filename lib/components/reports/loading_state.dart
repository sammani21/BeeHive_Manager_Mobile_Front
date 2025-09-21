// components/reports/loading_state.dart
import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({super.key, this.message = 'Loading report data...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}