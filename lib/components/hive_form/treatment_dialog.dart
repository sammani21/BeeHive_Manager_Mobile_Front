// components/hive_form/treatment_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pass_log/models/hive_model.dart';
import 'package:pass_log/utils/form_utils.dart';

class TreatmentDialog extends StatefulWidget {
  final Function(Treatment) onAddTreatment;

  const TreatmentDialog({super.key, required this.onAddTreatment});

  @override
  State<TreatmentDialog> createState() => _TreatmentDialogState();
}

class _TreatmentDialogState extends State<TreatmentDialog> {
  final TextEditingController _treatmentTypeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _applicationDateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now())
  );

  @override
  void dispose() {
    _treatmentTypeController.dispose();
    _notesController.dispose();
    _applicationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Treatment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _treatmentTypeController,
              decoration: const InputDecoration(
                labelText: 'Treatment Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter treatment type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _applicationDateController,
              decoration: const InputDecoration(
                labelText: 'Application Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => FormUtils.selectDate(context, _applicationDateController),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_treatmentTypeController.text.isNotEmpty) {
              widget.onAddTreatment(Treatment(
                treatmentType: _treatmentTypeController.text,
                applicationDate: DateFormat('yyyy-MM-dd').parse(_applicationDateController.text),
                notes: _notesController.text,
              ));
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}