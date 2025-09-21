// components/hive_form/disease_signs_dialog.dart
import 'package:flutter/material.dart';

class DiseaseSignsDialog extends StatefulWidget {
  final List<String> selectedDiseaseSigns;
  final List<String> diseaseOptions;
  final Function(List<String>) onDiseaseSignsChanged;

  const DiseaseSignsDialog({
    super.key,
    required this.selectedDiseaseSigns,
    required this.diseaseOptions,
    required this.onDiseaseSignsChanged,
  });

  @override
  State<DiseaseSignsDialog> createState() => _DiseaseSignsDialogState();
}

class _DiseaseSignsDialogState extends State<DiseaseSignsDialog> {
  late List<String> _tempSelectedDiseaseSigns;

  @override
  void initState() {
    super.initState();
    _tempSelectedDiseaseSigns = List.from(widget.selectedDiseaseSigns);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Disease Signs'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.diseaseOptions.length,
          itemBuilder: (BuildContext context, int index) {
            final disease = widget.diseaseOptions[index];
            return CheckboxListTile(
              title: Text(disease),
              value: _tempSelectedDiseaseSigns.contains(disease),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _tempSelectedDiseaseSigns.add(disease);
                  } else {
                    _tempSelectedDiseaseSigns.remove(disease);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            widget.onDiseaseSignsChanged(_tempSelectedDiseaseSigns);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}