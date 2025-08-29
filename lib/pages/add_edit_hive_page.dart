// pages/add_edit_hive_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/hive_model.dart';

class AddHivePage extends StatefulWidget {
  final Hive? hive;

  const AddHivePage({super.key, this.hive});

  @override
  // ignore: library_private_types_in_public_api
  _AddHivePageState createState() => _AddHivePageState();
}

class _AddHivePageState extends State<AddHivePage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Text editing controllers
  late TextEditingController _hiveNameController;
  late TextEditingController _hiveTypeController;
  late TextEditingController _installationDateController;
  late TextEditingController _lastInspectionController;
  late TextEditingController _queenStatusController;
  late TextEditingController _broodPatternController;
  late TextEditingController _honeyStoresController;
  late TextEditingController _pestLevelController;
  late TextEditingController _locationController;
  late TextEditingController _populationController;
  
  // For multi-select disease signs
  List<String> _selectedDiseaseSigns = [];
  final List<String> _diseaseOptions = [
    'Varroa Mites',
    'American Foulbrood',
    'European Foulbrood',
    'Nosema',
    'Chalkbrood',
    'Sacbrood',
    'Wax Moths',
    'Small Hive Beetles'
  ];
  
  // For treatments
  List<Treatment> _treatments = [];
  
  // Strength slider value
  double _strengthValue = 5.0;
  
  // Loading state
  bool _isLoading = false;
  String? _errorText;
  
  // Color scheme
  final Color primaryColor = const Color(0xFFFFB22C);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF343A40);
  final Color secondaryTextColor = const Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing values if editing
    _hiveNameController = TextEditingController(text: widget.hive?.hiveName ?? '');
    _hiveTypeController = TextEditingController(text: widget.hive?.hiveType ?? 'Langstroth');
    _installationDateController = TextEditingController(
      text: widget.hive != null 
        ? DateFormat('yyyy-MM-dd').format(widget.hive!.installationDate) 
        : DateFormat('yyyy-MM-dd').format(DateTime.now())
    );
    _lastInspectionController = TextEditingController(
      text: widget.hive != null 
        ? DateFormat('yyyy-MM-dd').format(widget.hive!.lastInspection) 
        : DateFormat('yyyy-MM-dd').format(DateTime.now())
    );
    _queenStatusController = TextEditingController(text: widget.hive?.queenStatus ?? 'Present');
    _broodPatternController = TextEditingController(text: widget.hive?.broodPattern ?? 'Solid');
    _honeyStoresController = TextEditingController(text: widget.hive?.honeyStores.toString() ?? '5');
    _pestLevelController = TextEditingController(text: widget.hive?.pestLevel.toString() ?? '0');
    _locationController = TextEditingController(text: widget.hive?.location ?? '');
    _populationController = TextEditingController(text: widget.hive?.population.toString() ?? '20000');
    
    // Set initial values
    if (widget.hive != null) {
      _strengthValue = widget.hive!.strength.toDouble();
      _selectedDiseaseSigns = List.from(widget.hive!.diseaseSigns);
      _treatments = List.from(widget.hive!.treatments);
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showDiseaseSignsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Disease Signs'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _diseaseOptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final disease = _diseaseOptions[index];
                    return CheckboxListTile(
                      title: Text(disease),
                      value: _selectedDiseaseSigns.contains(disease),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedDiseaseSigns.add(disease);
                          } else {
                            _selectedDiseaseSigns.remove(disease);
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
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addTreatment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final treatmentTypeController = TextEditingController();
        final notesController = TextEditingController();
        final applicationDateController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(DateTime.now())
        );

        return AlertDialog(
          title: const Text('Add Treatment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: treatmentTypeController,
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
                  controller: applicationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Application Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, applicationDateController),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
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
                if (treatmentTypeController.text.isNotEmpty) {
                  setState(() {
                    _treatments.add(Treatment(
                      treatmentType: treatmentTypeController.text,
                      applicationDate: DateFormat('yyyy-MM-dd').parse(applicationDateController.text),
                      notes: notesController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeTreatment(int index) {
    setState(() {
      _treatments.removeAt(index);
    });
  }

  Future<void> _saveHive() async {
  // Dismiss keyboard
  FocusScope.of(context).unfocus();
  
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      
      
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorText = 'Authentication error. Please log in again.';
        });
        return;
      }

      final Map<String, dynamic> hiveData = {
        'hiveName': _hiveNameController.text,
        'hiveType': _hiveTypeController.text,
        'installationDate': _installationDateController.text,
        'lastInspection': _lastInspectionController.text,
        'strength': _strengthValue.round(),
        'queenStatus': _queenStatusController.text,
        'broodPattern': _broodPatternController.text,
        'honeyStores': int.parse(_honeyStoresController.text),
        'pestLevel': int.parse(_pestLevelController.text),
        'diseaseSigns': _selectedDiseaseSigns,
        'treatments': _treatments.map((t) => {
          'treatmentType': t.treatmentType,
          'applicationDate': DateFormat('yyyy-MM-dd').format(t.applicationDate),
          'notes': t.notes,
        }).toList(),
        'location': _locationController.text,
        'population': int.parse(_populationController.text),
      };

      final String url = widget.hive != null
          ? 'http://localhost:3000/api/v1/hive/${widget.hive!}'
          : 'http://localhost:3000/api/v1/hive';

      final response = widget.hive != null
          ? await http.put(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(hiveData),
            )
          : await http.post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(hiveData),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Extract recommendation from response
        String? recommendation = responseData['data']?['recommendation'];
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.hive != null ? 'Hive updated successfully!' : 'Hive created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Show recommendation dialog if available
        if (recommendation != null && recommendation.isNotEmpty) {
          _showRecommendationDialog(recommendation);
        } else {
          // Navigate back if no recommendation
          Navigator.pop(context, true);
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save hive');
      }
    } catch (error) {
      setState(() {
        _errorText = error.toString();
      });
      // Haptic feedback for error
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

void _showRecommendationDialog(String recommendation) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF343A40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'These recommendations are generated based on your hive data. Always consult with experienced beekeepers or local experts for specific situations.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy recommendation to clipboard
              Clipboard.setData(ClipboardData(text: recommendation));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recommendations copied to clipboard'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, size: 16, color: secondaryTextColor),
                const SizedBox(width: 4),
                Text(
                  'Copy',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pop(context, true); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final double horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.hive == null ? 'Add New Hive' : 'Edit Hive',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFFFFB22C)),
            onPressed: _isLoading ? null : _saveHive,
            tooltip: 'Save Hive',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorText != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _hiveNameController,
                                decoration: InputDecoration(
                                  labelText: 'Hive Name *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.title),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a hive name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _hiveTypeController.text,
                                decoration: InputDecoration(
                                  labelText: 'Hive Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.category),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                items: ['Langstroth', 'Top Bar', 'Warre', 'Flow', 'Other']
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _hiveTypeController.text = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _locationController,
                                decoration: InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.location_on),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Dates Section
                      _buildSectionHeader('Dates'),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _installationDateController,
                                decoration: InputDecoration(
                                  labelText: 'Installation Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context, _installationDateController),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _lastInspectionController,
                                decoration: InputDecoration(
                                  labelText: 'Last Inspection Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context, _lastInspectionController),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Colony Health Section
                      _buildSectionHeader('Colony Health'),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.energy_savings_leaf, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Colony Strength',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_strengthValue.round()}/10',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _strengthValue,
                                min: 0,
                                max: 10,
                                divisions: 10,
                                label: _strengthValue.round().toString(),
                                activeColor: primaryColor,
                                onChanged: (double value) {
                                  setState(() {
                                    _strengthValue = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _queenStatusController.text,
                                decoration: InputDecoration(
                                  labelText: 'Queen Status',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.emoji_nature),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                items: ['Present', 'Not Present', 'Unknown']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _queenStatusController.text = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _broodPatternController.text,
                                decoration: InputDecoration(
                                  labelText: 'Brood Pattern',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.grid_on),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                items: ['Solid', 'Spotty', 'None', 'Other']
                                    .map((pattern) => DropdownMenuItem(
                                          value: pattern,
                                          child: Text(pattern),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _broodPatternController.text = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              isSmallScreen 
                                ? Column(
                                    children: [
                                      TextFormField(
                                        controller: _populationController,
                                        decoration: InputDecoration(
                                          labelText: 'Population Estimate',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          prefixIcon: const Icon(Icons.people),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: primaryColor, width: 2),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _honeyStoresController,
                                        decoration: InputDecoration(
                                          labelText: 'Honey Stores (kg)',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          prefixIcon: const Icon(Icons.local_drink),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: primaryColor, width: 2),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _populationController,
                                          decoration: InputDecoration(
                                            labelText: 'Population Estimate',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            prefixIcon: const Icon(Icons.people),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: primaryColor, width: 2),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _honeyStoresController,
                                          decoration: InputDecoration(
                                            labelText: 'Honey Stores (kg)',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            prefixIcon: const Icon(Icons.local_drink),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: primaryColor, width: 2),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pestLevelController,
                                decoration: InputDecoration(
                                  labelText: 'Pest Level (0-10)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.bug_report),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Disease Signs Section
                      _buildSectionHeader('Disease Signs'),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.health_and_safety, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: const Text(
                                      'Disease Signs Observed',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _showDiseaseSignsDialog,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: Text(isSmallScreen ? '' : 'Select'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: isSmallScreen 
                                        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_selectedDiseaseSigns.isEmpty)
                                const Text('No disease signs selected', style: TextStyle(color: Colors.grey))
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedDiseaseSigns
                                      .map((sign) => Chip(
                                            label: Text(sign),
                                            backgroundColor: Colors.amber[50],
                                            deleteIcon: const Icon(Icons.close, size: 16),
                                            onDeleted: () {
                                              setState(() {
                                                _selectedDiseaseSigns.remove(sign);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Treatments Section
                      _buildSectionHeader('Treatments'),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.medical_services, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Treatments Applied',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _addTreatment,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: Text(isSmallScreen ? '' : 'Add Treatment'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: isSmallScreen 
                                        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_treatments.isEmpty)
                                const Text('No treatments added', style: TextStyle(color: Colors.grey))
                              else
                                ..._treatments.asMap().entries.map((entry) {
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
                                        onPressed: () => _removeTreatment(index),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Save Button
                      Center(
                        child: SizedBox(
                          width: isSmallScreen ? double.infinity : null,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveHive,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isLoading 
                                ? 'Saving...' 
                                : widget.hive == null ? 'Create Hive' : 'Update Hive',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up all controllers
    _hiveNameController.dispose();
    _hiveTypeController.dispose();
    _installationDateController.dispose();
    _lastInspectionController.dispose();
    _queenStatusController.dispose();
    _broodPatternController.dispose();
    _honeyStoresController.dispose();
    _pestLevelController.dispose();
    _locationController.dispose();
    _populationController.dispose();
    super.dispose();
  }
}