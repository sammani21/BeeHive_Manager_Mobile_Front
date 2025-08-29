import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateBeekeeperScreen extends StatefulWidget {
  final String beekeeperEmail;

  const UpdateBeekeeperScreen({super.key, required this.beekeeperEmail});

  @override
  State<UpdateBeekeeperScreen> createState() => _UpdateBeekeeperScreenState();
}

class _UpdateBeekeeperScreenState extends State<UpdateBeekeeperScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  String? _errorMessage;
  bool _isLoading = true;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Color scheme
  final Color primaryColor = const Color(0xFFFFB22C);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF343A40);
  final Color secondaryTextColor = const Color(0xFF6C757D);
  final Color borderColor = const Color(0xFFDEE2E6);

  Future<void> _fetchBeekeeperDetails() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? beekeeperJson = prefs.getString('beekeeper');

    if (beekeeperJson != null) {
      try {
        final data = jsonDecode(beekeeperJson);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _nicController.text = data['nic'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _contactNoController.text = data['contactNo'] ?? '';
          _selectedGender = data['gender'] ?? _genderOptions.first;
          _dobController.text = data['dob'] ?? '';
          _errorMessage = null;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to parse beekeeper details';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to load beekeeper details';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _handleCancel() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void initState() {
    super.initState();
    _fetchBeekeeperDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF343A40)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Beekeeper Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_firstNameController.text} ${_lastNameController.text}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _usernameController.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Personal information card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your account details',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // First Name
                          _buildReadOnlyField(_firstNameController, 'First Name', Icons.person_outline),
                          const SizedBox(height: 16),
                          
                          // Last Name
                          _buildReadOnlyField(_lastNameController, 'Last Name', Icons.person_outline),
                          const SizedBox(height: 16),
                          
                          // NIC
                          _buildReadOnlyField(_nicController, 'NIC', Icons.badge_outlined),
                          const SizedBox(height: 16),
                          
                          // Username
                          _buildReadOnlyField(_usernameController, 'Username', Icons.alternate_email_rounded),
                          const SizedBox(height: 16),
                          
                          // Email
                          _buildReadOnlyField(_emailController, 'Email', Icons.email_outlined),
                          const SizedBox(height: 16),
                          
                          // Contact No
                          _buildReadOnlyField(_contactNoController, 'Contact No', Icons.phone_outlined),
                          const SizedBox(height: 16),
                          
                          // Date of Birth
                          _buildReadOnlyField(_dobController, 'Date of Birth', Icons.calendar_today_outlined),
                          const SizedBox(height: 16),
                          
                          // Gender Dropdown
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              // ignore: deprecated_member_use
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down_rounded, color: primaryColor),
                                items: _genderOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                                style: TextStyle(color: textColor, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          // ignore: deprecated_member_use
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Cancel button
                    Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 16),
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          'BACK TO DASHBOARD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            // ignore: deprecated_member_use
            color: textColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: secondaryTextColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.text.isEmpty ? 'Not provided' : controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.text.isEmpty ? secondaryTextColor : textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}