// components/hive_form/treatment_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pass_log/models/hive_model.dart';

class TreatmentList extends StatelessWidget {
  final List<Treatment> treatments;
  final Function(int) onRemoveTreatment;

  const TreatmentList({
    super.key,
    required this.treatments,
    required this.onRemoveTreatment,
  });

  @override
  Widget build(BuildContext context) {
    if (treatments.isEmpty) {
      return const Text('No treatments added', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: treatments.asMap().entries.map((entry) {
        final index = entry.key;
        final treatment = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.amber[50],
          child: ListTile(
            title: Text(treatment.treatmentType),
            subtitle: Text(
              '${DateFormat('yyyy-MM-dd').format(treatment.applicationDate)} - ${treatment.notes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => onRemoveTreatment(index),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }
}