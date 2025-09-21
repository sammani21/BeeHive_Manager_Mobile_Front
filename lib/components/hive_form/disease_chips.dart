// components/hive_form/disease_chips.dart
import 'package:flutter/material.dart';

class DiseaseChips extends StatelessWidget {
  final List<String> selectedDiseaseSigns;
  final Function(String) onRemoveDisease;

  const DiseaseChips({
    super.key,
    required this.selectedDiseaseSigns,
    required this.onRemoveDisease,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDiseaseSigns.isEmpty) {
      return const Text('No disease signs selected', style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedDiseaseSigns
          .map((sign) => Chip(
                label: Text(sign),
                backgroundColor: Colors.amber[50],
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemoveDisease(sign),
              ))
          .toList(),
    );
  }
}