import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

// Function to send data to backend
Future<void> sendDataToBackend({
  required String incidentType,
  required String type,
  required String description,
  required bool rerouting,
  String? reroutingNewVehicleNo,
  String? reroutingNewDriverNo,
}) async {
  final url = Uri.parse('http://localhost:3000/api/v1/issue');

  final body = {
    'incidentType': incidentType,
    'type': type,
    'description': description,
    'rerouting': rerouting,
  };

  if (rerouting) {
    if (reroutingNewVehicleNo == null || reroutingNewDriverNo == null) {
      throw Exception(
          'Both reroutingNewVehicleNo and reroutingNewDriverNo must be provided when rerouting is true.');
    }
    body['reroutingNewVehicleNo'] = reroutingNewVehicleNo;
    body['reroutingNewDriverNo'] = reroutingNewDriverNo;
  }

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(body),
  );

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Failed to submit form: ${response.body}');
  }
}

// Form Page Widget
class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String? incidentType;
  String? rerouting;
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _formSubmitted = false; // State variable to track form submission

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final type = _typeController.text;
    final description = _descriptionController.text;

    if (incidentType != null &&
        rerouting != null &&
        type.isNotEmpty &&
        description.isNotEmpty) {
      sendDataToBackend(
        incidentType: incidentType!,
        type: type,
        description: description,
        rerouting: rerouting == 'Yes',
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
        setState(() {
          _formSubmitted = true; // Set the state variable to true
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit the form: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues Form'),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/accident.json', // Path to your Lottie animation asset
                        height: 200,
                        width: 200,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Center(
                      child: Text(
                        'Report an Issue',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 101, 101, 237),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Issue Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Accident'),
                          value: 'Accident',
                          groupValue: incidentType,
                          onChanged: (value) {
                            setState(() {
                              incidentType = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Malfunction'),
                          value: 'Malfunction',
                          groupValue: incidentType,
                          onChanged: (value) {
                            setState(() {
                              incidentType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Do you want rerouting?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Yes'),
                            value: 'Yes',
                            groupValue: rerouting,
                            onChanged: (value) {
                              setState(() {
                                rerouting = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('No'),
                            value: 'No',
                            groupValue: rerouting,
                            onChanged: (value) {
                              setState(() {
                                rerouting = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button color
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                          shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _formSubmitted
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Form submitted successfully.'),
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 50.0,
                                      vertical: 15.0,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // Close the form page
                                  },
                                  child: const Text('Back'),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FormPage(),
  ));
}
